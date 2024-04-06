import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:reddit_app/core/common/error_text.dart";
import "package:reddit_app/core/common/loader.dart";
import "package:reddit_app/features/community/controller/community_controller.dart";
import "package:routemaster/routemaster.dart";

class SearchCommDelegeate extends SearchDelegate {
  final WidgetRef ref;
  SearchCommDelegeate(this.ref);
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.close),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    return const SizedBox();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ref.watch(searchCommProvider(query)).when(
        data: (communities) => ListView.builder(
              itemCount: communities.length,
              itemBuilder: (BuildContext context, int index) {
                final comm = communities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(comm.avatar),
                  ),
                  title: Text('r/${comm.name}'),
                  onTap: () {
                    navigateToCommunity(context, comm.name);
                  },
                );
              },
            ),
        error: (error, stackTrace) => ErrorText(
              error: error.toString(),
            ),
        loading: () => const Loader());
  }

  void navigateToCommunity(BuildContext context, String commName) {
    Routemaster.of(context).push('/r/$commName');
  }
}
