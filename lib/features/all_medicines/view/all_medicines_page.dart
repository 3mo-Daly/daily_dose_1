import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../home/cubit/home_cubit.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/medicine_model.dart';
import 'package:daily_dose/l10n/app_localizations.dart';

class AllMedicinesPage extends StatelessWidget {
  const AllMedicinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.allMedicinesTitle), centerTitle: true),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          if (profileState is! ProfileLoaded ||
              profileState.selectedProfileId == null) {
            return Center(
                child: Text(AppLocalizations.of(context)!.selectProfileFirst));
          }

          final profileId = profileState.selectedProfileId!;
          // ValueListenableBuilder subscribes directly to the Hive box so any
          // mutation (add, delete, update) triggers an immediate rebuild —
          // independent of whether HomeCubit happens to emit a new state.
          final medicineBox = context.read<HomeCubit>().medicineBox;

          return ValueListenableBuilder<Box<Medicine>>(
            valueListenable: medicineBox.listenable(),
            builder: (context, box, _) {
              final allMedicines = box.values
                  .where((m) => m.profileId == profileId)
                  .toList()
                ..sort((a, b) => b.startTime.compareTo(a.startTime));

              if (allMedicines.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.folder_open_rounded,
                        size: 80,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noMedicinesRecorded,
                        style: TextStyle(
                          color: (Theme.of(context).textTheme.bodyLarge?.color ??
                                  Colors.black)
                              .withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: allMedicines.length,
                itemBuilder: (context, index) {
                  final medicine = allMedicines[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    color: Theme.of(context).colorScheme.surface,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _showMedicineReportSheet(context, medicine),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                image: medicine.imagePath != null
                                    ? DecorationImage(
                                        image: FileImage(
                                            File(medicine.imagePath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: medicine.imagePath == null
                                  ? Icon(
                                      Icons.medication_rounded,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: 32,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    medicine.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    medicine.dosage,
                                    style: TextStyle(
                                      color: (Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.color ??
                                              Colors.black)
                                          .withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showMedicineReportSheet(BuildContext context, Medicine medicine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MedicineReportSheet(medicine: medicine),
    );
  }
}

class _MedicineReportSheet extends StatelessWidget {
  final Medicine medicine;

  const _MedicineReportSheet({required this.medicine});

  @override
  Widget build(BuildContext context) {
    final onlyDateFormat = DateFormat.yMMMd();
    final timeFormat = DateFormat.jm();

    final initialSchedule = medicine.isInterval
        ? medicine.startTime
        : (medicine.fixedTime ?? medicine.startTime);

    final endDate = medicine.durationDays != null
        ? initialSchedule.add(Duration(days: medicine.durationDays!))
        : null;

    // Calculate Doses Taken
    final takenCount = medicine.history.length;

    // Sort history for display
    final List<DateTime> sortedHistory = List.from(medicine.history)
      ..sort((a, b) => b.compareTo(a));

    // Calculate Missed Doses approximation
    int missedCount = 0;
    int expectedCount = 0;
    final now = DateTime.now();

    // Determine the end boundary for calculation (now, or earlier if it ended)
    final calcEnd = (endDate != null && endDate.isBefore(now)) ? endDate : now;

    if (medicine.isInterval && medicine.intervalHours != null) {
      DateTime current = medicine.startTime;
      while (current.isBefore(calcEnd)) {
        // Check bounds
        bool isHidden = false;
        if (medicine.hideBefore != null &&
            current.isBefore(medicine.hideBefore!)) {
          isHidden = true;
        }
        if (medicine.hideAfter != null && current.isAfter(medicine.hideAfter!)) {
          isHidden = true;
        }

        // Check explicit deleted occurrences
        bool isDeleted = medicine.deletedOccurrences.any(
          (dt) =>
              dt.year == current.year &&
              dt.month == current.month &&
              dt.day == current.day &&
              dt.hour == current.hour &&
              dt.minute == current.minute,
        );

        if (!isHidden && !isDeleted) {
          expectedCount++;
        }
        current = current.add(Duration(hours: medicine.intervalHours!));
      }
    } else if (medicine.fixedTime != null) {
      DateTime current = DateTime(
        medicine.startTime.year,
        medicine.startTime.month,
        medicine.startTime.day,
      );
      final finalEndDay = DateTime(calcEnd.year, calcEnd.month, calcEnd.day);

      while (!current.isAfter(finalEndDay)) {
        final occurrenceTime = DateTime(
          current.year,
          current.month,
          current.day,
          medicine.fixedTime!.hour,
          medicine.fixedTime!.minute,
        );

        if (occurrenceTime.isBefore(calcEnd)) {
          bool isHidden = false;
          if (medicine.hideBefore != null &&
              occurrenceTime.isBefore(medicine.hideBefore!)) {
            isHidden = true;
          }
          if (medicine.hideAfter != null &&
              occurrenceTime.isAfter(medicine.hideAfter!)) {
            isHidden = true;
          }

          bool isDeleted = medicine.deletedOccurrences.any(
            (dt) =>
                dt.year == occurrenceTime.year &&
                dt.month == occurrenceTime.month &&
                dt.day == occurrenceTime.day &&
                dt.hour == occurrenceTime.hour &&
                dt.minute == occurrenceTime.minute,
          );

          if (!isHidden && !isDeleted) {
            expectedCount++;
          }
        }
        current = current.add(const Duration(days: 1));
      }
    }

    // Missed = what was expected MINUS what was taken. (Can't be negative)
    missedCount = (expectedCount - takenCount) > 0
        ? (expectedCount - takenCount)
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20.0,
        right: 20.0,
        top: 24.0,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.0,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (medicine.imagePath != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          File(medicine.imagePath!),
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondaryContainer.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.medication_rounded,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.dosageLabel(medicine.dosage),
                      style: TextStyle(
                        fontSize: 16,
                        color:
                            (Theme.of(context).textTheme.bodyLarge?.color ??
                                    Colors.black)
                                .withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Stats Cards
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    Expanded(
                      child: _ReportStatCard(
                        title: AppLocalizations.of(context)!.taken,
                        value: takenCount.toString(),
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFF10B981), // Emerald
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ReportStatCard(
                        title: AppLocalizations.of(context)!.missed,
                        value: missedCount.toString(),
                        icon: Icons.cancel_rounded,
                        color: const Color(0xFFEF4444), // Red
                      ),
                    ),
                  ],
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Timeline details
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      _TimelineRow(
                        title: AppLocalizations.of(context)!.started,
                        value: onlyDateFormat.format(initialSchedule),
                        icon: Icons.play_circle_fill_rounded,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(),
                      ),
                      _TimelineRow(
                        title: AppLocalizations.of(context)!.ends,
                        value: endDate != null
                            ? onlyDateFormat.format(endDate)
                            : AppLocalizations.of(context)!.ongoingIndefinitely,
                        icon: Icons.stop_circle_rounded,
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(),
                      ),
                      _TimelineRow(
                        title: AppLocalizations.of(context)!.frequency,
                        value:
                            medicine.isInterval &&
                                medicine.intervalHours != null
                            ? AppLocalizations.of(context)!.everyXHours(medicine.intervalHours!)
                            : AppLocalizations.of(context)!.dailyAt(medicine.fixedTime != null ? timeFormat.format(DateTime(0, 1, 1, medicine.fixedTime!.hour, medicine.fixedTime!.minute)) : timeFormat.format(initialSchedule)),
                        icon: Icons.repeat_rounded,
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // History List Title
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                  child: Text(
                    AppLocalizations.of(context)!.intakeHistory,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // History List Items
              if (sortedHistory.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.noHistoryRecorded,
                        style: TextStyle(
                          color:
                              (Theme.of(context).textTheme.bodyLarge?.color ??
                                      Colors.black)
                                  .withOpacity(0.5),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final historyDate = sortedHistory[index];
                    final exactTime =
                        medicine.exactTakenTimes?[historyDate
                            .toIso8601String()] ??
                        historyDate;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 0,
                      ),
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Color(0xFF10B981),
                        ),
                      ),
                      title: Text(
                        onlyDateFormat.format(exactTime),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      trailing: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            timeFormat.format(exactTime),
                            style: TextStyle(
                              color:
                                  (Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color ??
                                          Colors.black)
                                      .withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            AppLocalizations.of(context)!.planned(timeFormat.format(historyDate)),
                            style: TextStyle(
                              color:
                                  (Theme.of(
                                            context,
                                          ).textTheme.bodyLarge?.color ??
                                          Colors.black)
                                      .withOpacity(0.5),
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  }, childCount: sortedHistory.length),
                ),

              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.bottom + 40),
              ), // Bottom padding
            ],
          );
        },
      ),
    );
  }
}

class _ReportStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ReportStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _TimelineRow({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                color:
                    (Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.black)
                        .withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
