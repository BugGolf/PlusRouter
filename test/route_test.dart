import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:plus_router/plus_router.dart';

void main() {
  group('Test Route', () {

    test("route empty string", () async {
      Uri uri = Uri.parse("");
      PlusRoute route = PlusRoute(path: "", widget: Container());
      bool result = route.parseURLSegment(uri.pathSegments);
      
      expect(result, true);
      expect(route.isActive, true);
    });

    test("route with '/' string", () async {
      Uri uri = Uri.parse("/");
      PlusRoute route = PlusRoute(path: "/", widget: Container());
      bool result = route.parseURLSegment(uri.pathSegments);
      
      expect(result, true);
      expect(route.isActive, true);
    });

    test("route home", () async {
      Uri uri = Uri.parse("/home");
      PlusRoute route = PlusRoute(path: "/home", widget: Container());
      bool result = route.parseURLSegment(uri.pathSegments);
      expect(result, true);
      expect(route.isActive, true);
    });

    test("route home page name", () async {
      Uri uri = Uri.parse("/home");
      PlusRoute route = PlusRoute(path: "/home", widget: Container());
      bool result = route.parseURLSegment(uri.pathSegments);
      print(route.name);
      expect(result, true);
      expect(route.name.startsWith("home"), true);
    });

    test("route home page name", () async {
      Uri uri = Uri.parse("/home/1");
      PlusRoute route = PlusRoute(path: "/home/:id", widget: Container());
      bool result = route.parseURLSegment(uri.pathSegments);
      print(route.name);
      expect(result, true);
      expect(route.name.startsWith("home"), true);
    });

    test("route home detail", () async {
      Uri uri = Uri.parse("/home/detail");
      PlusRoute route = PlusRoute(path: "/home/detail", widget: Container());
      bool result = route.parseURLSegment(uri.pathSegments);
      expect(result, true);
      expect(route.isActive, true);
    });

    test("route home detail with id", () async {
      Uri uri = Uri.parse("/home/detail/1");
      PlusRoute route = PlusRoute(path: "/home/detail/:id", widget: Container());
      bool result = route.parseURLSegment(uri.pathSegments);
      expect(result, true);
      expect(route.isActive, true);
    });

    test("route home detail with id argument match", () async {
      String id = "1";
      Uri uri = Uri.parse("/home/detail/" + id);
      PlusRoute route = PlusRoute(path: "/home/detail/:id", widget: Container());
      bool result = route.parseURLSegment(uri.pathSegments);
      expect(result, true);
      expect(route.isActive, true);
      expect(route.arguments["id"].toString(), id);
    });

    test("route home is parent of detail", () async {
      Uri uri = Uri.parse("/home/detail");
      PlusRoute route = PlusRoute(path: "/home", widget: Container());
      bool result = route.parseURLSegment(uri.pathSegments);
      expect(result, true);
      expect(route.isParent, true);
      expect(route.isActive, false);
    });

    test("route home is parent of detail child", () async {
      Uri uri = Uri.parse("/home/detail/1");
      PlusRoute route = PlusRoute(path: "/home", widget: Container());
      bool result = route.parseURLSegment(uri.pathSegments);
      expect(result, true);
      expect(route.isParent, true);
      expect(route.isActive, false);
    });

  });

  group('Test Navigation', () {
    List<PlusRoute> routes = [
      PlusRoute(path: "/home", widget: Container()),
      PlusRoute(path: "/home/detail", widget: Container())
    ];
    PlusRouterState router = PlusRouterState();
    router.router = PlusRouter(routes);

    test("navigate to home", () async {
      Uri uri = Uri.parse("/home");
      
      router.navigate(uri.pathSegments);
      expect(router.location, "/home");
    });

    test("navigate to home detail", () async {
      Uri uri = Uri.parse("/home/detail");
      
      router.navigate(uri.pathSegments);
      expect(router.location, "/home/detail");
    });

    test("navigate to home detail by string", () async {
      router.navigateByUrl("/home/detail");
      expect(router.location, "/home/detail");
    });

    test("navigate can back to home", () async {
      Uri uri = Uri.parse("/home/detail");
      router.navigate(uri.pathSegments);

      expect(router.location, "/home/detail");
      expect(router.canBack(), true);
    });

    test("navigate back to home", () async {
      Uri uri = Uri.parse("/home/detail");
      router.navigate(uri.pathSegments);

      expect(router.location, "/home/detail");
      expect(router.canBack(), true);

      router.back();
      expect(router.location, "/home");
    });

  });

}