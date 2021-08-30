import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:plus_router/plus_can_activate.dart';
import 'plus_router_error.dart';

class PlusRouterState extends ChangeNotifier {
  PlusRouter router;
  PlusRouterState(this.router);

  Map<String, dynamic> _stateObject = {};

  bool get isErrorPage {
    return router.currentRoute == null;
  }
  
  String get location {
    return isErrorPage ? "/" : router.location;
  }

  Future<void> setNewRouter(PlusRouter router) async {
    this.router = router;
    await this.canActivate();

    notifyListeners();
  }

  Future<void> canActivate() async {
    if(this.router.currentRoute != null) {
      if(this.router.currentRoute!.canActivate != null)
      {
        for(PlusRouterCanActivate activate 
          in this.router.currentRoute!.canActivate!) {
          bool result = await activate.canActivate(this);
          if(!result) 
            return;
        }
      }
    }
  }
  
  /// Navigate
  void navigate(List<String> urlSegments) {
    debugPrint(urlSegments.toString());
    this.router.tryParse(urlSegments);
    this.canActivate().then((value) {
      notifyListeners();
    });
  }

  /// Navigate by url string
  void navigateByUrl(String path) {
    this.navigate(Uri.parse(path).pathSegments);
  }

  bool canBack() {
    List<String> backSegments = Uri.parse(this.location).pathSegments;
    return backSegments.isNotEmpty;
  }

  bool back() {
    if(this.canBack()) {
      String location = this.location;
      List<String> backSegments = [...Uri.parse(this.location).pathSegments];
      backSegments.removeLast();

      this.navigate(backSegments);
      if(this.isErrorPage) {
        this.navigateByUrl(location);
        return false;
      } else {
        notifyListeners();
        return true;
      }
    }

    return false;
  }

  void setStateObject(String key, dynamic value) {
    this._stateObject[key] = value;
    notifyListeners();
  }

  dynamic getStateObject(String key) {
    if(this._stateObject.containsKey(key))
      return this._stateObject[key];

    notifyListeners();
  }
}

enum RouterMatch { Prefix, Full }

typedef RouterBuilder = Widget Function(
    PlusRouterState state, Map<String, dynamic> arguments);

class PlusRoute {
  final String path;
  final RouterBuilder? builder;
  final Widget? widget;
  final RouterMatch routerMatch;
  //final String? redirectTo;
  final List<PlusRouterCanActivate>? canActivate;
  
  Map<String, dynamic> arguments = {};
  List<String> localSegments = [];

  bool isParent = false;
  bool isActive = false;
  
  List<String> get pathSegments => Uri.parse(this.path).pathSegments;
  String get location => "/" + localSegments.join("/");

  String get name {
    return localSegments.join("_") + "_route";
  }

  PlusRoute({
    required this.path, 
    this.builder, 
    this.widget, 
    this.canActivate,
    this.routerMatch = RouterMatch.Prefix
  }) : assert((builder == null) != (widget == null));


  /// Start with ':' is argument
  bool checkArgument(String value) {
    return value.startsWith(":");
  }

  void setArgument(String segment, String value) {
    this.arguments[segment.replaceAll(":", "")] = value;
  }

  /// Try parse URLSegment
  bool parseURLSegment(List<String> urlSegments) {
    // Check is empty
    if(urlSegments.isEmpty && pathSegments.isEmpty) {
      isActive = true;
      return true;
    }

    // Check Full Match
    if(this.routerMatch == RouterMatch.Full
      && urlSegments.length != pathSegments.length)
      return false;

    // urlSegment >= pathSegment, skip if not
    if(urlSegments.length < pathSegments.length)
      return false;

    this.arguments = {};
    this.localSegments = [];

    for(int i=0;i<pathSegments.length;i++) 
    {
      String urlSegment = urlSegments[i].toString();
      String pathSegment = pathSegments[i].toString();

      if(urlSegment == pathSegment)
        this.localSegments.add(pathSegment);

      // Check segment start with ':' is argument
      // Ex. /home/:id
      if(checkArgument(pathSegment)) {
        this.setArgument(pathSegment, urlSegment);
        this.localSegments.add(urlSegment);
      }
      
    }
    
    if(this.localSegments.isNotEmpty) {
      this.isActive = localSegments.length == urlSegments.length;
      this.isParent = localSegments.length < urlSegments.length;
      return true;
    }

    return false;
  }

}

class PlusRouter {

  /// User defined routes
  final List<PlusRoute> routes;
  PlusRouter(this.routes);

  /// Activate routes current in URLSegment
  List<PlusRoute> activatedRoutes = [];
  PlusRoute? currentRoute;
  String get location => currentRoute?.location ?? "";

  void tryParse(List<String> urlSegments) {
    this.currentRoute = null;
    this.activatedRoutes = [];

    for(PlusRoute route in routes) {
      bool result = route.parseURLSegment(urlSegments);
      if(result) {
        this.activatedRoutes.add(route);

        if(route.isActive) 
          this.currentRoute = route;
      }
    }
  }

}

class PlusRouteInformationParser extends RouteInformationParser<PlusRouter> {
  List<PlusRoute> routes;
  PlusRouteInformationParser(this.routes);

  @override
  Future<PlusRouter> parseRouteInformation(
    RouteInformation routeInformation) async {
    Uri uri = Uri.parse(routeInformation.location!);

    PlusRouter router = PlusRouter(this.routes);
    router.tryParse(uri.pathSegments);

    return router;
  }

  @override
  RouteInformation? restoreRouteInformation(PlusRouter router) {
    return RouteInformation(location: router.location);
  }
}

class PlusRouterDelegate extends RouterDelegate<PlusRouter>
with ChangeNotifier, PopNavigatorRouterDelegateMixin<PlusRouter> {

  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey<NavigatorState>();
  
  late PlusRouterState state;

  PlusRouterDelegate(List<PlusRoute> routes) {
    this.state = PlusRouterState(PlusRouter(routes));
    this.state.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    state.removeListener(notifyListeners);
  }

  @override
  PlusRouter? get currentConfiguration {
    return state.router;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, result) {
        if(!route.didPop(result)) return false;
        return this.state.back();
      },
      pages: [
        for(PlusRoute route in state.router.activatedRoutes)
          MaterialPage(
            key: ValueKey(route.name),
            child: route.widget ?? route.builder!(state, route.arguments)
          ),

        if(state.isErrorPage)
          MaterialPage(
            key: ValueKey("plus_error_page"),
            child: PlusRouterErrorPage()
          )
      ]
    );
  }
  
  @override
  Future<void> setNewRoutePath(router) async {
    await state.setNewRouter(router);
  }
    
}