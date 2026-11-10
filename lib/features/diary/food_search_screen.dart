import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/recent_food.dart';
import 'package:mealora/features/diary/custom_food_screen.dart';
import 'package:mealora/features/diary/diary_format.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/serving_detail_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `13 · Cari makanan` (task 6.1–6.4): pencarian luring dengan bagian
/// "terakhir dicatat" dan pintasan Favorit yang ditandai belum tersedia.
class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({this.date, super.key});

  /// Tanggal yang akan dicatat — `null` berarti hari ini (konvensi
  /// `logFoodEntry`, change 008 task 5.6).
  final LocalDate? date;

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              MealoraSpacing.programHeroGutter,
              MealoraSpacing.lg,
              MealoraSpacing.programHeroGutter,
              MealoraSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  text.foodSearchContextLabel,
                  style: MealoraTypography.eyebrow,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.foodSearchTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.foodSearchSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                _SearchField(
                  controller: _controller,
                  hint: text.foodSearchHint,
                  clearSemantics: text.foodSearchClearSemantics,
                  onChanged: (value) => setState(() => _query = value.trim()),
                ),
                const SizedBox(height: MealoraSpacing.xl),
                if (_query.isEmpty)
                  _RecentSection(text: text, date: widget.date)
                else
                  _ResultsSection(query: _query, text: text, date: widget.date),
                const SizedBox(height: MealoraSpacing.lg),
                Semantics(
                  button: true,
                  child: InkWell(
                    onTap: () => _openCustomFood(context),
                    child: Text(
                      text.foodSearchCreateLink,
                      style: MealoraTypography.bodyEmphasis.copyWith(
                        color: MealoraColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Align(
                  alignment: Alignment.centerRight,
                  child: Semantics(
                    button: true,
                    label:
                        '${text.foodSearchFavoritesLabel}. ${text.foodSearchFavoritesUnavailable}',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(MealoraRadius.chip),
                      onTap: () => _announceFavoritesUnavailable(context, text),
                      child: MealoraCard(
                        radius: MealoraRadius.chip,
                        padding: const EdgeInsets.symmetric(
                          horizontal: MealoraSpacing.md,
                          vertical: MealoraSpacing.sm,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.star_border_rounded,
                              size: 16,
                              color: MealoraColors.accent,
                            ),
                            const SizedBox(width: MealoraSpacing.xs),
                            Text(
                              text.foodSearchFavoritesLabel,
                              style: MealoraTypography.bodyEmphasis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openCustomFood(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomFoodScreen(date: widget.date),
      ),
    );
  }

  void _announceFavoritesUnavailable(BuildContext context, AppText text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text.foodSearchFavoritesUnavailable),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.clearSemantics,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final String clearSemantics;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: MealoraCard(
        radius: MealoraRadius.button,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.search,
              size: 18,
              color: MealoraColors.primaryDeep,
            ),
            const SizedBox(width: MealoraSpacing.sm),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: MealoraTypography.bodyEmphasis,
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: MealoraTypography.bodyMuted,
                  filled: false,
                  fillColor: MealoraColors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              Semantics(
                button: true,
                label: clearSemantics,
                child: InkWell(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: MealoraColors.affordance,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentSection extends ConsumerWidget {
  const _RecentSection({required this.text, this.date});

  final LocalDate? date;

  final AppText text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentFoodsProvider);
    return recent.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (items) {
        if (items.isEmpty) {
          // Pengguna baru: bagian ini kosong, tidak diisi contoh (task 6.3).
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              text.foodSearchRecentHeading,
              style: MealoraTypography.sectionTitle,
            ),
            const SizedBox(height: MealoraSpacing.sm),
            MealoraCard(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: <Widget>[
                  for (var i = 0; i < items.length; i++) ...<Widget>[
                    if (i > 0) const Divider(height: 1),
                    _RecentRow(item: items[i], text: text, date: date),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.item, required this.text, this.date});

  final RecentFood item;
  final AppText text;
  final LocalDate? date;

  @override
  Widget build(BuildContext context) {
    final detail = text.foodSearchApproxPerServing(
      DiaryFormat.kcal(item.lastServing.nutrition.energy, text),
      item.lastServing.label,
    );
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ServingDetailScreen(
            food: item.food,
            initialServing: item.lastServing,
            date: date,
          ),
        ),
      ),
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MealoraSpacing.md),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MealoraColors.iconFieldAmber,
                  borderRadius: BorderRadius.circular(
                    MealoraRadius.compactIconField,
                  ),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  size: MealoraIconSize.action,
                  color: MealoraColors.accent,
                ),
              ),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.food.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MealoraTypography.bodyEmphasis.copyWith(
                        height: 1.2,
                      ),
                    ),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MealoraTypography.caption.copyWith(height: 1.2),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MealoraColors.iconFieldGreen,
                  borderRadius: BorderRadius.circular(
                    MealoraRadius.compactIconField,
                  ),
                ),
                child: const Icon(
                  Icons.add,
                  size: MealoraIconSize.action,
                  color: MealoraColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsSection extends ConsumerWidget {
  const _ResultsSection({required this.query, required this.text, this.date});

  final String query;
  final AppText text;
  final LocalDate? date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(foodSearchProvider(query));
    return results.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: MealoraSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (foods) {
        if (foods.isEmpty) {
          return MealoraEmptyState(
            title: text.foodSearchNoResultsTitle,
            body: text.foodSearchNoResultsBody,
            icon: Icons.search_off_rounded,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              text.foodSearchResultsHeading(query),
              style: MealoraTypography.sectionTitle,
            ),
            const SizedBox(height: MealoraSpacing.sm),
            MealoraCard(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: <Widget>[
                  for (var i = 0; i < foods.length; i++) ...<Widget>[
                    if (i > 0) const Divider(height: 1),
                    _ResultRow(food: foods[i], text: text, date: date),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.food, required this.text, this.date});

  final Food food;
  final AppText text;
  final LocalDate? date;

  @override
  Widget build(BuildContext context) {
    final serving = food.defaultServing;
    final detail = food.isUserCreated
        ? '${serving.label} · ${text.foodSearchCustomDataLabel}'
        : '${serving.label} · ${text.foodSearchCatalogDataLabel}';
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ServingDetailScreen(food: food, date: date),
        ),
      ),
      child: SizedBox(
        height: 52,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: MealoraSpacing.md),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      food.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MealoraTypography.bodyEmphasis.copyWith(
                        height: 1.2,
                      ),
                    ),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MealoraTypography.caption.copyWith(height: 1.2),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: MealoraColors.affordance,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
