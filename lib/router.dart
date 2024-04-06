import 'package:flutter/material.dart';
import 'package:reddit_app/features/auth/screens/login_screen.dart';
import 'package:reddit_app/features/community/screens/community_edit_screen.dart';
import 'package:reddit_app/features/community/screens/community_mod_screen.dart';
import 'package:reddit_app/features/community/screens/community_mod_tools_screen.dart';
import 'package:reddit_app/features/community/screens/community_profile_screen.dart';
import 'package:reddit_app/features/community/screens/community_create_screen.dart';
import 'package:reddit_app/features/home/screens/home_screen.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(
  routes: {'/': (_) => const MaterialPage(child: LoginScreen())},
);

final loggedInRoute = RouteMap(
  routes: {
    '/': (_) => const MaterialPage(child: HomeScreen()),
    '/mod-tools/:name': (route) => MaterialPage(
            child: ModToolsScreen(
          name: route.pathParameters['name']!,
        )),
    '/edit-community/:name': (route) => MaterialPage(
            child: EditCommunityScreen(
          name: route.pathParameters['name']!,
        )),
    '/add-mods/:name': (route) => MaterialPage(
            child: AddModsScreen(
          name: route.pathParameters['name']!,
        )),
    '/create-community': (_) =>
        const MaterialPage(child: CreateCommunityScreen()),
    '/r/:name': (route) => MaterialPage(
            child: CommunityScreen(
          name: route.pathParameters['name']!,
        )),
  },
);
