// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i14;
import 'package:categorize_app/models/Folders/Folder.dart' as _i16;
import 'package:categorize_app/pages/loginAndRegisterPages/EditPage.dart'
    as _i4;
import 'package:categorize_app/pages/loginAndRegisterPages/LoginPage.dart'
    as _i8;
import 'package:categorize_app/pages/loginAndRegisterPages/RegisterPage.dart'
    as _i11;
import 'package:categorize_app/pages/MainPage.dart' as _i2;
import 'package:categorize_app/pages/mainPages/ChatPage.dart' as _i3;
import 'package:categorize_app/pages/mainPages/Photos/FolderDetailPage.dart'
    as _i5;
import 'package:categorize_app/pages/mainPages/Photos/FoldersPage.dart' as _i6;
import 'package:categorize_app/pages/mainPages/Photos/GalleryPage.dart' as _i7;
import 'package:categorize_app/pages/mainPages/Photos/Photo.dart' as _i9;
import 'package:categorize_app/pages/mainPages/ProfilePages/AboutPage.dart'
    as _i1;
import 'package:categorize_app/pages/mainPages/ProfilePages/ProfilePage.dart'
    as _i10;
import 'package:categorize_app/pages/mainPages/ProfilePages/SettingsPage.dart'
    as _i12;
import 'package:categorize_app/pages/mainPages/ProfilePages/SupportPage.dart'
    as _i13;
import 'package:flutter/material.dart' as _i15;
import 'package:photo_manager/photo_manager.dart' as _i17;

/// generated route for
/// [_i1.AboutPage]
class AboutRoute extends _i14.PageRouteInfo<void> {
  const AboutRoute({List<_i14.PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i1.AboutPage();
    },
  );
}

/// generated route for
/// [_i2.AppPage]
class AppRoute extends _i14.PageRouteInfo<void> {
  const AppRoute({List<_i14.PageRouteInfo>? children})
    : super(AppRoute.name, initialChildren: children);

  static const String name = 'AppRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i2.AppPage();
    },
  );
}

/// generated route for
/// [_i3.ChatPage]
class ChatRoute extends _i14.PageRouteInfo<void> {
  const ChatRoute({List<_i14.PageRouteInfo>? children})
    : super(ChatRoute.name, initialChildren: children);

  static const String name = 'ChatRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i3.ChatPage();
    },
  );
}

/// generated route for
/// [_i4.EditPage]
class EditRoute extends _i14.PageRouteInfo<EditRouteArgs> {
  EditRoute({_i15.Key? key, List<_i14.PageRouteInfo>? children})
    : super(
        EditRoute.name,
        args: EditRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'EditRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditRouteArgs>(
        orElse: () => const EditRouteArgs(),
      );
      return _i4.EditPage(key: args.key);
    },
  );
}

class EditRouteArgs {
  const EditRouteArgs({this.key});

  final _i15.Key? key;

  @override
  String toString() {
    return 'EditRouteArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EditRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i5.FolderDetailsPage]
class FolderDetailsRoute extends _i14.PageRouteInfo<FolderDetailsRouteArgs> {
  FolderDetailsRoute({
    _i15.Key? key,
    required _i16.Folder folder,
    List<_i14.PageRouteInfo>? children,
  }) : super(
         FolderDetailsRoute.name,
         args: FolderDetailsRouteArgs(key: key, folder: folder),
         initialChildren: children,
       );

  static const String name = 'FolderDetailsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FolderDetailsRouteArgs>();
      return _i5.FolderDetailsPage(key: args.key, folder: args.folder);
    },
  );
}

class FolderDetailsRouteArgs {
  const FolderDetailsRouteArgs({this.key, required this.folder});

  final _i15.Key? key;

  final _i16.Folder folder;

  @override
  String toString() {
    return 'FolderDetailsRouteArgs{key: $key, folder: $folder}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FolderDetailsRouteArgs) return false;
    return key == other.key && folder == other.folder;
  }

  @override
  int get hashCode => key.hashCode ^ folder.hashCode;
}

/// generated route for
/// [_i6.FoldersPage]
class FoldersRoute extends _i14.PageRouteInfo<void> {
  const FoldersRoute({List<_i14.PageRouteInfo>? children})
    : super(FoldersRoute.name, initialChildren: children);

  static const String name = 'FoldersRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i6.FoldersPage();
    },
  );
}

/// generated route for
/// [_i7.GalleryPage]
class GalleryRoute extends _i14.PageRouteInfo<void> {
  const GalleryRoute({List<_i14.PageRouteInfo>? children})
    : super(GalleryRoute.name, initialChildren: children);

  static const String name = 'GalleryRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i7.GalleryPage();
    },
  );
}

/// generated route for
/// [_i8.LoginPage]
class LoginRoute extends _i14.PageRouteInfo<LoginRouteArgs> {
  LoginRoute({_i15.Key? key, List<_i14.PageRouteInfo>? children})
    : super(
        LoginRoute.name,
        args: LoginRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'LoginRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return _i8.LoginPage(key: args.key);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key});

  final _i15.Key? key;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
}

/// generated route for
/// [_i9.PhotoViewerPage]
class PhotoViewerRoute extends _i14.PageRouteInfo<PhotoViewerRouteArgs> {
  PhotoViewerRoute({
    _i15.Key? key,
    required _i17.AssetEntity photo,
    List<_i14.PageRouteInfo>? children,
  }) : super(
         PhotoViewerRoute.name,
         args: PhotoViewerRouteArgs(key: key, photo: photo),
         initialChildren: children,
       );

  static const String name = 'PhotoViewerRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PhotoViewerRouteArgs>();
      return _i9.PhotoViewerPage(key: args.key, photo: args.photo);
    },
  );
}

class PhotoViewerRouteArgs {
  const PhotoViewerRouteArgs({this.key, required this.photo});

  final _i15.Key? key;

  final _i17.AssetEntity photo;

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
/// [_i10.ProfilePage]
class ProfileRoute extends _i14.PageRouteInfo<void> {
  const ProfileRoute({List<_i14.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i10.ProfilePage();
    },
  );
}

/// generated route for
/// [_i11.RegisterPage]
class RegisterRoute extends _i14.PageRouteInfo<void> {
  const RegisterRoute({List<_i14.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i11.RegisterPage();
    },
  );
}

/// generated route for
/// [_i12.SettingsPage]
class SettingsRoute extends _i14.PageRouteInfo<void> {
  const SettingsRoute({List<_i14.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i12.SettingsPage();
    },
  );
}

/// generated route for
/// [_i13.SupportPage]
class SupportRoute extends _i14.PageRouteInfo<void> {
  const SupportRoute({List<_i14.PageRouteInfo>? children})
    : super(SupportRoute.name, initialChildren: children);

  static const String name = 'SupportRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i13.SupportPage();
    },
  );
}
