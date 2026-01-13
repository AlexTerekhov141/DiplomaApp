// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i7;
import 'package:categorize_app/pages/MainPage.dart' as _i1;
import 'package:categorize_app/pages/mainPages/Photos/ChatPage.dart' as _i2;
import 'package:categorize_app/pages/mainPages/Photos/FoldersPage.dart' as _i3;
import 'package:categorize_app/pages/mainPages/Photos/GalleryPage.dart' as _i4;
import 'package:categorize_app/pages/mainPages/Photos/Photo.dart' as _i5;
import 'package:categorize_app/pages/mainPages/ProfilePage.dart' as _i6;
import 'package:flutter/material.dart' as _i8;
import 'package:photo_manager/photo_manager.dart' as _i9;

/// generated route for
/// [_i1.AppPage]
class AppRoute extends _i7.PageRouteInfo<void> {
  const AppRoute({List<_i7.PageRouteInfo>? children})
    : super(AppRoute.name, initialChildren: children);

  static const String name = 'AppRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i1.AppPage();
    },
  );
}

/// generated route for
/// [_i2.ChatPage]
class ChatRoute extends _i7.PageRouteInfo<void> {
  const ChatRoute({List<_i7.PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i2.ChatPage();
    },
  );
}

/// generated route for
/// [_i3.FoldersPage]
class FoldersRoute extends _i7.PageRouteInfo<void> {
  const FoldersRoute({List<_i7.PageRouteInfo>? children})
    : super(FoldersRoute.name, initialChildren: children);

  static const String name = 'FoldersRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i3.FoldersPage();
    },
  );
}

/// generated route for
/// [_i4.GalleryPage]
class GalleryRoute extends _i7.PageRouteInfo<void> {
  const GalleryRoute({List<_i7.PageRouteInfo>? children})
    : super(GalleryRoute.name, initialChildren: children);

  static const String name = 'GalleryRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i4.GalleryPage();
    },
  );
}

/// generated route for
/// [_i5.PhotoViewerPage]
class PhotoViewerRoute extends _i7.PageRouteInfo<PhotoViewerRouteArgs> {
  PhotoViewerRoute({
    _i8.Key? key,
    required _i9.AssetEntity photo,
    List<_i7.PageRouteInfo>? children,
  }) : super(
         PhotoViewerRoute.name,
         args: PhotoViewerRouteArgs(key: key, photo: photo),
         initialChildren: children,
       );

  static const String name = 'PhotoViewerRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PhotoViewerRouteArgs>();
      return _i5.PhotoViewerPage(key: args.key, photo: args.photo);
    },
  );
}

class PhotoViewerRouteArgs {
  const PhotoViewerRouteArgs({this.key, required this.photo});

  final _i8.Key? key;

  final _i9.AssetEntity photo;

  @override
  String toString() {
    return 'PhotoViewerRouteArgs{key: $key, photo: $photo}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PhotoViewerRouteArgs) return false;
    return key == other.key && photo == other.photo;
  }

  @override
  int get hashCode => key.hashCode ^ photo.hashCode;
}

/// generated route for
/// [_i6.ProfilePage]
class ProfileRoute extends _i7.PageRouteInfo<void> {
  const ProfileRoute({List<_i7.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i7.PageInfo page = _i7.PageInfo(
    name,
    builder: (data) {
      return const _i6.ProfilePage();
    },
  );
}
