import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_app/core/providers/storage_repo_providers.dart';
import 'package:reddit_app/core/utils.dart';
import 'package:reddit_app/features/auth/controller/auth_controller.dart';
import 'package:reddit_app/features/user_profile/repository/user_profile_repo.dart';
import 'package:reddit_app/models/user_model.dart';
import 'package:routemaster/routemaster.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userRepository = ref.watch(userProfileRepository);
  final storageRepository = ref.watch(fireBaseStorageProvider);
  return UserProfileController(
      userProfileRepository: userRepository,
      storageRepo: storageRepository,
      ref: ref);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepo _storageRepo;

  UserProfileController(
      {required UserProfileRepository userProfileRepository,
      required Ref ref,
      required StorageRepo storageRepo})
      : _userProfileRepository = userProfileRepository,
        _ref = ref,
        _storageRepo = storageRepo,
        super(false);

  void editUserProfile(
      {required File? profileFile,
      required File? bannerFile,
      required BuildContext context,
      required String name}) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    if (profileFile != null) {
      final res = await _storageRepo.storeFile(
          path: 'users/profile', id: user.uid, file: profileFile);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(profilePic: r),
      );
    }
    if (bannerFile != null) {
      final res = await _storageRepo.storeFile(
          path: 'users/banner', id: user.uid, file: bannerFile);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => user = user.copyWith(bannerPic: r),
      );
    }
    user = user.copyWith(name: name);
    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        _ref.read(userProvider.notifier).update((state) => user);
        Routemaster.of(context).pop();
      },
    );
  }
}
