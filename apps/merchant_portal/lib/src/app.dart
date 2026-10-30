import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/merchant_router.dart';

class MerchantPortalApp extends ConsumerStatefulWidget {
  const MerchantPortalApp({super.key, this.initialLocation = '/dashboard'});

  final String initialLocation;

  @override
  ConsumerState<MerchantPortalApp> createState() => _MerchantPortalAppState();
}

class _MerchantPortalAppState extends ConsumerState<MerchantPortalApp> {
  late final _router = createMerchantRouter(initialLocation: widget.initialLocation);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Go-Volts Merchant Portal',
      debugShowCheckedModeBanner: false,
      theme: GVTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
