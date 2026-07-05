import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class DataPrivacyService {
  static final _supabase = Supabase.instance.client;

  /// Requests a ZIP export of all user data.
  /// Typically, the backend generates this asynchronously and emails a secure link.
  static Future<void> requestDataExport() async {
    try {
      await _supabase.functions.invoke('gdpr_export_data');
    } catch (e) {
      debugPrint('Failed to request data export: $e');
      rethrow;
    }
  }

  /// Initiates a hard delete of the user's account and all associated data.
  /// Because Supabase Auth deletion must be done with service_role privileges,
  /// this calls an Edge Function that verifies the JWT and safely deletes the user.
  static Future<void> deleteAccount() async {
    try {
      await _supabase.functions.invoke('gdpr_delete_account');
      
      // Sign out locally after requesting deletion
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Failed to delete account: $e');
      rethrow;
    }
  }
}
