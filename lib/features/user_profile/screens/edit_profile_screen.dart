import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reddit_app/core/common/error_text.dart';
import 'package:reddit_app/core/common/loader.dart';
import 'package:reddit_app/core/constants/constants.dart';
import 'package:reddit_app/core/utils.dart';
import 'package:reddit_app/features/auth/controller/auth_controller.dart';
import 'package:reddit_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:reddit_app/theme/pallete.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String uid;
  const EditProfileScreen({
    super.key,
    required this.uid,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? bannerFile;
  File? avatarFile;
  late TextEditingController nameController;

  @override
  void initState() {
    nameController = TextEditingController(text: ref.read(userProvider)!.name);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void selectAvatarImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        avatarFile = File(res.files.first.path!);
      });
    }
  }

  void save() {
    ref.read(userProfileControllerProvider.notifier).editUserProfile(
          profileFile: avatarFile,
          bannerFile: bannerFile,
          context: context,
          name: nameController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(userProfileControllerProvider);
    return ref.watch(getUserDataProvider(widget.uid)).when(
          data: (user) => Scaffold(
            backgroundColor: Pallete.darkModeAppTheme.colorScheme.background,
            appBar: AppBar(
              title: const Text("Edit User"),
              actions: [
                TextButton(
                  onPressed: save,
                  child: const Text("Save"),
                ),
              ],
            ),
            body: isLoading
                ? const Loader()
                : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 200,
                          child: Stack(
                            children: [
                              GestureDetector(
                                onTap: selectBannerImage,
                                child: DottedBorder(
                                  radius: const Radius.circular(15),
                                  dashPattern: const [10, 4],
                                  borderType: BorderType.RRect,
                                  strokeCap: StrokeCap.round,
                                  color: Pallete.darkModeAppTheme.textTheme
                                      .bodyMedium!.color!,
                                  strokeWidth: 1.4,
                                  child: Container(
                                    width: double.infinity,
                                    height: 150,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    child: bannerFile != null
                                        ? Image.file(bannerFile!)
                                        : user.bannerPic ==
                                                    Constant.bannerDefault ||
                                                user.bannerPic.isEmpty
                                            ? const Center(
                                                child: Icon(
                                                    Icons.camera_alt_outlined,
                                                    size: 40))
                                            : Image.network(user.bannerPic),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 25,
                                child: GestureDetector(
                                  onTap: selectAvatarImage,
                                  child: avatarFile != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              FileImage(avatarFile!),
                                          radius: 32)
                                      : CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(user.profilePic),
                                          radius: 32),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextField(
                          controller: nameController,
                          decoration: InputDecoration(
                            filled: true,
                            hintText: "Name",
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.all(18),
                          ),
                        )
                      ],
                    ),
                  ),
          ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
