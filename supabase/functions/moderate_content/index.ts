import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { RekognitionClient, DetectModerationLabelsCommand } from "npm:@aws-sdk/client-rekognition";

// AWS Rekognition Setup
// Account Name: CrossRedeemed
// Account ID: 423937246519

const rekognitionClient = new RekognitionClient({
  region: Deno.env.get('AWS_REGION') ?? 'us-east-1',
  credentials: {
    accessKeyId: Deno.env.get('AWS_ACCESS_KEY_ID') ?? '',
    secretAccessKey: Deno.env.get('AWS_SECRET_ACCESS_KEY') ?? '',
  },
});

serve(async (req) => {
  try {
    // 1. Validate CORS
    if (req.method === 'OPTIONS') {
      return new Response('ok', { headers: corsHeaders });
    }

    // 2. Parse request payload
    const body = await req.json();
    const { imageBase64 } = body;

    if (!imageBase64) {
      return new Response(JSON.stringify({ error: 'No image provided' }), { status: 400 });
    }

    // 3. Convert Base64 to binary buffer
    const buffer = Uint8Array.from(atob(imageBase64), c => c.charCodeAt(0));

    // 4. Call AWS Rekognition
    const command = new DetectModerationLabelsCommand({
      Image: { Bytes: buffer },
      MinConfidence: 75,
    });

    const response = await rekognitionClient.send(command);

    // 5. Evaluate Labels
    const labels = response.ModerationLabels || [];
    const isExplicit = labels.some(label => 
      label.Name === 'Explicit Nudity' || 
      label.Name === 'Violence' ||
      label.Name === 'Drugs'
    );

    if (isExplicit) {
      const reasons = labels.map(l => l.Name).join(', ');
      return new Response(
        JSON.stringify({ isApproved: false, reason: `Inappropriate content detected: ${reasons}` }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    return new Response(
      JSON.stringify({ isApproved: true, reason: 'Content approved' }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );

  } catch (error) {
    console.error('Moderation error:', error);
    return new Response(JSON.stringify({ error: error.message }), { status: 500, headers: corsHeaders });
  }
});

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};
