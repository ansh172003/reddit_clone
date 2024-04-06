import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_app/features/auth/controller/auth_controller.dart';
import 'package:reddit_app/theme/pallete.dart';
import 'package:routemaster/routemaster.dart';

class ProfileDrawer extends ConsumerWidget {
  const ProfileDrawer({super.key});

  void logOut(WidgetRef ref) {
    ref.read(authControllerProvider.notifier).logOut();
  }

  void navigateToUserProfile(BuildContext context, String uid) {
    Routemaster.of(context).push('u/$uid');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(user.profilePic),
              radius: 70,
            ),
          ),
          Text(
            'u/${user.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: 10,
          ),
          const Divider(),
          ListTile(
            title: const Text("My Profile"),
            leading: const Icon(Icons.person),
            onTap: () => navigateToUserProfile(context, user.uid),
          ),
          ListTile(
            title: const Text("Logout"),
            leading: Icon(
              Icons.logout,
              color: Pallete.redColor,
            ),
            onTap: () {
              logOut(ref);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.light_mode,
                size: 24,
                color: Color.fromARGB(255, 51, 51, 51),
              ),
              const SizedBox(width: 10),
              Switch.adaptive(
                value: true,
                onChanged: (val) {},
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.dark_mode,
                size: 24,
                color: Color.fromARGB(255, 213, 213, 213),
              )
            ],
          )
        ],
      )),
    );
  }
}
