import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mealora/app/router.dart';
import 'package:mealora/app/theme/app_theme.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Akar aplikasi Mealora.
///
/// Satu locale (`id-ID`), satu tema terang yang dibangun dari token, dan
/// rute bernama dengan keadaan rute tidak dikenal yang dapat dibaca pengguna.
class MealoraApp extends StatelessWidget {
  const MealoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppText.of(context).appName,
      debugShowCheckedModeBanner: false,
      theme: MealoraTheme.light(),
      localizationsDelegates: AppText.localizationsDelegates,
      supportedLocales: AppText.supportedLocales,
      locale: const Locale('id'),
      initialRoute: MealoraRoutes.root,
      onGenerateRoute: generateMealoraRoute,
      onUnknownRoute: unknownMealoraRoute,
      // Ikon status bar gelap sebagai bawaan; layar yang butuh ikon terang
      // (mis. foto hero tinjau foto, change 021) menimpanya selama terlihat.
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
