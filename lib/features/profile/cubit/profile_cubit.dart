import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../../models/profile_model.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final Box<Profile> profileBox;

  ProfileCubit({required this.profileBox}) : super(ProfileInitial());

  void loadProfiles() {
    emit(ProfileLoading());
    try {
      final profiles = profileBox.values.toList();
      // Default to the first profile if none selected, or keep selection logic elsewhere
      // For now, let's just emit loaded.
      // If no profiles, maybe we should create a default "Me" profile?
      if (profiles.isEmpty) {
        addProfile('Me', null); // This will emit loaded within addProfile
      } else {
         emit(ProfileLoaded(profiles: profiles, selectedProfileId: profiles.first.id));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> addProfile(String name, String? avatarPath) async {
    try {
      final id = const Uuid().v4();
      final newProfile = Profile(id: id, name: name, avatarPath: avatarPath);
      await profileBox.put(id, newProfile);
      final profiles = profileBox.values.toList();
      emit(ProfileLoaded(profiles: profiles, selectedProfileId: id));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
  
  void selectProfile(String profileId) {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(ProfileLoaded(profiles: currentState.profiles, selectedProfileId: profileId));
    }
  }
}
