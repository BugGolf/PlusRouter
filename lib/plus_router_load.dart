import 'package:flutter/material.dart';

class PlusRouterLoadPage extends StatelessWidget {
  const PlusRouterLoadPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
