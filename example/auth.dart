import 'package:flutter/material.dart';
import 'package:plus_router/plus_can_activate.dart';
import 'package:plus_router/plus_router.dart';
import 'package:plus_router/plus_router_load.dart';

void main() {
  runApp(MyApp());
}

class AuthGuard implements PlusRouterCanActivate {
  @override
  Future<bool> canActivate(PlusRouterState state) async {
    bool? login = state.getStateObject("login") as bool?;

    /// Faker http request to authenticate system
    await Future.delayed(Duration(seconds: 2));

    if(login == true) {
      return false;
    } else {
      state.navigateByUrl("/login");
      return false;
    }
  }
}

List<PlusRoute> routes = [
  PlusRoute(
    path: "/",
    widget: WelcomePage(),
    canActivate: [AuthGuard()]
  ),
  PlusRoute(
    path: "/login",
    builder: (state, args) => LoginPage(routerState: state)
  ),
];

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Demo Authenticate',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routeInformationParser: PlusRouteInformationParser(routes),
      // routerDelegate: PlusRouterDelegate(routes),
      routerDelegate: PlusRouterDelegate(routes,
        loadPage: PlusRouterLoadPage()
      ),
    );
  }
}

class LoginPage extends StatelessWidget {

  /// final PlusRouterState routerState = PlusRouterState.instance;
  final PlusRouterState routerState;
  const LoginPage({ Key? key, required this.routerState }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Center(child: Column(
        children: [
          Container(child: Text("Login Page")),
          Container(
            child: ElevatedButton(
              onPressed: () {
                this.routerState.setStateObject("login", true);
                this.routerState.navigateByUrl("/");
              },
              child: Text("Click to login")
            )
          )
        ],
      )),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Container(child: Text("Welcome Page"))),
    );
  }
}