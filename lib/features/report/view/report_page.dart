import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/cubit/home_cubit.dart';
import '../../home/cubit/home_state.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import '../../../core/theme/app_theme.dart';
import 'package:daily_dose/l10n/app_localizations.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          if (profileState is ProfileLoaded &&
              profileState.selectedProfileId != null) {
            return BlocBuilder<HomeCubit, HomeState>(
              builder: (context, homeState) {
                final profileId = profileState.selectedProfileId!;
                final profile = profileState.profiles.firstWhere(
                  (p) => p.id == profileId,
                );

                // Read from the HomeCubit's central box for stats inside the builder so it rebuilds
                final homeCubit = context.read<HomeCubit>();
                final allMedicinesInBox = homeCubit.medicineBox.values
                    .where((m) => m.profileId == profileId)
                    .toList();

                final totalMedicines = allMedicinesInBox.length;
                int takenCount = 0;
                int activeCount = 0;
                int totalExpected = 0;

                final now = DateTime.now();

                for (var med in allMedicinesInBox) {
                  takenCount += med.history.length;

                  bool isExpired = false;
                  if (med.durationDays != null) {
                    final end = med.startTime.add(
                      Duration(days: med.durationDays!),
                    );
                    if (now.isAfter(end)) isExpired = true;
                  }
                  if (med.hideAfter != null && now.isAfter(med.hideAfter!)) {
                    isExpired = true;
                  }

                  if (!med.isInterval &&
                      med.durationDays == null &&
                      med.fixedTime != null) {
                    final singleOccurrenceDate = DateTime(
                      med.startTime.year,
                      med.startTime.month,
                      med.startTime.day,
                      med.fixedTime!.hour,
                      med.fixedTime!.minute,
                    );
                    if (now.isAfter(singleOccurrenceDate)) {
                      isExpired = true;
                    }
                  }

                  if (!isExpired) activeCount++;

                  // Calculate Expected Doses up to NOW
                  if (med.startTime.isBefore(now)) {
                    DateTime endCalc = now;
                    if (med.hideAfter != null &&
                        endCalc.isAfter(med.hideAfter!)) {
                      endCalc = med.hideAfter!;
                    }
                    if (med.durationDays != null) {
                      final durationEnd = med.startTime.add(
                        Duration(days: med.durationDays!),
                      );
                      if (endCalc.isAfter(durationEnd)) {
                        endCalc = durationEnd;
                      }
                    }

                    if (med.isInterval &&
                        med.intervalHours != null &&
                        med.intervalHours! > 0) {
                      int hours = endCalc.difference(med.startTime).inHours;
                      if (hours >= 0) {
                        totalExpected +=
                            (hours / med.intervalHours!).floor() + 1;
                      }
                    } else {
                      if (med.durationDays == null && med.fixedTime != null) {
                        totalExpected += 1;
                      } else {
                        int days =
                            DateTime(endCalc.year, endCalc.month, endCalc.day)
                                .difference(
                                  DateTime(
                                    med.startTime.year,
                                    med.startTime.month,
                                    med.startTime.day,
                                  ),
                                )
                                .inDays;
                        if (days >= 0) totalExpected += days + 1;
                      }
                    }
                  }
                }

                int missedDoses = (totalExpected > takenCount)
                    ? (totalExpected - takenCount)
                    : 0;
                double adherenceRate = totalExpected > 0
                    ? (takenCount / totalExpected)
                    : 1.0;
                if (adherenceRate > 1.0) adherenceRate = 1.0;
                int adherencePercent = (adherenceRate * 100).round();

                return SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                image: profile.avatarPath != null
                                    ? DecorationImage(
                                        image: FileImage(
                                          File(profile.avatarPath!),
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: profile.avatarPath == null
                                  ? Center(
                                      child: Text(
                                        profile.name.isNotEmpty
                                            ? profile.name[0].toUpperCase()
                                            : 'U',
                                        style: TextStyle(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                profile.name,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge?.color,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? null
                                  : AppColors.softShadow,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 150,
                                  height: 150,
                                  child: CircularProgressIndicator(
                                    value: adherenceRate,
                                    strokeWidth: 12,
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                    color: adherenceRate >= 0.8
                                        ? Colors.green
                                        : (adherenceRate >= 0.5
                                              ? Colors.orange
                                              : Colors.red),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "$adherencePercent%",
                                      style: TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w900,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                    Text(
                                      AppLocalizations.of(context)!.adherence,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            (Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color ??
                                                    Colors.black)
                                                .withValues(alpha: 0.6),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                adherenceRate >= 0.8
                                    ? Icons.emoji_events_rounded
                                    : (adherenceRate >= 0.5
                                          ? Icons.thumb_up_alt_rounded
                                          : Icons.health_and_safety_rounded),
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  adherenceRate >= 0.8
                                      ? AppLocalizations.of(
                                          context,
                                        )!.excellentAdherence
                                      : (adherenceRate >= 0.5
                                            ? AppLocalizations.of(
                                                context,
                                              )!.goodAdherence
                                            : AppLocalizations.of(
                                                context,
                                              )!.improveAdherence),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSecondaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          AppLocalizations.of(context)!.myPerformance,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.1,
                          children: [
                            _StatCard(
                              title: AppLocalizations.of(context)!.medicines,
                              value: totalMedicines.toString(),
                              icon: Icons.medication_rounded,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            _StatCard(
                              title: AppLocalizations.of(context)!.active,
                              value: activeCount.toString(),
                              icon: Icons.local_pharmacy_rounded,
                              color: Colors.blue,
                            ),
                            _StatCard(
                              title: AppLocalizations.of(context)!.dosesTaken,
                              value: takenCount.toString(),
                              icon: Icons.check_circle_rounded,
                              color: Colors.green,
                            ),
                            _StatCard(
                              title: AppLocalizations.of(context)!.missedDoses,
                              value: missedDoses.toString(),
                              icon: Icons.cancel_rounded,
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Center(
            child: Text(AppLocalizations.of(context)!.selectProfileFirst),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: Theme.of(context).brightness == Brightness.dark
            ? null
            : AppColors.softShadow,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color:
                    (Theme.of(context).textTheme.bodyLarge?.color ??
                            Colors.black)
                        .withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
