import 'package:flutter/cupertino.dart';
import 'package:plus_router/plus_route.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Plus Route', () {
    test("test route home", () async {
      PlusRoute route = PlusRoute(
        path: "home",
        builder: (state, args) => Container()
      );
      
      bool result = route.tryParse(["home"]);
      expect(result, true);
    });

    test("test route home with parameter", () async {
      PlusRoute route = PlusRoute(
        path: "home/:id",
        builder: (state, args) => Container()
      );
      
      bool result = route.tryParse(["home", "100"]);
      expect(result, true);
      expect(route.arguments["id"], "100");
    });

    test("test route home with child", () async {
      PlusRoute route = PlusRoute(
        path: "home/detail",
        builder: (state, args) => Container()
      );
      
      bool result = route.tryParse(["home", "detail"]);
      expect(result, true);
    });

    test("test route home with child and parameter", () async {
      PlusRoute route = PlusRoute(
        path: "home/detail/:id",
        builder: (state, args) => Container()
      );
      
      bool result = route.tryParse(["home", "detail", "100"]);
      expect(result, true);
    });

    test("test route is parent", () async {
      PlusRoute route = PlusRoute(
        path: "home",
        builder: (state, args) => Container()
      );
      
      bool result = route.tryParse(["home", "detail"]);
      expect(result, true);
      expect(route.isParent, true);
      expect(route.isCurrent, false);
    });


    test("test route is parent with parameter", () async {
      PlusRoute route = PlusRoute(
        path: "home",
        builder: (state, args) => Container()
      );
      
      bool result = route.tryParse(["home", "detail", "1"]);
      expect(result, true);
      expect(route.isParent, true);
      expect(route.isCurrent, false);
    });

    test("test route is current", () async {
      PlusRoute route = PlusRoute(
        path: "home/detail",
        builder: (state, args) => Container()
      );
      
      bool result = route.tryParse(["home", "detail"]);
      expect(result, true);
      expect(route.isParent, false);
      expect(route.isCurrent, true);
    });

    test("test route is current with parameter", () async {
      PlusRoute route = PlusRoute(
        path: "home/detail/:id",
        builder: (state, args) => Container()
      );
      
      bool result = route.tryParse(["home", "detail", "100"]);
      expect(result, true);
      expect(route.isParent, false);
      expect(route.isCurrent, true);
    });
  });
}