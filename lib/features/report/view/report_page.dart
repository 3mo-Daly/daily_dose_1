import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/cubit/home_cubit.dart';
import '../../home/cubit/home_state.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import '../../../core/theme/app_theme.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          if (profileState is ProfileLoaded && profileState.selectedProfileId != null) {
            return BlocBuilder<HomeCubit, HomeState>(
              builder: (context, homeState) {
                final profileId = profileState.selectedProfileId!;
                final profile = profileState.profiles.firstWhere((p) => p.id == profileId);
                
                // Read from the HomeCubit's central box for stats inside the builder so it rebuilds
                final homeCubit = context.read<HomeCubit>();
                final allMedicinesInBox = homeCubit.medicineBox.values.where((m) => m.profileId == profileId).toList();
                
                final totalMedicines = allMedicinesInBox.length;
                int takenCount = 0;
                int activeCount = 0;
                
                final now = DateTime.now();

                for (var med in allMedicinesInBox) {
                   takenCount += med.history.length;
                   
                   bool isExpired = false;
                   if (med.durationDays != null) {
                       final end = med.startTime.add(Duration(days: med.durationDays!));
                       if (now.isAfter(end)) isExpired = true;
                   }
                   if (med.hideAfter != null && now.isAfter(med.hideAfter!)) {
                       isExpired = true;
                   }
                   
                   // New generic fix: If it's not an interval medicine and it has NO duration days,
                   // it means it's a single time dosage. Once that single time is in the past, it's inactive.
                   if (!med.isInterval && med.durationDays == null && med.fixedTime != null) {
                      final singleOccurrenceDate = DateTime(
                         med.startTime.year, med.startTime.month, med.startTime.day,
                         med.fixedTime!.hour, med.fixedTime!.minute,
                      );
                      if (now.isAfter(singleOccurrenceDate)) {
                          isExpired = true;
                      }
                   }
                   
                   if (!isExpired) activeCount++;
                }

                return SafeArea(
                  child: Padding(
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
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                image: profile.avatarPath != null ? DecorationImage(image: FileImage(File(profile.avatarPath!)), fit: BoxFit.cover) : null,
                              ),
                              child: profile.avatarPath == null 
                                ? Center(child: Text(profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16)))
                                : null,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              profile.name,
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          "My Performance",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).textTheme.bodyLarge?.color),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.1,
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _StatCard(title: 'Medicines', value: totalMedicines.toString(), icon: Icons.medication_rounded, color: Theme.of(context).colorScheme.primary),
                              _StatCard(title: 'Active', value: activeCount.toString(), icon: Icons.local_pharmacy_rounded, color: const Color(0xFFE57373)),
                              _StatCard(title: 'Doses Taken', value: takenCount.toString(), icon: Icons.check_circle_rounded, color: const Color(0xFFFFB74D)),
                              _StatCard(title: 'Adherence', value: 'N/A', icon: Icons.pie_chart_rounded, color: Theme.of(context).colorScheme.secondary),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text('Select a profile first'));
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

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: Theme.of(context).brightness == Brightness.dark ? null : AppColors.softShadow,
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
                color: (Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black).withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
