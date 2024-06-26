import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_app/core/common/error_text.dart';
import 'package:reddit_app/core/common/loader.dart';
import 'package:reddit_app/features/community/controller/community_controller.dart';
import 'package:reddit_app/models/community_model.dart';
import 'package:routemaster/routemaster.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunity(BuildContext context, Community comm) {
    Routemaster.of(context).push('/r/${comm.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              title: const Text("Create Community"),
              leading: const Icon(Icons.add),
              onTap: () => navigateToCreateCommunity(context),
            ),
            const SizedBox(
              height: 10,
            ),
            ref.watch(userCommunitiesProvider).when(
                data: (communities) => Expanded(
                      child: ListView.builder(
                          itemCount: communities.length,
                          itemBuilder: (context, index) {
                            final community = communities[index];
                            return ListTile(
                              leading: CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(community.avatar)),
                              title: Text('r/${community.name}'),
                              onTap: () {
                                navigateToCommunity(context, community);
                              },
                            );
                          }),
                    ),
                error: ((error, stackTrace) =>
                    ErrorText(error: error.toString())),
                loading: () => const Loader())
          ],
        ),
      ),
    );
  }
}
