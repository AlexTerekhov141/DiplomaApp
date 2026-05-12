import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../Routes/routes.gr.dart';
import '../../../../../Widgets/ResponsiveFrame.dart';
import '../../../../../bloc/PhotoRoastBloc/bloc.dart';
import '../../../../../bloc/PhotoRoastBloc/event.dart';
import '../../../../../bloc/PhotoRoastBloc/state.dart';
import '../../../../../models/Photo.dart';
import '../../../../../models/PhotoRoastModels/QualityPhotoGroup.dart';

class PhotoRoastView extends StatelessWidget {
  const PhotoRoastView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI quality groups'),
      ),
      body: ResponsiveFrame(
        maxWidth: 1200,
        child: BlocConsumer<PhotoRoastBloc, PhotoRoastState>(
          listenWhen: (PhotoRoastState prev, PhotoRoastState curr) =>
          prev.error != curr.error && curr.error != null,
          listener: (BuildContext context, PhotoRoastState state) {
            final String message = state.error ?? 'Unknown error';
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
            context.read<PhotoRoastBloc>().add(const PhotoRoastErrorCleared());
          },
          builder: (BuildContext context, PhotoRoastState state) {
            if (state.isLoading && state.groups.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PhotoRoastBloc>().add(
                  const PhotoRoastQualityGroupsRequested(),
                );
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: <Widget>[
                  for (final QualityPhotoGroup group in state.groups)
                    _QualityGroupSection(group: group),
                  if (state.groups.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 120),
                      child: Center(
                        child: Text('No processed photos found'),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _QualityGroupSection extends StatelessWidget {
  const _QualityGroupSection({
    required this.group,
  });

  final QualityPhotoGroup group;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {context.router.push(PhotoRoastDetailsRoute(group: group));},
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      group.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Text('${group.photos.length}'),
                ],
              ),
              const SizedBox(height: 4),
              Text(group.description),
              const SizedBox(height: 12),
              if (group.photos.isEmpty)
                const SizedBox(
                  height: 96,
                  child: Center(child: Text('No photos')),
                )
              else
                SizedBox(
                  height: 140,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: group.photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (BuildContext context, int index) {
                      return _QualityPhotoTile(photo: group.photos[index]);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QualityPhotoTile extends StatelessWidget {
  const _QualityPhotoTile({
    required this.photo,
  });

  final Photo photo;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 110,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: photo.image,
              cacheKey: 'quality_photo_${photo.id}',
              fit: BoxFit.cover,
              placeholder: (_, __) => const ColoredBox(
                color: Colors.black12,
              ),
              errorWidget: (_, __, ___) => const ColoredBox(
                color: Colors.black12,
                child: Icon(Icons.broken_image_outlined),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color(0x00000000),
                      Color(0xB3000000),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    '${(photo.qualityScore * 100).round()}/100',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
