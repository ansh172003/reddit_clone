import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_app/core/common/error_text.dart';
import 'package:reddit_app/core/common/loader.dart';
import 'package:reddit_app/core/utils.dart';
import 'package:reddit_app/features/community/controller/community_controller.dart';
import 'package:reddit_app/features/post/controller/post_controller.dart';
import 'package:reddit_app/models/community_model.dart';
import 'package:reddit_app/theme/pallete.dart';

class AddPostTypeScreen extends ConsumerStatefulWidget {
  final String type;
  const AddPostTypeScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddPostTypeScreenState();
}

class _AddPostTypeScreenState extends ConsumerState<AddPostTypeScreen> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final linkController = TextEditingController();
  final borderTheme =
      OutlineInputBorder(borderRadius: BorderRadius.circular(10));
  File? bannerFile;
  List<Community> communities = [];
  Community? selected;
  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    descriptionController.dispose();
    linkController.dispose();
  }

  void selectBannerImage() async {
    final res = await pickImage();
    if (res != null) {
      setState(() {
        bannerFile = File(res.files.first.path!);
      });
    }
  }

  void sharePost() async {
    if (widget.type == 'image' &&
        bannerFile != null &&
        titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareImagePost(
            context: context,
            title: titleController.text.trim(),
            selected: selected ?? communities[0],
            file: bannerFile,
          );
    } else if (widget.type == 'text' && titleController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareTextPost(
            context: context,
            description: descriptionController.text.trim(),
            title: titleController.text.trim(),
            selected: selected ?? communities[0],
          );
    } else if (widget.type == 'link' &&
        titleController.text.isNotEmpty &&
        linkController.text.isNotEmpty) {
      ref.read(postControllerProvider.notifier).shareLinkPost(
            context: context,
            link: linkController.text.trim(),
            title: titleController.text.trim(),
            selected: selected ?? communities[0],
          );
    } else {
      showSnackBar(context, 'Please enter all fields');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTypeImage = widget.type == "image";
    final currTheme = ref.watch(themeNotifierProvider);

    final isTypeText = widget.type == "text";
    final isTypeLink = widget.type == "link";
    return Scaffold(
      appBar: AppBar(
        title: Text("Post ${widget.type}"),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: sharePost,
            child: const Text("Share"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              maxLength: 30,
              decoration: InputDecoration(
                focusedBorder: borderTheme,
                enabledBorder: borderTheme,
                errorBorder: borderTheme,
                disabledBorder: borderTheme,
                focusedErrorBorder: borderTheme,
                filled: true,
                hintText: "Enter Title here",
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(18),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            if (isTypeImage)
              GestureDetector(
                onTap: selectBannerImage,
                child: DottedBorder(
                  radius: const Radius.circular(15),
                  dashPattern: const [10, 4],
                  borderType: BorderType.RRect,
                  strokeCap: StrokeCap.round,
                  color: currTheme.textTheme.bodyMedium!.color!,
                  strokeWidth: 1.4,
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(16)),
                    child: bannerFile != null
                        ? Image.file(bannerFile!)
                        : const Center(
                            child: Icon(
                              Icons.camera_alt_outlined,
                              size: 40,
                            ),
                          ),
                  ),
                ),
              ),
            if (isTypeText)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: TextField(
                  maxLines: 5,
                  controller: descriptionController,
                  decoration: InputDecoration(
                    focusedBorder: borderTheme,
                    enabledBorder: borderTheme,
                    errorBorder: borderTheme,
                    disabledBorder: borderTheme,
                    focusedErrorBorder: borderTheme,
                    filled: true,
                    hintText: "Enter Description here",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(18),
                  ),
                ),
              ),
            if (isTypeLink)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: TextField(
                  controller: linkController,
                  decoration: InputDecoration(
                    focusedBorder: borderTheme,
                    enabledBorder: borderTheme,
                    errorBorder: borderTheme,
                    disabledBorder: borderTheme,
                    focusedErrorBorder: borderTheme,
                    filled: true,
                    hintText: "Enter Description here",
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(18),
                  ),
                ),
              ),
            const SizedBox(
              height: 20,
            ),
            const Align(
              alignment: Alignment.topLeft,
              child: Text("Select Community"),
            ),
            ref.watch(userCommunitiesProvider).when(
                  data: (data) {
                    communities = data;
                    if (data.isEmpty) return const SizedBox();

                    return DropdownButton(
                        borderRadius: BorderRadius.circular(15),
                        value: selected ?? data[0],
                        items: data
                            .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e.name)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selected = val;
                          });
                        });
                  },
                  error: (error, stackFrame) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                )
          ],
        ),
      ),
    );
  }
}
