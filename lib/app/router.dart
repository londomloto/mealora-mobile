import 'package:flutter/material.dart';
import 'package:mealora/app/bootstrap.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Nama rute aplikasi.
abstract final class MealoraRoutes {
  /// Gerbang peluncuran: splash lalu ruang utama.
  static const String root = '/';
}

/// Membangun rute yang dikenal aplikasi.
Route<void>? generateMealoraRoute(RouteSettings settings) {
  return switch (settings.name) {
    MealoraRoutes.root => MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const MealoraBootstrap(),
    ),
    _ => null,
  };
}

/// Rute yang tidak dikenal: keadaan yang dapat dibaca pengguna beserta jalan
/// kembali ke ruang utama — bukan layar kosong.
Route<void> unknownMealoraRoute(RouteSettings settings) {
  return MaterialPageRoute<void>(
    settings: settings,
    builder: (_) => const RouteNotFoundScreen(),
  );
}

/// Layar "halaman tidak ditemukan".
class RouteNotFoundScreen extends StatelessWidget {
  const RouteNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MealoraSpacing.xl),
            child: MealoraErrorState(
              title: text.routeNotFoundTitle,
              body: text.routeNotFoundBody,
              action: MealoraPrimaryButton(
                label: text.routeNotFoundAction,
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(MealoraRoutes.root, (route) => false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
