import 'package:flutter/material.dart';
import 'plus_router_error.dart';
import 'plus_route.dart';
import 'plus_router_configuration.dart';
import 'plus_router_state.dart';

class PlusRouterDelegate extends RouterDelegate<PlusRouterConfiguration>
with ChangeNotifier, PopNavigatorRouterDelegateMixin<PlusRouterConfiguration> {

  @override
  GlobalKey<NavigatorState>? get navigatorKey => GlobalKey<NavigatorState>();

  /**
   * Init routes
   */
  late PlusRouterState _state;
  PlusRouterDelegate(List<PlusRoute> routes) {
    this._state = PlusRouterState(PlusRouterConfiguration.instance(routes));
    this._state.addListener(notifyListeners);
  }

  @override
  void dispose() {
    super.dispose();
    _state.removeListener(notifyListeners);
  }

  @override
  PlusRouterConfiguration? get currentConfiguration {
    return _state.configuration;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onPopPage: (route, result) {
        if(!route.didPop(result)) {
          return false;
        }

        return true;
      },
      pages: [
        for(PlusRoute route in _state.configuration.currentRoutes)
          MaterialPage(
            key: ValueKey(route.name),
            child: route.widget ?? route.builder!(_state, route.arguments)
          ),

        if(_state.configuration.isError)
          MaterialPage(
            key: ValueKey("plus_error_page"),
            child: PlusRouterErrorPage()
          )
      ]
    );
  }
  
  @override
  Future<void> setNewRoutePath(configuration) async {
    _state.setConfiguration(configuration);
  }
    
}
