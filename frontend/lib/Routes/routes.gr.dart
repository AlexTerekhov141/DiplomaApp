// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i23;
import 'package:categorize_app/models/Folders/Folder.dart' as _i25;
import 'package:categorize_app/pages/loginAndRegisterPages/EditPage.dart'
    as _i4;
import 'package:categorize_app/pages/loginAndRegisterPages/LoginPage.dart'
    as _i11;
import 'package:categorize_app/pages/loginAndRegisterPages/RegisterPage.dart'
    as _i16;
import 'package:categorize_app/pages/MainPage.dart' as _i3;
import 'package:categorize_app/pages/mainPages/FeaturePage/Chat/ChatPage.dart'
    as _i7;
import 'package:categorize_app/pages/mainPages/FeaturePage/Enchance/EnchancePage.dart'
    as _i5;
import 'package:categorize_app/pages/mainPages/FeaturePage/Favourite/FavouritePage.dart'
    as _i6;
import 'package:categorize_app/pages/mainPages/FeaturePage/PhotoRoast/PhotoRoastPage.dart'
    as _i13;
import 'package:categorize_app/pages/mainPages/FeaturePage/SuggestedTrash/SuggestedTrashDetailPage.dart'
    as _i19;
import 'package:categorize_app/pages/mainPages/FeaturePage/SuggestedTrash/SuggestedTrashPage.dart'
    as _i20;
import 'package:categorize_app/pages/mainPages/FeaturePage/Trash/TrashPage.dart'
    as _i22;
import 'package:categorize_app/pages/mainPages/Offline/offline.dart' as _i2;
import 'package:categorize_app/pages/mainPages/Offline/OfflineCategorization.dart'
    as _i12;
import 'package:categorize_app/pages/mainPages/Photos/FolderDetail/FolderDetailPage.dart'
    as _i8;
import 'package:categorize_app/pages/mainPages/Photos/Folders/FoldersPage.dart'
    as _i9;
import 'package:categorize_app/pages/mainPages/Photos/Gallery/GalleryPage.dart'
    as _i10;
import 'package:categorize_app/pages/mainPages/Photos/Photo/Photo.dart' as _i14;
import 'package:categorize_app/pages/mainPages/ProfilePages/About/AboutPage.dart'
    as _i1;
import 'package:categorize_app/pages/mainPages/ProfilePages/Profile/ProfilePage.dart'
    as _i15;
import 'package:categorize_app/pages/mainPages/ProfilePages/Settings/SettingsPage.dart'
    as _i17;
import 'package:categorize_app/pages/mainPages/ProfilePages/Support/SupportPage.dart'
    as _i21;
import 'package:categorize_app/pages/spash/splash_screen.dart' as _i18;
import 'package:flutter/material.dart' as _i24;
import 'package:photo_manager/photo_manager.dart' as _i26;

/// generated route for
/// [_i1.AboutPage]
class AboutRoute extends _i23.PageRouteInfo<void> {
  const AboutRoute({List<_i23.PageRouteInfo>? children})
    : super(AboutRoute.name, initialChildren: children);

  static const String name = 'AboutRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i1.AboutPage();
    },
  );
}

/// generated route for
/// [_i2.AppMode]
class AppMode extends _i23.PageRouteInfo<void> {
  const AppMode({List<_i23.PageRouteInfo>? children})
    : super(AppMode.name, initialChildren: children);

  static const String name = 'AppMode';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i2.AppMode();
    },
  );
}

/// generated route for
/// [_i3.AppPage]
class AppRoute extends _i23.PageRouteInfo<AppRouteArgs> {
  AppRoute({
    _i24.Key? key,
    int initialIndex = 0,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         AppRoute.name,
         args: AppRouteArgs(key: key, initialIndex: initialIndex),
         initialChildren: children,
       );

  static const String name = 'AppRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AppRouteArgs>(
        orElse: () => const AppRouteArgs(),
      );
      return _i3.AppPage(key: args.key, initialIndex: args.initialIndex);
    },
  );
}

class AppRouteArgs {
  const AppRouteArgs({this.key, this.initialIndex = 0});

  final _i24.Key? key;

  final int initialIndex;

  @override
  String toString() {
    return 'AppRouteArgs{key: $key, initialIndex: $initialIndex}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AppRouteArgs) return false;
    return key == other.key && initialIndex == other.initialIndex;
  }

  @override
  int get hashCode => key.hashCode ^ initialIndex.hashCode;
}

/// generated route for
/// [_i4.EditPage]
class EditRoute extends _i23.PageRouteInfo<EditRouteArgs> {
  EditRoute({_i24.Key? key, List<_i23.PageRouteInfo>? children})
    : super(
        EditRoute.name,
        args: EditRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'EditRoute';

  static _i23.PageInfo page = _i23.PageInfo(
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

  final _i24.Key? key;

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
/// [_i5.EnhancePage]
class EnhanceRoute extends _i23.PageRouteInfo<void> {
  const EnhanceRoute({List<_i23.PageRouteInfo>? children})
    : super(EnhanceRoute.name, initialChildren: children);

  static const String name = 'EnhanceRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i5.EnhancePage();
    },
  );
}

/// generated route for
/// [_i6.FavouritePage]
class FavouriteRoute extends _i23.PageRouteInfo<void> {
  const FavouriteRoute({List<_i23.PageRouteInfo>? children})
    : super(FavouriteRoute.name, initialChildren: children);

  static const String name = 'FavouriteRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i6.FavouritePage();
    },
  );
}

/// generated route for
/// [_i7.FeatureHubPage]
class FeatureHubRoute extends _i23.PageRouteInfo<void> {
  const FeatureHubRoute({List<_i23.PageRouteInfo>? children})
    : super(FeatureHubRoute.name, initialChildren: children);

  static const String name = 'FeatureHubRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i7.FeatureHubPage();
    },
  );
}

/// generated route for
/// [_i8.FolderDetailsPage]
class FolderDetailsRoute extends _i23.PageRouteInfo<FolderDetailsRouteArgs> {
  FolderDetailsRoute({
    _i24.Key? key,
    required _i25.Folder folder,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         FolderDetailsRoute.name,
         args: FolderDetailsRouteArgs(key: key, folder: folder),
         initialChildren: children,
       );

  static const String name = 'FolderDetailsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FolderDetailsRouteArgs>();
      return _i8.FolderDetailsPage(key: args.key, folder: args.folder);
    },
  );
}

class FolderDetailsRouteArgs {
  const FolderDetailsRouteArgs({this.key, required this.folder});

  final _i24.Key? key;

  final _i25.Folder folder;

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
/// [_i9.FoldersPage]
class FoldersRoute extends _i23.PageRouteInfo<void> {
  const FoldersRoute({List<_i23.PageRouteInfo>? children})
    : super(FoldersRoute.name, initialChildren: children);

  static const String name = 'FoldersRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i9.FoldersPage();
    },
  );
}

/// generated route for
/// [_i10.GalleryPage]
class GalleryRoute extends _i23.PageRouteInfo<void> {
  const GalleryRoute({List<_i23.PageRouteInfo>? children})
    : super(GalleryRoute.name, initialChildren: children);

  static const String name = 'GalleryRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i10.GalleryPage();
    },
  );
}

/// generated route for
/// [_i11.LoginPage]
class LoginRoute extends _i23.PageRouteInfo<void> {
  const LoginRoute({List<_i23.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i11.LoginPage();
    },
  );
}

/// generated route for
/// [_i12.OfflineCategorizationPage]
class OfflineCategorizationRoute extends _i23.PageRouteInfo<void> {
  const OfflineCategorizationRoute({List<_i23.PageRouteInfo>? children})
    : super(OfflineCategorizationRoute.name, initialChildren: children);

  static const String name = 'OfflineCategorizationRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i12.OfflineCategorizationPage();
    },
  );
}

/// generated route for
/// [_i13.PhotoRoastPage]
class PhotoRoastRoute extends _i23.PageRouteInfo<void> {
  const PhotoRoastRoute({List<_i23.PageRouteInfo>? children})
    : super(PhotoRoastRoute.name, initialChildren: children);

  static const String name = 'PhotoRoastRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i13.PhotoRoastPage();
    },
  );
}

/// generated route for
/// [_i14.PhotoViewerPage]
class PhotoViewerRoute extends _i23.PageRouteInfo<PhotoViewerRouteArgs> {
  PhotoViewerRoute({
    _i24.Key? key,
    required _i26.AssetEntity photo,
    List<_i23.PageRouteInfo>? children,
  }) : super(
         PhotoViewerRoute.name,
         args: PhotoViewerRouteArgs(key: key, photo: photo),
         initialChildren: children,
       );

  static const String name = 'PhotoViewerRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PhotoViewerRouteArgs>();
      return _i14.PhotoViewerPage(key: args.key, photo: args.photo);
    },
  );
}

class PhotoViewerRouteArgs {
  const PhotoViewerRouteArgs({this.key, required this.photo});

  final _i24.Key? key;

  final _i26.AssetEntity photo;

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
/// [_i15.ProfilePage]
class ProfileRoute extends _i23.PageRouteInfo<void> {
  const ProfileRoute({List<_i23.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i15.ProfilePage();
    },
  );
}

/// generated route for
/// [_i16.RegisterPage]
class RegisterRoute extends _i23.PageRouteInfo<void> {
  const RegisterRoute({List<_i23.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i16.RegisterPage();
    },
  );
}

/// generated route for
/// [_i17.SettingsPage]
class SettingsRoute extends _i23.PageRouteInfo<void> {
  const SettingsRoute({List<_i23.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i17.SettingsPage();
    },
  );
}

/// generated route for
/// [_i18.SplashScreen]
class SplashRoute extends _i23.PageRouteInfo<void> {
  const SplashRoute({List<_i23.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i18.SplashScreen();
    },
  );
}

/// generated route for
/// [_i19.SuggestedtrashdetailPage]
class SuggestedtrashdetailRoute extends _i23.PageRouteInfo<void> {
  const SuggestedtrashdetailRoute({List<_i23.PageRouteInfo>? children})
    : super(SuggestedtrashdetailRoute.name, initialChildren: children);

  static const String name = 'SuggestedtrashdetailRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i19.SuggestedtrashdetailPage();
    },
  );
}

/// generated route for
/// [_i20.Suggestedtrashpage]
class Suggestedtrashpage extends _i23.PageRouteInfo<void> {
  const Suggestedtrashpage({List<_i23.PageRouteInfo>? children})
    : super(Suggestedtrashpage.name, initialChildren: children);

  static const String name = 'Suggestedtrashpage';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i20.Suggestedtrashpage();
    },
  );
}

/// generated route for
/// [_i21.SupportPage]
class SupportRoute extends _i23.PageRouteInfo<void> {
  const SupportRoute({List<_i23.PageRouteInfo>? children})
    : super(SupportRoute.name, initialChildren: children);

  static const String name = 'SupportRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i21.SupportPage();
    },
  );
}

/// generated route for
/// [_i22.TrashPage]
class TrashRoute extends _i23.PageRouteInfo<void> {
  const TrashRoute({List<_i23.PageRouteInfo>? children})
    : super(TrashRoute.name, initialChildren: children);

  static const String name = 'TrashRoute';

  static _i23.PageInfo page = _i23.PageInfo(
    name,
    builder: (data) {
      return const _i22.TrashPage();
    },
  );
}
