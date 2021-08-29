import 'package:flutter/cupertino.dart';
import 'package:plus_router/plus_route.dart';
import 'package:plus_router/plus_router_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Plus Router Configuration', () {
    List<PlusRoute> routes = [
      PlusRoute(
        path: "home",
        builder: (state, args) => Container()
      ),
      PlusRoute(
        path: "home/profile",
        builder: (state, args) => Container()
      ),
      PlusRoute(
        path: "home/detail/:id",
        builder: (state, args) => Container()
      ),
      PlusRoute(
        path: "welcome",
        builder: (state, args) => Container()
      )
    ];

    PlusRouterConfiguration configuration 
      = PlusRouterConfiguration.instance(routes);

    test("test route home", () async {
      Uri uri = Uri.parse("http://localhost/home");
      configuration.parseRouteInformation(uri);

      expect(configuration.currentRoute?.path, "home");
    });

    test("test route home with child", () async {
      Uri uri = Uri.parse("http://localhost/home/profile");
      configuration.parseRouteInformation(uri);

      expect(configuration.isError, false);
      expect(configuration.currentRoute?.path, "home/profile");
    });

    test("test route home with child paramter", () async {
      Uri uri = Uri.parse("http://localhost/home/detail/1");
      configuration.parseRouteInformation(uri);

      expect(configuration.isError, false);
      expect(configuration.currentRoute?.path, "home/detail/:id");
    });

    test("test route stack page", () async {
      Uri uri = Uri.parse("http://localhost/home/detail/1");
      configuration.parseRouteInformation(uri);

      expect(configuration.isError, false);
      expect(configuration.currentRoutes.length, 2);
    });
  });
}