import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';

class ReportDialog {
  static void show(BuildContext context, {String? reportedUserId, String? reportedPostId}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return _ReportSheet(reportedUserId: reportedUserId, reportedPostId: reportedPostId);
      },
    );
  }
}

class _ReportSheet extends StatefulWidget {
  final String? reportedUserId;
  final String? reportedPostId;

  const _ReportSheet({this.reportedUserId, this.reportedPostId});

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final List<String> _reasons = [
    'Inappropriate content',
    'Spam or misleading',
    'Harassment or bullying',
    'Hate speech',
    'Intellectual property violation',
    'Other'
  ];

  String? _selectedReason;
  final TextEditingController _detailsCtrl = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitReport() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a reason.')));
      return;
    }

    setState(() => _isSubmitting = true);
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must be logged in to report.')));
      return;
    }

    try {
      await Supabase.instance.client.from('reports').insert({
        'reporter_id': user.id,
        'reported_user_id': widget.reportedUserId,
        'reported_post_id': widget.reportedPostId,
        'reason': _selectedReason,
        'details': _detailsCtrl.text.trim(),
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted successfully. We will review it shortly.'),
            backgroundColor: AppTheme.primaryPurple,
          )
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting report: $e')));
      }
    }
  }

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Why are you reporting this?',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _reasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return ChoiceChip(
                  label: Text(reason),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryPurple,
                  backgroundColor: Colors.black45,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.white70),
                  onSelected: (selected) {
                    setState(() {
                      _selectedReason = selected ? reason : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsCtrl,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Additional details (optional)',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Colors.black45,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                      )
                    : const Text('Submit Report', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
