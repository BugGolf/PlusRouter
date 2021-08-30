import 'package:flutter/material.dart';
import 'package:plus_router/plus_router.dart';

void main() {
  runApp(MyApp());
}

List<PlusRoute> routes = [
  PlusRoute(
    path: "/",
    builder: (state, args) => HomePage(routerState: state)
  ),
  PlusRoute(
    path: "/home/list",
    builder: (state, args) => WelcomePage(routerState: state)
  ),
  PlusRoute(
    path: "/home/list/:id",
    builder: (state, args) => HomeDetailPage(routerState: state, args: args)
  )
];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Demo Route',
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
  HomePage({ Key? key, required this.routerState }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Column(
        children: [
          Container(child: Text("Home Page")),
          Container(
            child: ElevatedButton(
              onPressed: () { 
                this.routerState.navigateByUrl("/home/list");
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
                this.routerState.navigateByUrl("/home/list/100");
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
          Container(child: Text("Detail Page $arg")),
          Container(
            child: ElevatedButton(
              onPressed: () {
                this.routerState.back();
              },
              child: Text("Click"),
            )
          )
        ],
      )),
    );
  }
}