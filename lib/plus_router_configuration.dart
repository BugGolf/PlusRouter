import 'plus_route.dart';

class PlusRouterConfiguration {
  final List<PlusRoute> routes;
  PlusRouterConfiguration.instance(this.routes);

  List<PlusRoute> currentRoutes = [];
  PlusRoute? currentRoute;
  PlusRoute? defautRoute;

  bool get isError => currentRoute == null;
  String get location => currentRoute?.location ?? "/";

  List<String> pathSegments = [];
  
  void parseRouteInformation(Uri uri) {
    this.parseSegments(uri.pathSegments);
  }

  void parseSegments(List<String> segments) {
    this.pathSegments = segments;
    
    this.currentRoute = null;
    this.currentRoutes = [];

    for(PlusRoute route in this.routes) {
      bool _result = route.tryParse(pathSegments);
      if(_result) {
        if(route.isParent) {
          this.currentRoutes.add(route);
        }

        if(route.isCurrent) {
          this.currentRoute = route;
          this.currentRoutes.add(route);
        }
      }
    }
  }
  
}