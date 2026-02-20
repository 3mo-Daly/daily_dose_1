import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return SizedBox(
            height: 120, // Increased height to prevent bottom overflow
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.profiles.length + 1, // +1 for Add button
              itemBuilder: (context, index) {
                if (index == state.profiles.length) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            // Implement add profile dialog
                            _showAddProfileDialog(context);
                          },
                          child: const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.add),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Add'),
                      ],
                    ),
                  );
                }

                final profile = state.profiles[index];
                final isSelected = profile.id == state.selectedProfileId;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          context.read<ProfileCubit>().selectProfile(
                            profile.id,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: profile.avatarPath != null
                                ? FileImage(File(profile.avatarPath!))
                                : null,
                            child: profile.avatarPath == null
                                ? Text(
                                    profile.name[0].toUpperCase(),
                                    style: TextStyle(fontSize: 12),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.name,
                        style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showAddProfileDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Profile'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<ProfileCubit>().addProfile(controller.text, null);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
