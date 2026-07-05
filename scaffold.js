const fs = require('fs');
const path = require('path');

const screens = {
  auth: [
    { file: 'welcome_screen.dart', cls: 'WelcomeScreen', title: '1. WELCOME SCREEN' },
    { file: 'login_screen.dart', cls: 'LoginScreen', title: '2. LOGIN' },
    { file: 'sign_up_screen.dart', cls: 'SignUpScreen', title: '3. SIGN UP' },
    { file: 'forgot_password_screen.dart', cls: 'ForgotPasswordScreen', title: '4. FORGOT PASSWORD' },
    { file: 'email_verification_screen.dart', cls: 'EmailVerificationScreen', title: '5. EMAIL VERIFICATION' },
    { file: 'terms_of_service_screen.dart', cls: 'TermsOfServiceScreen', title: '6. TERMS OF SERVICE' },
    { file: 'privacy_policy_screen.dart', cls: 'PrivacyPolicyScreen', title: '7. PRIVACY POLICY' },
  ],
  home: [
    { file: 'home_feed_screen.dart', cls: 'HomeFeedScreen', title: '1. HOME FEED' },
    { file: 'following_feed_screen.dart', cls: 'FollowingFeedScreen', title: '2. FOLLOWING FEED' },
    { file: 'video_details_screen.dart', cls: 'VideoDetailsScreen', title: '3. VIDEO DETAILS' },
    { file: 'comments_screen.dart', cls: 'CommentsScreen', title: '4. COMMENTS' },
    { file: 'search_screen.dart', cls: 'SearchScreen', title: '5. SEARCH' },
    { file: 'creator_profile_screen.dart', cls: 'CreatorProfileScreen', title: '6. CREATOR PROFILE' },
  ],
  bible: [
    { file: 'bible_home_screen.dart', cls: 'BibleHomeScreen', title: '1. BIBLE HOME' },
    { file: 'bible_reader_screen.dart', cls: 'BibleReaderScreen', title: '2. BIBLE READER' },
    { file: 'chapter_view_screen.dart', cls: 'ChapterViewScreen', title: '3. CHAPTER VIEW' },
    { file: 'verse_view_screen.dart', cls: 'VerseViewScreen', title: '4. VERSE VIEW' },
    { file: 'scripture_search_screen.dart', cls: 'ScriptureSearchScreen', title: '5. SCRIPTURE SEARCH' },
    { file: 'commentary_screen.dart', cls: 'CommentaryScreen', title: '6. MATTHEW HENRY COMMENTARY' },
    { file: 'concordance_screen.dart', cls: 'ConcordanceScreen', title: "7. STRONG'S CONCORDANCE" },
    { file: 'cross_references_screen.dart', cls: 'CrossReferencesScreen', title: '8. CROSS REFERENCES' },
    { file: 'saved_verses_screen.dart', cls: 'SavedVersesScreen', title: '9. SAVED VERSES' },
    { file: 'notes_screen.dart', cls: 'NotesScreen', title: '10. NOTES' },
    { file: 'reading_history_screen.dart', cls: 'ReadingHistoryScreen', title: '11. READING HISTORY' },
  ],
  create: [
    { file: 'record_video_screen.dart', cls: 'RecordVideoScreen', title: '1. RECORD VIDEO' },
    { file: 'upload_video_screen.dart', cls: 'UploadVideoScreen', title: '2. UPLOAD VIDEO' },
    { file: 'edit_video_screen.dart', cls: 'EditVideoScreen', title: '3. EDIT VIDEO' },
    { file: 'add_scripture_overlay_screen.dart', cls: 'AddScriptureOverlayScreen', title: '4. ADD SCRIPTURE OVERLAY' },
    { file: 'add_caption_screen.dart', cls: 'AddCaptionScreen', title: '5. ADD CAPTION' },
    { file: 'preview_post_screen.dart', cls: 'PreviewPostScreen', title: '6. PREVIEW POST' },
    { file: 'create_drafts_screen.dart', cls: 'CreateDraftsScreen', title: '7. DRAFTS' },
  ],
  faith_wall: [
    { file: 'faith_wall_feed_screen.dart', cls: 'FaithWallFeedScreen', title: '1. FAITH WALL FEED' },
    { file: 'prayer_requests_screen.dart', cls: 'PrayerRequestsScreen', title: '2. PRAYER REQUESTS' },
    { file: 'testimonies_screen.dart', cls: 'TestimoniesScreen', title: '3. TESTIMONIES' },
    { file: 'praise_reports_screen.dart', cls: 'PraiseReportsScreen', title: '4. PRAISE REPORTS' },
    { file: 'post_details_screen.dart', cls: 'PostDetailsScreen', title: '5. POST DETAILS' },
    { file: 'faith_wall_comments_screen.dart', cls: 'FaithWallCommentsScreen', title: '6. COMMENTS' },
  ],
  profile: [
    { file: 'my_profile_screen.dart', cls: 'MyProfileScreen', title: '1. MY PROFILE' },
    { file: 'edit_profile_screen.dart', cls: 'EditProfileScreen', title: '2. EDIT PROFILE' },
    { file: 'saved_content_screen.dart', cls: 'SavedContentScreen', title: '3. SAVED CONTENT' },
    { file: 'liked_content_screen.dart', cls: 'LikedContentScreen', title: '4. LIKED CONTENT' },
    { file: 'profile_drafts_screen.dart', cls: 'ProfileDraftsScreen', title: '5. DRAFTS' },
    { file: 'inbox_screen.dart', cls: 'InboxScreen', title: '6. INBOX' },
    { file: 'chat_list_screen.dart', cls: 'ChatListScreen', title: '7. CHAT LIST' },
    { file: 'direct_message_screen.dart', cls: 'DirectMessageScreen', title: '8. DIRECT MESSAGE' },
  ],
  system: [
    { file: 'notifications_screen.dart', cls: 'NotificationsScreen', title: '1. NOTIFICATIONS' },
    { file: 'report_content_screen.dart', cls: 'ReportContentScreen', title: '2. REPORT CONTENT' },
    { file: 'help_center_screen.dart', cls: 'HelpCenterScreen', title: '3. HELP CENTER' },
    { file: 'community_guidelines_screen.dart', cls: 'CommunityGuidelinesScreen', title: '4. COMMUNITY GUIDELINES' },
  ],
  admin: [
    { file: 'admin_dashboard_screen.dart', cls: 'AdminDashboardScreen', title: '1. ADMIN DASHBOARD' },
    { file: 'user_management_screen.dart', cls: 'UserManagementScreen', title: '2. USER MANAGEMENT' },
    { file: 'content_moderation_screen.dart', cls: 'ContentModerationScreen', title: '3. CONTENT MODERATION' },
    { file: 'reports_queue_screen.dart', cls: 'ReportsQueueScreen', title: '4. REPORTS QUEUE' },
    { file: 'analytics_screen.dart', cls: 'AnalyticsScreen', title: '5. ANALYTICS' },
  ]
};

const baseDir = path.join(__dirname, 'lib', 'screens');

for (const section in screens) {
  const dir = path.join(baseDir, section);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }

  screens[section].forEach(screen => {
    const filePath = path.join(dir, screen.file);
    const content = `import 'package:flutter/material.dart';

class ${screen.cls} extends StatelessWidget {
  const ${screen.cls}({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${screen.title}')),
      body: Center(
        child: Text('${screen.title}', style: const TextStyle(color: Colors.white, fontSize: 20)),
      ),
    );
  }
}
`;
    fs.writeFileSync(filePath, content);
    console.log(`Created ${filePath}`);
  });
}
