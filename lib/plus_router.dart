import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:plus_router/plus_can_activate.dart';
import 'package:plus_router/plus_router_load.dart';

class PlusRouterState extends ChangeNotifier {
  PlusRouter _router = PlusRouter([]);

  static PlusRouterState _routerState = PlusRouterState();
  static PlusRouterState get instance => _routerState;

  Map<String, dynamic> _stateObject = {};
  PlusRoute? currentRoute;
  
  String get location => currentRoute == null ? "/" : currentRoute!.location;

  void setNewRouter(PlusRouter router) {
    this._router = router;
    this.navigate(router.urlSegments);
  }

  /// Navigate
  Future<void> navigate(List<String> urlSegments) async {
    this.currentRoute = this._router.tryParse(urlSegments);
    notifyListeners();
  }

  /// Navigate by url string
  Future<void> navigateByUrl(String path) async {
    return this.navigate(Uri.parse(path).pathSegments);
  }

  bool canBack() {
    List<String> backSegments = [...this._router.urlSegments];
    return backSegments.isNotEmpty;
  }

  bool back() {
    if (this.canBack()) {
      List<String> backSegments = [...this._router.urlSegments];
      backSegments.removeLast();

      PlusRoute? _result = this._router.tryParse(backSegments);
      if (_result != null) {
        this.navigateByUrl(_result.location);
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
    if (this._stateObject.containsKey(key)) return this._stateObject[key];
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

  PlusRoute({required this.path,
    this.builder,
    this.widget,
    this.canActivate,
    this.routerMatch = RouterMatch.Prefix})
    : assert((builder == null) != (widget == null));

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
    if (urlSegments.isEmpty && pathSegments.isEmpty) {
      isActive = true;
      return true;
    }

    // Check Full Match
    if (this.routerMatch == RouterMatch.Full &&
        urlSegments.length != pathSegments.length) return false;

    // urlSegment >= pathSegment, skip if not
    if (urlSegments.length < pathSegments.length) return false;

    this.arguments = {};
    this.localSegments = [];

    for (int i = 0; i < pathSegments.length; i++) {
      String urlSegment = urlSegments[i].toString();
      String pathSegment = pathSegments[i].toString();

      if (localSegments.length == i) {
        if (urlSegment == pathSegment) {
          this.localSegments.add(pathSegment);
        } else {
          // Check segment start with ':' is argument
          // Ex. /home/:id
          if (checkArgument(pathSegment)) {
            this.setArgument(pathSegment, urlSegment);
            this.localSegments.add(urlSegment);
          }
        }
      }
    }

    if (this.localSegments.isNotEmpty) {
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

  List<String> urlSegments = [];
  List<PlusRoute> activatedRoutes = [];
  PlusRoute? route;

  PlusRoute? tryParse(List<String> urlSegments) {
    // Reset activatedRoutes
    this.route = null;
    this.urlSegments = urlSegments;

    // forEach List<PlusRoute> routes
    this.activatedRoutes = [];
    for (PlusRoute route in routes) {
      bool result = route.parseURLSegment(urlSegments);
      if (result) {
        // If route is active == this is current route
        // Return this route to routerState
        if (route.isActive) 
          this.route = route;
        else
          this.activatedRoutes.add(route);
      }
    }
    return this.route;
  }
}

class PlusRouteInformationParser extends RouteInformationParser<PlusRouter> {
  String initialRoute;
  List<PlusRoute> routes;
  PlusRouteInformationParser(this.routes, { this.initialRoute = "/" });

  @override
  Future<PlusRouter> parseRouteInformation(
      RouteInformation routeInformation) async {
    Uri uri = Uri.parse(routeInformation.location!);
    
    PlusRouter router = PlusRouter(this.routes);
    router.tryParse(uri.pathSegments);

    if(router.route == null)
      router.tryParse(Uri.parse(this.initialRoute).pathSegments);
    
    return router;
  }

  @override
  RouteInformation? restoreRouteInformation(PlusRouter router) {
    return RouteInformation(location: router.route?.location ?? "/");
  }
}

class PlusRouterDelegate extends RouterDelegate<PlusRouter>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<PlusRouter> {
  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey<NavigatorState>();

  final Widget? loadPage;
  late PlusRouterState state;

  PlusRouterDelegate(List<PlusRoute> routes, { this.loadPage }) {
    this.state = PlusRouterState.instance;
    this.state._router = PlusRouter(routes);
    this.state.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    state.removeListener(notifyListeners);
  }

  @override
  PlusRouter? get currentConfiguration {
    return state._router;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, result) {
        if (!route.didPop(result)) return false;
        return this.state.back();
      },
      pages: [
        MaterialPage(
          key: ValueKey("plus_router_init_page"), 
          child: loadPage ?? PlusRouterLoadPage()),

        // Activated Route
        for (PlusRoute route in state._router.activatedRoutes)
          MaterialPage(
            key: ValueKey(route.name),
            child: route.widget ?? route.builder!(state, route.arguments)),

        // current route
        if (state.currentRoute != null)
          MaterialPage(
            key: ValueKey(state.currentRoute!.name),
            child: state.currentRoute!.widget ?? state.currentRoute!.builder!(
              state, state.currentRoute!.arguments
            )),
      ]);
  }

  Future<bool> canActivate(PlusRouter _router) async {
    PlusRoute? current = _router.route;
    List<PlusRouterCanActivate>? canActivates = current?.canActivate;

    if (current != null && canActivates != null) {
      for (PlusRouterCanActivate activate in current.canActivate!) {
        if (await activate.canActivate(this.state) == false) return false;
      }
    }

    return true;
  }

  @override
  Future<void> setNewRoutePath(router) async {
    bool _result = await this.canActivate(router);
    if(_result == true)
      this.state.setNewRouter(router);
  }
}
