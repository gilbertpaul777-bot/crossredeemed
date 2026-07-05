require('dotenv').config();
const express = require('express');
const cors = require('cors');
const multer = require('multer');
const ffmpegPath = require('ffmpeg-static');
const ffmpeg = require('fluent-ffmpeg');
ffmpeg.setFfmpegPath(ffmpegPath);
const fs = require('fs');
const path = require('path');
const os = require('os');
const { S3Client, PutObjectCommand, GetObjectCommand } = require('@aws-sdk/client-s3');
const { createClient } = require('@supabase/supabase-js');

const app = express();
app.use(cors());
app.use(express.json());

// Set up Multer for direct file uploads to a temporary directory
const upload = multer({ dest: os.tmpdir() });

// Backblaze B2 Configuration (S3 Compatible)
const s3Client = new S3Client({
  endpoint: process.env.B2_ENDPOINT, // e.g., https://s3.us-west-004.backblazeb2.com
  region: process.env.B2_REGION,     // e.g., us-west-004
  credentials: {
    accessKeyId: process.env.B2_KEY_ID,
    secretAccessKey: process.env.B2_APPLICATION_KEY,
  }
});
const B2_BUCKET = process.env.B2_BUCKET_NAME;

// Supabase Configuration
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

app.post('/upload', upload.single('video'), async (req, res) => {
  try {
    const { videoId, userId } = req.body;
    let trimStart = req.body.trimStart ? parseFloat(req.body.trimStart) : null;
    let trimEnd = req.body.trimEnd ? parseFloat(req.body.trimEnd) : null;
    const file = req.file;

    if (!file || !videoId || !userId) {
      return res.status(400).send('Missing video file, videoId, or userId');
    }

    console.log(`Processing videoId: ${videoId} for userId: ${userId}`);

    const rawFilePath = file.path;
    const outputDir = path.join(os.tmpdir(), `output_${videoId}`);
    
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir);
    }

    // 1. Transcode to HLS using FFmpeg
    console.log('Starting FFmpeg transcoding to HLS...');
    const m3u8Path = path.join(outputDir, 'manifest.m3u8');
    
    await new Promise((resolve, reject) => {
      let command = ffmpeg(rawFilePath);
      
      if (trimStart !== null && trimEnd !== null) {
        console.log(`Applying trim: start=${trimStart}, duration=${trimEnd - trimStart}`);
        command = command.setStartTime(trimStart).setDuration(trimEnd - trimStart);
      }

      command
        // Basic HLS settings
        .outputOptions([
          '-profile:v baseline', 
          '-level 3.0', 
          '-start_number 0', 
          '-hls_time 10', 
          '-hls_list_size 0',
          '-f hls'
        ])
        .output(m3u8Path)
        .on('end', () => {
          console.log('FFmpeg processing finished.');
          resolve();
        })
        .on('error', (err) => {
          console.error('FFmpeg error:', err);
          reject(err);
        })
        .run();
    });

    // 2. Upload the HLS files back to Backblaze B2
    console.log('Uploading HLS files to Backblaze B2...');
    const files = fs.readdirSync(outputDir);
    for (const fileName of files) {
      const localFilePath = path.join(outputDir, fileName);
      const destination = `stream/${videoId}/${fileName}`;
      const fileStream = fs.createReadStream(localFilePath);
      
      const contentType = fileName.endsWith('.m3u8') 
        ? 'application/vnd.apple.mpegurl' 
        : 'video/MP2T';

      await s3Client.send(new PutObjectCommand({
        Bucket: B2_BUCKET,
        Key: destination,
        Body: fileStream,
        ContentType: contentType,
        CacheControl: 'public, max-age=31536000'
      }));
      console.log(`Uploaded ${destination}`);
    }

    // 3. Update Supabase Document Status
    console.log(`Updating Supabase document posts/${videoId} to ready...`);
    
    // We will use our own API to proxy the private Backblaze files
    // In production, replace localhost with your Render URL
    const baseUrl = process.env.RENDER_EXTERNAL_URL || `http://localhost:${process.env.PORT || 8080}`;
    const hlsUrl = `${baseUrl}/stream/${videoId}/manifest.m3u8`;
    
    const { error } = await supabase
      .from('posts')
      .update({
        status: 'ready',
        video_url: hlsUrl,
      })
      .eq('id', videoId);

    if (error) {
      console.error('Supabase update error:', error);
      throw error;
    }

    console.log('Pipeline complete! Cleaning up temporary files...');
    
    // 4. Clean up local files
    fs.unlinkSync(rawFilePath);
    files.forEach(f => fs.unlinkSync(path.join(outputDir, f)));
    fs.rmdirSync(outputDir);

    res.status(200).send({ message: 'Transcoding complete and Supabase updated.', hlsUrl });

  } catch (error) {
    console.error('Error during processing:', error);
    res.status(500).send(`Internal Server Error: ${error.message}`);
  }
});

// Proxy route to serve private Backblaze HLS files
app.get('/stream/:videoId/:fileName', async (req, res) => {
  const { videoId, fileName } = req.params;
  const key = `stream/${videoId}/${fileName}`;
  
  try {
    const data = await s3Client.send(new GetObjectCommand({
      Bucket: B2_BUCKET,
      Key: key,
    }));
    
    if (fileName.endsWith('.m3u8')) {
      res.setHeader('Content-Type', 'application/vnd.apple.mpegurl');
    } else {
      res.setHeader('Content-Type', 'video/MP2T');
    }
    
    // Stream the file directly from Backblaze to the Flutter client
    data.Body.pipe(res);
  } catch (error) {
    console.error(`Error fetching ${key} from B2:`, error);
    res.status(404).send('File not found');
  }
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`Render API Transcoder listening on port ${port}`);
});
