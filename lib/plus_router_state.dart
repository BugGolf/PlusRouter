import 'package:flutter/material.dart';
import 'plus_router_configuration.dart';

class PlusRouterState extends ChangeNotifier {

  late PlusRouterConfiguration configuration;

  static late PlusRouterState instance;
  PlusRouterState(PlusRouterConfiguration configuration) {
    this.configuration = configuration;
    PlusRouterState.instance = this;
  }

  void setConfiguration(PlusRouterConfiguration configuration) {
    this.configuration = configuration;
  }

  void navigate(List<String> args) {
    this.configuration.parseSegments(args);
    notifyListeners();
  }

  void navigateByUrl(String path) {
    return navigate(Uri.parse(path).pathSegments);
  }

  void back() {
    
  }

}