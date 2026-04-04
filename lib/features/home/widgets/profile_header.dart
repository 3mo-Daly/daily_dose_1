import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../home/cubit/home_cubit.dart';
import '../../profile/cubit/profile_cubit.dart';
import '../../profile/cubit/profile_state.dart';
import '../../../core/theme/app_theme.dart';
import 'package:daily_dose/l10n/app_localizations.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoaded) {
          return SizedBox(
            height: 145, // Increased height to prevent bottom overflow
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: state.profiles.length + 1, // +1 for Add button
              itemBuilder: (context, index) {
                if (index == state.profiles.length) {
                  return const _AddProfileItem();
                }

                final profile = state.profiles[index];
                final isSelected = profile.id == state.selectedProfileId;

                return _ProfileItem(
                  profile: profile,
                  isSelected: isSelected,
                  onSelect: () =>
                      context.read<ProfileCubit>().selectProfile(profile.id),
                  onLongPress: () => _ProfileHeaderActions.showEditDeleteOptions(
                      context, profile),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ProfileHeaderActions {
  static void showAddProfileDialog(BuildContext context) {
    showProfileDialog(context, isEditing: false);
  }

  static void showEditDeleteOptions(
    BuildContext context,
    dynamic profile, 
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
                  AppLocalizations.of(context)!.manageProfile(profile.name),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: Text(AppLocalizations.of(context)!.editProfile),
                onTap: () {
                  Navigator.pop(ctx);
                  _ProfileHeaderActions.showProfileDialog(context, isEditing: true, profile: profile);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _ProfileHeaderActions.confirmDeleteProfile(context, profile);
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  static void confirmDeleteProfile(BuildContext context, dynamic profile) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.deleteProfileTitle),
        content: Text(
          AppLocalizations.of(context)!.deleteProfileContent(profile.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<HomeCubit>().deleteAllMedicines(profile.id);
              context.read<ProfileCubit>().deleteProfile(profile.id);
              Navigator.pop(ctx);
            },
            child: Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void showProfileDialog(BuildContext context, {required bool isEditing, dynamic profile}) {
    final TextEditingController controller = TextEditingController(text: isEditing ? profile.name : '');
    String? pickedImagePath = isEditing ? profile.avatarPath : null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(isEditing ? AppLocalizations.of(context)!.editProfile : AppLocalizations.of(context)!.addProfile),
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
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.name,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.of(context)!.cancel),
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
                  child: Text(isEditing ? AppLocalizations.of(context)!.save : AppLocalizations.of(context)!.add),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _AddProfileItem extends StatelessWidget {
  const _AddProfileItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              _ProfileHeaderActions.showAddProfileDialog(context);
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Icon(Icons.add_rounded,
                  color: Theme.of(context).colorScheme.primary, size: 28),
            ),
          ),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context)!.add,
              style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final dynamic profile;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onLongPress;

  const _ProfileItem({
    required this.profile,
    required this.isSelected,
    required this.onSelect,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
      child: InkWell(
        onTap: onSelect,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: isSelected
              ? BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: Theme.of(context).brightness == Brightness.dark ? null : AppColors.softShadow,
                )
              : const BoxDecoration(color: Colors.transparent),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: profile.avatarPath != null
                          ? DecorationImage(
                              image: FileImage(File(profile.avatarPath!)),
                              fit: BoxFit.cover)
                          : null,
                    ),
                    child: profile.avatarPath == null
                        ? Center(
                            child: Text(
                              profile.name.isNotEmpty
                                  ? profile.name[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        : null,
                  ),
                  Builder(
                    builder: (context) {
                      context.watch<HomeCubit>();
                      final count = context
                          .read<HomeCubit>()
                          .getUncompletedCountForProfile(profile.id);
                      if (count > 0) {
                        return Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  width: 2),
                            ),
                            child: Text(
                              count > 99 ? '99+' : count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                height: 1.0,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  profile.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
