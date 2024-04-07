import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_app/core/providers/storage_repo_providers.dart';
import 'package:reddit_app/core/utils.dart';
import 'package:reddit_app/features/auth/controller/auth_controller.dart';
import 'package:reddit_app/features/post/repository/post_repository.dart';
import 'package:reddit_app/models/community_model.dart';
import 'package:reddit_app/models/post_model.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postrepositoryProvider);
  final storageRepository = ref.watch(fireBaseStorageProvider);
  return PostController(
      postRepository: postRepository, storageRepo: storageRepository, ref: ref);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepo _storageRepo;

  PostController(
      {required PostRepository postRepository,
      required Ref ref,
      required StorageRepo storageRepo})
      : _postRepository = postRepository,
        _ref = ref,
        _storageRepo = storageRepo,
        super(false);

  void shareTextPost({
    required BuildContext context,
    required String title,
    required Community selected,
    required String description,
  }) async {
    state = true;
    String postID = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final Post post = Post(
        id: postID,
        title: title,
        communityName: selected.name,
        communityProfilePic: selected.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'text',
        createdAt: DateTime.now(),
        awards: [],
        description: description);

    final res = await _postRepository.addPost(post);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "Posted Succesfully");
      Routemaster.of(context).pop();
    });
  }

  void shareLinkPost({
    required BuildContext context,
    required String title,
    required Community selected,
    required String link,
  }) async {
    state = true;
    String postID = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final Post post = Post(
        id: postID,
        title: title,
        communityName: selected.name,
        communityProfilePic: selected.avatar,
        upvotes: [],
        downvotes: [],
        commentCount: 0,
        username: user.name,
        uid: user.uid,
        type: 'link',
        createdAt: DateTime.now(),
        awards: [],
        link: link);

    final res = await _postRepository.addPost(post);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "Posted Succesfully");
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost({
    required BuildContext context,
    required String title,
    required Community selected,
    required File? file,
  }) async {
    state = true;
    String postID = const Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageRes = await _storageRepo.storeFile(
      path: 'posts/${selected.name}',
      id: postID,
      file: file,
    );

    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
          id: postID,
          title: title,
          communityName: selected.name,
          communityProfilePic: selected.avatar,
          upvotes: [],
          downvotes: [],
          commentCount: 0,
          username: user.name,
          uid: user.uid,
          type: 'image',
          createdAt: DateTime.now(),
          awards: [],
          link: r);

      final res = await _postRepository.addPost(post);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, "Posted Succesfully");
        Routemaster.of(context).pop();
      });
    });
  }
}
