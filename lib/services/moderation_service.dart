import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class ModerationResult {
  final bool isApproved;
  final String? reason;

  ModerationResult({required this.isApproved, this.reason});
}

class ModerationService {
  static final _supabase = Supabase.instance.client;

  /// Scans a file (image/video) for inappropriate content using AWS Rekognition 
  /// via a secure Supabase Edge Function.
  static Future<ModerationResult> scanMedia(XFile file) async {
    try {
      // 1. Convert file to base64 for transmission to Edge Function
      // (For large videos, we would upload to a private bucket first and send the path, 
      // but for MVP images/short clips base64 works)
      final bytes = await file.readAsBytes();
      final base64Media = base64Encode(bytes);

      // 2. Call Supabase Edge Function which integrates with AWS Rekognition
      final res = await _supabase.functions.invoke(
        'moderate_content',
        body: {
          'media_base64': base64Media,
          'file_type': file.name.split('.').last, // e.g. 'jpg', 'mp4'
        },
      );

      final data = res.data;
      
      // Expected response from our Edge Function:
      // { "approved": false, "reason": "Explicit nudity detected" }
      if (data != null && data['approved'] == false) {
        return ModerationResult(
          isApproved: false,
          reason: data['reason'] ?? 'Content violates community guidelines.',
        );
      }

      return ModerationResult(isApproved: true);
    } on FunctionException catch (e) {
      // If the edge function itself fails (e.g. AWS Rekognition is down)
      // For safety, we block the upload when moderation is unreachable
      return ModerationResult(
        isApproved: false, 
        reason: 'Moderation service unavailable. Please try again later. Error: ${e.toString()}'
      );
    } catch (e) {
      return ModerationResult(
        isApproved: false,
        reason: 'An unexpected error occurred during content moderation.',
      );
    }
  }
}
