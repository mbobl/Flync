import 'dart:io';
import 'package:animations/animations.dart';
import 'package:device_preview/device_preview.dart';
import 'package:dynamic_system_colors/dynamic_system_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flync/service/service_locator.dart';
import 'package:flync/ui/page/home/home_page.dart';
import 'package:flync/ui/page/storage_form/config/storage_source_ui.dart';
import 'package:flync/ui/page/storage_form/storage_config_page.dart';
import 'package:flync/ui/page/storage_form/storage_source_select_page.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

bool isMobile() => Platform.isAndroid || Platform.isIOS;

//TODO: https://pub.dev/documentation/go_router/latest/topics/Type-safe%20routes-topic.html
final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/storage-form',
      builder: (context, state) => const StorageSourceSelectPage(step: 1),
    ),
    GoRoute(
      path: '/storage-source-select/:step',
      builder:
          (context, state) => StorageSourceSelectPage(
            step: int.parse(state.pathParameters['step']!),
          ),
    ),
    GoRoute(
      path: '/storage-config/:step/:source',
      builder:
          (context, state) => StorageConfigPage(
            step: int.parse(state.pathParameters['step']!),
            selectedSourceUi: StorageSourceUi.values.byName(
              state.pathParameters['source']!,
            ),
          ),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  runApp(
    DevicePreview(
      enabled: !kReleaseMode && !isMobile(),
      builder: (context) => const Main(),
    ),
  );
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: DynamicColorBuilder(
        builder:
            (lightScheme, darkScheme) => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: _router,
              theme: ThemeData(
                appBarTheme: AppBarTheme(
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarBrightness: Brightness.dark,
                  ),
                ),
                colorScheme: lightScheme,
                materialTapTargetSize: MaterialTapTargetSize.padded,
                textTheme: GoogleFonts.instrumentSansTextTheme(),
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(),
                ),
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: {
                    TargetPlatform.linux: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal,
                    ),
                    TargetPlatform.android: SharedAxisPageTransitionsBuilder(
                      transitionType: SharedAxisTransitionType.horizontal,
                    ),
                  },
                ),
              ),
            ),
      ),
    );
  }
}
