import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routegard.dart';
import 'package:categorize_app/Routes/routes.gr.dart';



@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  AppRouter(this.routeGuard);

  final RouteGuard routeGuard;
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: AppRoute.page, initial: true),
    AutoRoute(page: GalleryRoute.page),
    AutoRoute(page: PhotoViewerRoute.page),
    AutoRoute(page: ProfileRoute.page, guards: <AutoRouteGuard>[routeGuard]),
    AutoRoute(page: FoldersRoute.page),
    AutoRoute(page: ChatRoute.page),
    AutoRoute(page: FolderDetailsRoute.page),
    AutoRoute(page: RegisterRoute.page),
    AutoRoute(page: LoginRoute.page),
    AutoRoute(page: EditRoute.page, guards: <AutoRouteGuard>[routeGuard]),
    AutoRoute(page: SettingsRoute.page, guards: <AutoRouteGuard>[routeGuard]),
    AutoRoute(page: AboutRoute.page, guards: <AutoRouteGuard>[routeGuard]),
    AutoRoute(page: SupportRoute.page, guards: <AutoRouteGuard>[routeGuard]),
  ];

}
