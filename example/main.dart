import 'package:flutter/material.dart';
import '../lib/plus_router_state.dart';
import '../lib/route_information_parser.dart';
import '../lib/router_delegate.dart';
import '../lib/plus_route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  final List<PlusRoute> routes = [
    PlusRoute(
      path: "home",
      builder: (state, args) => HomePage(routerState: state)
    ),
    PlusRoute(
      path: "welcome",
      builder: (state, args) => WelcomePage(routerState: state)
    ),
    PlusRoute(
      path: "home/detail/:id",
      builder: (state, args) => HomeDetailPage(routerState: state, args: args)
    ),
  ];

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerDelegate: PlusRouterDelegate(routes),
      routeInformationParser: PlusRouteInformationParser(routes),
    );
  }
}

class HomePage extends StatelessWidget {
  final PlusRouterState routerState;
  const HomePage({ Key? key, required this.routerState }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        children: [
          Container(child: Text("Home Page")),
          Container(
            child: ElevatedButton(
              onPressed: () { 
                this.routerState.navigate(["welcome"]);
              },
              child: Text("Click"),
            )
          )
        ],
      )),
    );
  }
}

class WelcomePage extends StatelessWidget {
  final PlusRouterState routerState;
  const WelcomePage({ Key? key, required this.routerState }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Center(child: Column(
        children: [
          Container(child: Text("Welcome Page")),
          Container(
            child: ElevatedButton(
              onPressed: () { 
                this.routerState.navigate(["home", "detail", "100"]);
              },
              child: Text("Click"),
            )
          )
        ],
      )),
    );
  }
}

class HomeDetailPage extends StatelessWidget {
  final PlusRouterState routerState;
  final Map<String, dynamic> args;
  const HomeDetailPage({ Key? key, required this.routerState, required this.args }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String arg = args["id"] ?? "None";

    return Scaffold(
       body: Center(child: Column(
        children: [
          Container(child: Text("Detail Page ${arg}")),
          Container(
            child: ElevatedButton(
              onPressed: () { 
                this.routerState.navigate(["home"]);
              },
              child: Text("Click"),
            )
          )
        ],
      )),
    );
  }
}