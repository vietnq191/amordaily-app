import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amordaily/providers/love_provider.dart';
import 'package:amordaily/utils/constants.dart';
import 'package:amordaily/utils/app_localizations.dart';
import 'package:intl/intl.dart';

class AnniversaryScreen extends StatelessWidget {
  const AnniversaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoveProvider>(
      builder: (context, loveProvider, _) {
        final loc = loveProvider.loc;
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(loc.t('anniversary_title')),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                onPressed: () => _showMilestoneDialog(context, loveProvider, loc),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(child: _buildBody(context, loveProvider, loc)),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, LoveProvider loveProvider, AppLocalizations loc) {
    final milestones = loveProvider.getFilteredMilestones(includeAllCustom: true);

    if (milestones.isEmpty) {
      return Center(
        child: Text(loc.t('not_set'), style: const TextStyle(color: Colors.white54)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
      itemCount: milestones.length,
      itemBuilder: (context, index) {
        final m = milestones[index];
        final isPassed = (m['date'] as DateTime).isBefore(DateTime.now());
        final daysLeft = (m['date'] as DateTime).difference(DateTime.now()).inDays;
        final isDefault = m['isDefault'] == true;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: !isDefault && m.containsKey('customIndex')
                  ? () => _showMilestoneDialog(context, loveProvider, loc, index: m['customIndex'] as int)
                  : null,
              onLongPress: !isDefault && m.containsKey('customIndex')
                  ? () => _showDeleteDialog(context, loveProvider, m['customIndex'] as int, loc)
                  : null,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isPassed
                        ? Colors.white.withValues(alpha: 0.05)
                        : AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isPassed
                            ? Colors.green.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isPassed ? Icons.check_circle_rounded : (isDefault ? Icons.favorite_rounded : Icons.star_rounded),
                        color: isPassed ? Colors.greenAccent : AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m['title'] as String,
                            style: TextStyle(
                              color: isPassed ? Colors.white54 : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            DateFormat('dd/MM/yyyy').format(m['date'] as DateTime),
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    if (!isPassed)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
                        ),
                        child: Text(
                          '$daysLeft\n${loc.t('days_unit')}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      )
                    else
                      Text(loc.t('passed'), style: const TextStyle(color: Colors.white30, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /* This is now handled by provider.getFilteredMilestones()
     But we might want the screen to show ALL custom milestones even if they are far away.
     The provider.getFilteredMilestones() filters custom milestones by 60 days.
     Let's modify provider.getFilteredMilestones to take an optional 'includeAllCustom' flag?
     Or just handle it here for the screen. */


  Future<void> _showMilestoneDialog(BuildContext context, LoveProvider provider, AppLocalizations loc, {int? index}) async {
    final isEditing = index != null;
    final titleController = TextEditingController(
      text: isEditing ? provider.story.customMilestones[index].title : '',
    );
    DateTime selectedDate = isEditing ? provider.story.customMilestones[index].date : DateTime.now();

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            isEditing ? loc.t('edit_anniversary') : loc.t('add_anniversary'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: loc.t('anniversary_name_hint'),
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: selectedDate,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: AppColors.primary,
                            onPrimary: Colors.white,
                            surface: Color(0xFF1E1E2E),
                            onSurface: Colors.white,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) setDialogState(() => selectedDate = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded, color: AppColors.primary, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd/MM/yyyy').format(selectedDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                loc.t('cancel'),
                style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isNotEmpty) {
                  if (isEditing) {
                    provider.updateMilestone(index, title, selectedDate);
                  } else {
                    provider.addMilestone(title, selectedDate);
                  }
                  Navigator.pop(ctx);
                }
              },
              child: Text(
                isEditing ? loc.t('save') : loc.t('add'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, LoveProvider provider, int customIndex, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(loc.t('delete_anniversary'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.t('cancel'), style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              provider.removeMilestone(customIndex);
              Navigator.pop(ctx);
            },
            child: Text(loc.t('delete'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
