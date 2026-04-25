import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../../repository/ProccessingRouterRepository/ProccessingRouterRepository.dart';

class FoldersActionButtons extends StatelessWidget {
  const FoldersActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.router.push(const FavouriteRoute());
            },
            icon: const Icon(Icons.favorite_border),
            label: const Text('Fav'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.router.push(const TrashRoute());
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Trash'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              final bool isOfflineMode =
                  await GetIt.I<ProccessingRouterRepository>().isOfflineMode();
              if (!context.mounted) {
                return;
              }
              if (!isOfflineMode) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Local processing is available offline'),
                  ),
                );
                return;
              }
              context.router.replaceAll(<PageRouteInfo>[
                const OfflineCategorizationRoute(),
              ]);
            },
            icon: const Icon(Icons.offline_bolt_outlined),
            label: const Text('Proc'),
          ),
        ),
      ],
    );
  }
}
