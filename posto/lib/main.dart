import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:posto/core/utils/themes.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/utils/l10n/app_localizations.dart';
import 'supabase_options.dart';
import 'core/navigation/router.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoRouter.optionURLReflectsImperativeAPIs = true;

  await Future.wait([
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown
    ]),
    Supabase.initialize(
      url: SupabaseOptions.supabaseUrl,
      anonKey: SupabaseOptions.supabaseAnonKey,
    ),
  ]);

  runApp(
    ProviderScope(
      child: DevicePreview(
        enabled: false,
        builder: (context) {
          return MyApp();
        },
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterNotifierProvider);

    return MaterialApp.router(
      title: 'Virtual Therapy App',
      theme: CustomTheme.lightTheme,
      themeMode: ThemeMode.dark,
      routerConfig: goRouter,
      localizationsDelegates: const [
        FlutterQuillLocalizations.delegate,
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt'),
      ],
    );
  }
}
