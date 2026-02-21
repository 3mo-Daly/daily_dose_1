import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/cubit/home_cubit.dart';
import '../../home/cubit/home_state.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Report'),
      ),
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

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 56,
                                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                backgroundImage: profile.avatarPath != null ? FileImage(File(profile.avatarPath!)) : null,
                                child: profile.avatarPath == null
                                    ? Icon(Icons.person, size: 56, color: Theme.of(context).colorScheme.primary)
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                profile.name,
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        const Text('Summary Statistics', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Total\nMedicines',
                                value: totalMedicines.toString(),
                                icon: Icons.medication,
                                color: Colors.blueAccent,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _StatCard(
                                title: 'Active\nPrescriptions',
                                value: activeCount.toString(),
                                icon: Icons.local_pharmacy,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                title: 'Total Doses\nTaken',
                                value: takenCount.toString(),
                                icon: Icons.check_circle,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const Spacer(), 
                          ],
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
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }
}
