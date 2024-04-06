import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_app/core/constants/constants.dart';
import 'package:reddit_app/core/failures.dart';
import 'package:reddit_app/core/providers/storage_repo_providers.dart';
import 'package:reddit_app/core/utils.dart';
import 'package:reddit_app/features/auth/controller/auth_controller.dart';
import 'package:reddit_app/features/community/repository/community_repository.dart';
import 'package:reddit_app/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityRepository = ref.watch(communityRepositoryProvider);
  final storageRepository = ref.watch(fireBaseStorageProvider);
  return CommunityController(
      communityRepository: communityRepository,
      storageRepo: storageRepository,
      ref: ref);
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref
      .watch(communityControllerProvider.notifier)
      .getCommunityByName(name);
});

final searchCommProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityRepository _communityRepository;
  final Ref _ref;
  final StorageRepo _storageRepo;

  CommunityController(
      {required CommunityRepository communityRepository,
      required Ref ref,
      required StorageRepo storageRepo})
      : _communityRepository = communityRepository,
        _ref = ref,
        _storageRepo = storageRepo,
        super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    Community community = Community(
      id: name,
      name: name,
      banner: Constant.bannerDefault,
      avatar: Constant.avatarDefault,
      members: [uid],
      mods: [uid],
    );
    final res = await _communityRepository.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "Community Created!");
      Routemaster.of(context).pop();
    });
  }

  void joinCommunity(Community community, BuildContext context) async {
    final user = _ref.read(userProvider)!.uid;

    Either<Failure, void> res;

    if (community.members.contains(user)) {
      res = await _communityRepository.leaveCommunity(community.name, user);
    } else {
      res = await _communityRepository.joinCommunity(community.name, user);
    }
    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (community.members.contains(user)) {
        showSnackBar(context, "Community left successfully!");
      } else {
        showSnackBar(context, "Community joined successfully!");
      }
    });
  }

  Stream<List<Community>> getUserCommunities() {
    final uid = _ref.read(userProvider)!.uid;
    return _communityRepository.getUserCommunities(uid);
  }

  Stream<Community> getCommunityByName(String name) {
    return _communityRepository.getCommunityByName(name);
  }

  void editCommunity(
      {required File? avatarPic,
      required File? bannerPic,
      required BuildContext context,
      required Community community}) async {
    state = true;
    if (avatarPic != null) {
      final res = await _storageRepo.storeFile(
          path: 'communities/profile', id: community.name, file: avatarPic);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(avatar: r),
      );
    }
    if (bannerPic != null) {
      final res = await _storageRepo.storeFile(
          path: 'communities/banner', id: community.name, file: bannerPic);
      res.fold(
        (l) => showSnackBar(context, l.message),
        (r) => community = community.copyWith(banner: r),
      );
    }
    final res = await _communityRepository.editCommunity(community);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityRepository.searchComm(query);
  }

  void editMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityRepository.editMods(communityName, uids);
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) => Routemaster.of(context).pop(),
    );
  }
}
