import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../home/cubit/home_cubit.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import '../../../core/theme/app_theme.dart';

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
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            // Implement add profile dialog
                            _showAddProfileDialog(context);
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withOpacity(0.10),
                            ),
                            child: const Icon(Icons.add_rounded, color: AppColors.primary, size: 28),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('Add', style: TextStyle(color: AppColors.text.withOpacity(0.7), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  );
                }

                final profile = state.profiles[index];
                final isSelected = profile.id == state.selectedProfileId;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          context.read<ProfileCubit>().selectProfile(
                            profile.id,
                          );
                        },
                        onLongPress: () {
                          _showEditDeleteOptions(context, profile);
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              width: 3,
                            ),
                            image: profile.avatarPath != null ? DecorationImage(image: FileImage(File(profile.avatarPath!)), fit: BoxFit.cover) : null,
                          ),
                          child: profile.avatarPath == null
                            ? Center(
                                child: Text(
                                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                                  style: const TextStyle(fontSize: 20, color: AppColors.primary, fontWeight: FontWeight.bold),
                                ),
                              )
                            : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.name,
                        style: TextStyle(
                          color: AppColors.text,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
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
    _showProfileDialog(context, isEditing: false);
  }

  void _showEditDeleteOptions(
    BuildContext context,
    dynamic profile, // Using dynamic to avoid importing profile explicitly here if it's already in scope, or just referencing the model
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Manage Profile: ${profile.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showProfileDialog(context, isEditing: true, profile: profile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Profile', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteProfile(context, profile);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteProfile(BuildContext context, dynamic profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Profile?'),
        content: Text(
          'Are you sure you want to delete ${profile.name}? All medicines associated with this profile will be permanently wiped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<HomeCubit>().deleteAllMedicines(profile.id);
              context.read<ProfileCubit>().deleteProfile(profile.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context, {required bool isEditing, dynamic profile}) {
    final TextEditingController controller = TextEditingController(text: isEditing ? profile.name : '');
    String? pickedImagePath = isEditing ? profile.avatarPath : null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Profile' : 'Add Profile'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        setState(() {
                          pickedImagePath = pickedFile.path;
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      backgroundImage: pickedImagePath != null ? FileImage(File(pickedImagePath!)) : null,
                      child: pickedImagePath == null
                          ? const Icon(Icons.add_a_photo, size: 30)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.text.isNotEmpty) {
                      if (isEditing) {
                        context.read<ProfileCubit>().updateProfile(profile.id, controller.text, pickedImagePath);
                      } else {
                        context.read<ProfileCubit>().addProfile(controller.text, pickedImagePath);
                      }
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
