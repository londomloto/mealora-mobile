import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/app_update/app_update.dart';
import 'package:mealora/features/app_update/app_update_controller.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Membuka halaman app di toko. Hanya `https`, di aplikasi eksternal
/// (design D7); gagal → snackbar.
Future<void> openAppStore(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final failed = AppText.of(context).appUpdateStoreOpenFailed;
  final uri = Uri.tryParse(url);
  var opened = false;
  if (uri != null && uri.scheme == 'https') {
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      opened = false;
    }
  }
  if (!opened) messenger?.showSnackBar(SnackBar(content: Text(failed)));
}

String _storeActionLabel(AppText text) =>
    defaultTargetPlatform == TargetPlatform.iOS
    ? text.appUpdateStoreActionIos
    : text.appUpdateStoreActionAndroid;

/// Gerbang cek update (change 017, design D6): cek saat dibuka dan saat
/// resume; wajib update menggantikan [child]; update tersedia tampil sebagai
/// sheet sekali per versi.
class AppUpdateGate extends ConsumerStatefulWidget {
  const AppUpdateGate({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppUpdateGate> createState() => _AppUpdateGateState();
}

class _AppUpdateGateState extends ConsumerState<AppUpdateGate> {
  late final AppLifecycleListener _lifecycle;
  AppVersion? _offeredVersion;

  AppUpdateController get _controller =>
      ref.read(appUpdateControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => _controller.check(throttled: true),
    );
    // Tidak menahan layar awal: cek berjalan setelah frame pertama.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.check();
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AppUpdateStatus>(appUpdateControllerProvider, (_, next) {
      if (next is AppUpdateForced) {
        // Layar lain dan sheet di atas gerbang ikut ditutup.
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else if (next is AppUpdateOptional && next.version != _offeredVersion) {
        _offeredVersion = next.version;
        _offer(next);
      }
    });

    final status = ref.watch(appUpdateControllerProvider);
    if (status is AppUpdateForced) return ForceUpdateScreen(status: status);
    return widget.child;
  }

  Future<void> _offer(AppUpdateOptional offer) async {
    final update = await showUpdateAvailableSheet(context, offer);
    if (!mounted) return;
    if (update == true) {
      _controller.acknowledge();
      await openAppStore(context, offer.storeUrl);
    } else {
      await _controller.dismiss(offer.version);
    }
  }
}

final FutureProvider<PackageInfo> _installedInfoProvider =
    FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

/// `78 · Wajib update` — tidak dapat ditutup, termasuk dengan tombol kembali.
class ForceUpdateScreen extends ConsumerWidget {
  const ForceUpdateScreen({required this.status, super.key});

  final AppUpdateForced status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final installed = ref.watch(_installedInfoProvider).valueOrNull?.version;
    final installedLabel = installed == null
        ? ''
        : (AppVersion.tryParse(installed)?.toString() ?? installed);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: MealoraColors.background,
        body: MealoraBlobBackdrop(
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      MealoraSpacing.programHeroGutter,
                      MealoraSpacing.lg,
                      MealoraSpacing.programHeroGutter,
                      MealoraSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          text.appUpdateForcedEyebrow,
                          style: MealoraTypography.eyebrow,
                        ),
                        const SizedBox(height: MealoraSpacing.xs),
                        Text(
                          text.appUpdateForcedTitle,
                          style: MealoraTypography.title,
                        ),
                        const SizedBox(height: MealoraSpacing.xxs),
                        Text(
                          text.appUpdateForcedSubtitle,
                          style: MealoraTypography.subtitle,
                        ),
                        const SizedBox(height: MealoraSpacing.lg),
                        MealoraNoteCard(
                          icon: Icons.sync_rounded,
                          title: installedLabel.isEmpty
                              ? null
                              : text.appUpdateForcedCardTitle(installedLabel),
                          body: text.appUpdateForcedCardBody,
                          background: MealoraColors.noteWarning,
                          foreground: MealoraColors.amberText,
                        ),
                        if (status.releaseNotes.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: MealoraSpacing.lg),
                          Text(
                            text.appUpdateReleaseNotesHeading,
                            style: MealoraTypography.sectionTitle,
                          ),
                          const SizedBox(height: MealoraSpacing.xs),
                          MealoraCard(
                            child: Text(
                              status.releaseNotes.trim(),
                              style: MealoraTypography.body,
                            ),
                          ),
                        ],
                        const SizedBox(height: MealoraSpacing.md),
                        MealoraNoteCard(
                          icon: Icons.info_outline_rounded,
                          title: text.appUpdateDataSafeTitle,
                          body: text.appUpdateDataSafeBody,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    MealoraSpacing.screenGutter,
                    0,
                    MealoraSpacing.screenGutter,
                    MealoraSpacing.lg,
                  ),
                  child: MealoraPrimaryButton(
                    label: _storeActionLabel(text),
                    icon: Icons.open_in_new_rounded,
                    onPressed: () => openAppStore(context, status.storeUrl),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `79 · Update tersedia`; `true` bila pengguna memilih Update, `false`
/// untuk Nanti, null bila sheet ditutup tanpa memilih (dianggap Nanti).
Future<bool?> showUpdateAvailableSheet(
  BuildContext context,
  AppUpdateOptional offer,
) => showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  backgroundColor: MealoraColors.sheetSurface,
  barrierColor: MealoraColors.modalScrim,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(MealoraRadius.sheet),
    ),
  ),
  builder: (_) => _UpdateAvailableSheet(offer: offer),
);

class _UpdateAvailableSheet extends StatelessWidget {
  const _UpdateAvailableSheet({required this.offer});

  final AppUpdateOptional offer;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final notes = offer.releaseNotes.trim();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MealoraSpacing.lg,
          MealoraSpacing.sm,
          MealoraSpacing.lg,
          MealoraSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: MealoraSpacing.md),
                decoration: BoxDecoration(
                  color: MealoraColors.line,
                  borderRadius: BorderRadius.circular(
                    MealoraRadius.sheetHandle,
                  ),
                ),
              ),
            ),
            Text(
              text.appUpdateAvailableTitle,
              style: MealoraTypography.headline,
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            Text(
              text.appUpdateAvailableBody('${offer.version}'),
              style: MealoraTypography.bodySmall,
            ),
            const SizedBox(height: MealoraSpacing.md),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: MealoraColors.iconField,
                borderRadius: BorderRadius.circular(MealoraRadius.iconField),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: MealoraColors.primaryDeep,
              ),
            ),
            if (notes.isNotEmpty) ...<Widget>[
              const SizedBox(height: MealoraSpacing.md),
              MealoraNoteCard(icon: Icons.checklist_rounded, body: notes),
            ],
            const SizedBox(height: MealoraSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(
                        MealoraTouch.minTarget + 8,
                      ),
                      backgroundColor: MealoraColors.surface,
                      foregroundColor: MealoraColors.ink,
                      side: const BorderSide(color: MealoraColors.line),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          MealoraRadius.button,
                        ),
                      ),
                    ),
                    child: Text(
                      text.appUpdateLater,
                      style: MealoraTypography.button.copyWith(
                        color: MealoraColors.ink,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: MealoraSpacing.sm),
                Expanded(
                  child: MealoraPrimaryButton(
                    label: text.appUpdateNow,
                    onPressed: () => Navigator.of(context).pop(true),
                    icon: null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
