import 'package:auto_route/auto_route.dart';
import 'package:categorize_app/Routes/routes.gr.dart';



@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => <AutoRoute>[
    AutoRoute(page: AppRoute.page, initial: true),
    AutoRoute(page: GalleryRoute.page),
    AutoRoute(page: PhotoViewerRoute.page),
    AutoRoute(page: ProfileRoute.page),
    AutoRoute(page: FoldersRoute.page),
    AutoRoute(page: ChatRoute.page)
  ];

}