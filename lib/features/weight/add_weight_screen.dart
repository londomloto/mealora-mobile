import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/weight/weight_record.dart';
import 'package:mealora/features/weight/weight_controller.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `32 · Tambah berat` — mencatat satu nilai berat untuk sebuah tanggal
/// (change 008, design D1/D9).
///
/// Berbeda dari lembar makan (change 007): tidak ada pilihan takaran atau
/// katalog — hanya nilai, tanggal, dan catatan bebas opsional. Dibuka lewat
/// push biasa (bukan tab utama), ditutup dengan `pop(true)` saat berhasil
/// supaya pemanggil tahu kapan harus membaca ulang penyimpanan.
class AddWeightScreen extends ConsumerStatefulWidget {
  const AddWeightScreen({this.existingRecord, super.key});

  /// Catatan yang sedang disunting, atau `null` untuk menambah catatan baru
  /// (task 4.8 — layar yang sama dipakai menyunting dari daftar catatan
  /// terakhir).
  final WeightRecord? existingRecord;

  @override
  ConsumerState<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends ConsumerState<AddWeightScreen> {
  late final TextEditingController _weightController;
  late final TextEditingController _noteController;
  late DateTime _date;
  String? _weightError;
  String? _dateError;
  bool _saving = false;

  bool get _isEditing => widget.existingRecord != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingRecord;
    _weightController = TextEditingController(
      text: existing == null
          ? ''
          : existing.weightKg.toString().replaceAll('.', ','),
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
    final today = ref.read(clockProvider).today();
    _date = existing == null
        ? DateTime(today.year, today.month, today.day)
        : DateTime(
            existing.localDate.year,
            existing.localDate.month,
            existing.localDate.day,
          );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final today = ref.watch(clockProvider).today();
    final todayDateTime = DateTime(today.year, today.month, today.day);

    return Scaffold(
      backgroundColor: MealoraColors.background,
      appBar: AppBar(
        backgroundColor: MealoraColors.background,
        elevation: 0,
        title: Text(
          _isEditing ? text.weightEditTitle : text.weightAddTitle,
          style: MealoraTypography.sectionTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            MealoraSpacing.screenGutter,
            MealoraSpacing.sm,
            MealoraSpacing.screenGutter,
            MealoraSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(text.weightAddSubtitle, style: MealoraTypography.subtitle),
              const SizedBox(height: MealoraSpacing.lg),
              MealoraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      text.weightValueLabel,
                      style: MealoraTypography.compactFieldLabel,
                    ),
                    const SizedBox(height: MealoraSpacing.xxs),
                    _WeightValueInput(
                      controller: _weightController,
                      hasError: _weightError != null,
                    ),
                    if (_weightError != null) ...<Widget>[
                      const SizedBox(height: MealoraSpacing.xxs),
                      _InlineError(message: _weightError!),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: MealoraSpacing.md),
              MealoraDateField(
                label: text.weightDateLabel,
                hint: text.weightDateHint,
                value: _date,
                firstDate: todayDateTime.subtract(const Duration(days: 3650)),
                lastDate: todayDateTime,
                errorText: _dateError,
                onChanged: (picked) => setState(() {
                  _date = picked;
                  _dateError = null;
                }),
              ),
              const SizedBox(height: MealoraSpacing.md),
              MealoraField(
                label: text.weightNoteLabel,
                hint: text.weightNoteHint,
                controller: _noteController,
              ),
              const SizedBox(height: MealoraSpacing.md),
              MealoraNoteCard(
                icon: Icons.lock_outline,
                body: text.weightLocalOnlyNote,
              ),
              const SizedBox(height: MealoraSpacing.xl),
              MealoraPrimaryButton(
                label: text.weightSaveAction,
                onPressed: _saving ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final rawWeight = _weightController.text.trim().replaceAll(',', '.');
    final weightKg = double.tryParse(rawWeight);
    final text = AppText.of(context);
    if (weightKg == null) {
      setState(() => _weightError = text.weightInvalidNumberError);
      return;
    }

    setState(() {
      _saving = true;
      _weightError = null;
      _dateError = null;
    });

    final date = LocalDate(_date.year, _date.month, _date.day);
    final note = _noteController.text.trim();
    final repository = ref.read(weightRepositoryProvider);
    final existing = widget.existingRecord;
    final result = existing == null
        ? await repository.addRecord(
            profileId: (await ref.read(currentProfileProvider.future))!.id,
            date: date,
            weightKg: weightKg,
            note: note.isEmpty ? null : note,
          )
        : await repository.updateRecord(
            recordId: existing.id,
            date: date,
            weightKg: weightKg,
            note: note.isEmpty ? null : note,
          );

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok<WeightRecord>():
        bumpWeightRefresh(ref);
        Navigator.of(context).pop(true);
      case Err<WeightRecord>(:final failure):
        setState(() {
          _saving = false;
          _applyFailure(failure, text);
        });
    }
  }

  void _applyFailure(Failure failure, AppText text) {
    if (failure.field == 'localDate') {
      _dateError = text.weightFutureDateError;
      return;
    }
    _weightError = text.weightOutOfRangeError;
  }
}

/// Nilai berat besar yang dapat disunting, dengan unit "kg" di sampingnya —
/// mengikuti rancangan `32` (angka besar, bukan kolom isian biasa).
class _WeightValueInput extends StatelessWidget {
  const _WeightValueInput({required this.controller, required this.hasError});

  final TextEditingController controller;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final inputWidth = (value.text.length * 26.0 + 16)
            .clamp(56.0, 160.0)
            .toDouble();
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            SizedBox(
              width: inputWidth,
              child: TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: MealoraTypography.display.copyWith(
                  color: hasError ? MealoraColors.danger : MealoraColors.ink,
                ),
                decoration: const InputDecoration(
                  filled: false,
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(width: MealoraSpacing.xs),
            Padding(
              padding: const EdgeInsets.only(bottom: MealoraSpacing.xs),
              child: Text(text.weightUnitKg, style: MealoraTypography.body),
            ),
          ],
        );
      },
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.error_outline,
            size: MealoraIconSize.inline,
            color: MealoraColors.danger,
          ),
          const SizedBox(width: MealoraSpacing.xxs),
          Expanded(
            child: Text(
              message,
              style: MealoraTypography.caption.copyWith(
                color: MealoraColors.danger,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
