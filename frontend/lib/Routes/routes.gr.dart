// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i17;
import 'package:categorize_app/models/Folders/Folder.dart' as _i19;
import 'package:categorize_app/pages/loginAndRegisterPages/EditPage.dart'
    as _i3;
import 'package:categorize_app/pages/loginAndRegisterPages/LoginPage.dart'
    as _i9;
import 'package:categorize_app/pages/loginAndRegisterPages/RegisterPage.dart'
    as _i13;
import 'package:categorize_app/pages/MainPage.dart' as _i2;
import 'package:categorize_app/pages/mainPages/FeaturePage/Chat/ChatPage.dart'
    as _i5;
import 'package:categorize_app/pages/mainPages/FeaturePage/Enchance/EnchancePage.dart'
    as _i4;
import 'package:categorize_app/pages/mainPages/FeaturePage/PhotoRoast/PhotoRoastPage.dart'
    as _i10;
import 'package:categorize_app/pages/mainPages/Photos/FolderDetail/FolderDetailPage.dart'
    as _i6;
import 'package:categorize_app/pages/mainPages/Photos/Folders/FoldersPage.dart'
    as _i7;
import 'package:categorize_app/pages/mainPages/Photos/Gallery/GalleryPage.dart'
    as _i8;
import 'package:categorize_app/pages/mainPages/Photos/Photo/Photo.dart' as _i11;
import 'package:categorize_app/pages/mainPages/ProfilePages/About/AboutPage.dart'
    as _i1;
import 'package:categorize_app/pages/mainPages/ProfilePages/Profile/ProfilePage.dart'
    as _i12;
import 'package:categorize_app/pages/mainPages/ProfilePages/Settings/SettingsPage.dart'
    as _i14;
import 'package:categorize_app/pages/mainPages/ProfilePages/Support/SupportPage.dart'
    as _i16;
import 'package:categorize_app/pages/spash/splash_screen.dart' as _i15;
import 'package:flutter/material.dart' as _i18;
import 'package:photo_manager/photo_manager.dart' as _i20;

/// generated route for
/// [_i1.AboutPage]
class AboutRoute extends _i17.PageRouteInfo<void> {
  const AboutRoute({List<_i17.PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i1.AboutPage();
    },
  );
}

/// generated route for
/// [_i2.AppPage]
class AppRoute extends _i17.PageRouteInfo<void> {
  const AppRoute({List<_i17.PageRouteInfo>? children})
    : super(AppRoute.name, initialChildren: children);

  static const String name = 'AppRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i2.AppPage();
    },
  );
}

/// generated route for
/// [_i3.EditPage]
class EditRoute extends _i17.PageRouteInfo<EditRouteArgs> {
  EditRoute({_i18.Key? key, List<_i17.PageRouteInfo>? children})
    : super(
        EditRoute.name,
        args: EditRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'EditRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<EditRouteArgs>(
        orElse: () => const EditRouteArgs(),
      );
      return _i3.EditPage(key: args.key);
    },
  );
}

class EditRouteArgs {
  const EditRouteArgs({this.key});

  final _i18.Key? key;

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
/// [_i4.EnhancePage]
class EnhanceRoute extends _i17.PageRouteInfo<void> {
  const EnhanceRoute({List<_i17.PageRouteInfo>? children})
    : super(EnhanceRoute.name, initialChildren: children);

  static const String name = 'EnhanceRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i4.EnhancePage();
    },
  );
}

/// generated route for
/// [_i5.FeatureHubPage]
class FeatureHubRoute extends _i17.PageRouteInfo<void> {
  const FeatureHubRoute({List<_i17.PageRouteInfo>? children})
    : super(FeatureHubRoute.name, initialChildren: children);

  static const String name = 'FeatureHubRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i5.FeatureHubPage();
    },
  );
}

/// generated route for
/// [_i6.FolderDetailsPage]
class FolderDetailsRoute extends _i17.PageRouteInfo<FolderDetailsRouteArgs> {
  FolderDetailsRoute({
    _i18.Key? key,
    required _i19.Folder folder,
    List<_i17.PageRouteInfo>? children,
  }) : super(
         FolderDetailsRoute.name,
         args: FolderDetailsRouteArgs(key: key, folder: folder),
         initialChildren: children,
       );

  static const String name = 'FolderDetailsRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FolderDetailsRouteArgs>();
      return _i6.FolderDetailsPage(key: args.key, folder: args.folder);
    },
  );
}

class FolderDetailsRouteArgs {
  const FolderDetailsRouteArgs({this.key, required this.folder});

  final _i18.Key? key;

  final _i19.Folder folder;

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
/// [_i7.FoldersPage]
class FoldersRoute extends _i17.PageRouteInfo<void> {
  const FoldersRoute({List<_i17.PageRouteInfo>? children})
    : super(FoldersRoute.name, initialChildren: children);

  static const String name = 'FoldersRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i7.FoldersPage();
    },
  );
}

/// generated route for
/// [_i8.GalleryPage]
class GalleryRoute extends _i17.PageRouteInfo<void> {
  const GalleryRoute({List<_i17.PageRouteInfo>? children})
    : super(GalleryRoute.name, initialChildren: children);

  static const String name = 'GalleryRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i8.GalleryPage();
    },
  );
}

/// generated route for
/// [_i9.LoginPage]
class LoginRoute extends _i17.PageRouteInfo<void> {
  const LoginRoute({List<_i17.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i9.LoginPage();
    },
  );
}

/// generated route for
/// [_i10.PhotoRoastPage]
class PhotoRoastRoute extends _i17.PageRouteInfo<void> {
  const PhotoRoastRoute({List<_i17.PageRouteInfo>? children})
    : super(PhotoRoastRoute.name, initialChildren: children);

  static const String name = 'PhotoRoastRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i10.PhotoRoastPage();
    },
  );
}

/// generated route for
/// [_i11.PhotoViewerPage]
class PhotoViewerRoute extends _i17.PageRouteInfo<PhotoViewerRouteArgs> {
  PhotoViewerRoute({
    _i18.Key? key,
    required _i20.AssetEntity photo,
    List<_i17.PageRouteInfo>? children,
  }) : super(
         PhotoViewerRoute.name,
         args: PhotoViewerRouteArgs(key: key, photo: photo),
         initialChildren: children,
       );

  static const String name = 'PhotoViewerRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PhotoViewerRouteArgs>();
      return _i11.PhotoViewerPage(key: args.key, photo: args.photo);
    },
  );
}

class PhotoViewerRouteArgs {
  const PhotoViewerRouteArgs({this.key, required this.photo});

  final _i18.Key? key;

  final _i20.AssetEntity photo;

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
/// [_i12.ProfilePage]
class ProfileRoute extends _i17.PageRouteInfo<void> {
  const ProfileRoute({List<_i17.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i12.ProfilePage();
    },
  );
}

/// generated route for
/// [_i13.RegisterPage]
class RegisterRoute extends _i17.PageRouteInfo<void> {
  const RegisterRoute({List<_i17.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i13.RegisterPage();
    },
  );
}

/// generated route for
/// [_i14.SettingsPage]
class SettingsRoute extends _i17.PageRouteInfo<void> {
  const SettingsRoute({List<_i17.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i14.SettingsPage();
    },
  );
}

/// generated route for
/// [_i15.SplashScreen]
class SplashRoute extends _i17.PageRouteInfo<void> {
  const SplashRoute({List<_i17.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i15.SplashScreen();
    },
  );
}

/// generated route for
/// [_i16.SupportPage]
class SupportRoute extends _i17.PageRouteInfo<void> {
  const SupportRoute({List<_i17.PageRouteInfo>? children})
    : super(SupportRoute.name, initialChildren: children);

  static const String name = 'SupportRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i16.SupportPage();
    },
  );
}
