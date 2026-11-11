import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Menerjemahkan [LabelServiceFailureReason] menjadi bahasa yang dapat
/// dimengerti pengguna (task 4.2, spec image-ai-access "Kegagalan layanan
/// selalu bermuara ke jalur manual").
///
/// SATU-SATUNYA tempat di aplikasi yang memetakan alasan kegagalan ke teks
/// — layar foto label (`23`) dan layar tinjau ekstraksi (`24`) SHALL
/// memanggil ini, bukan menyusun pesannya sendiri, supaya bahasanya
/// konsisten dan tidak ada yang diam-diam menyelipkan kode error atau
/// istilah teknis.
String labelExtractionFailureHeadline(
  AppText text,
  LabelServiceFailureReason reason,
) => switch (reason) {
  LabelServiceFailureReason.offline => text.labelExtractionReasonOffline,
  LabelServiceFailureReason.timeout => text.labelExtractionReasonTimeout,
  LabelServiceFailureReason.quotaExceeded =>
    text.labelExtractionReasonQuotaExceeded,
  LabelServiceFailureReason.refused => text.labelExtractionReasonRefused,
};
