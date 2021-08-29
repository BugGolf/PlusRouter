import 'package:flutter/material.dart';
import 'plus_route.dart';
import 'plus_router_configuration.dart';

class PlusRouteInformationParser extends RouteInformationParser<PlusRouterConfiguration> {
  
  /**
   * Init routes
   */
  List<PlusRoute> routes;
  PlusRouteInformationParser(this.routes);

  @override
  Future<PlusRouterConfiguration> parseRouteInformation(
    RouteInformation routeInformation) async {
    Uri uri = Uri.parse(routeInformation.location!);

    PlusRouterConfiguration configuration = 
      PlusRouterConfiguration.instance(this.routes);
      
    configuration.parseRouteInformation(uri);
    return configuration;
  }

  @override
  RouteInformation? restoreRouteInformation(PlusRouterConfiguration configuration) {
    return RouteInformation(location: configuration.location);
  }
}
