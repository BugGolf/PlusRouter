import 'package:plus_router/plus_router.dart';

abstract class PlusRouterCanActivate {
  Future<bool> canActivate(PlusRouterState state);
}
