import 'package:flutter/material.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';

/// Lembar pilihan generik: takaran saji, waktu makan, atau daftar sejenis
/// yang dipilih satu (dipakai layar `14`/`17`, change 007).
class OptionSheet<T> extends StatelessWidget {
  const OptionSheet({
    required this.title,
    required this.options,
    required this.labelOf,
    required this.selected,
    super.key,
  });

  final String title;
  final List<T> options;
  final String Function(T) labelOf;
  final T selected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(MealoraSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: MealoraTypography.sectionTitle),
            const SizedBox(height: MealoraSpacing.sm),
            for (final option in options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(labelOf(option), style: MealoraTypography.body),
                trailing: MealoraCircleCheck(selected: option == selected),
                onTap: () => Navigator.of(context).pop(option),
              ),
          ],
        ),
      ),
    );
  }
}
