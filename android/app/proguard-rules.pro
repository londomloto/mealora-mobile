# google_mlkit_text_recognition mereferensikan pengenal teks Chinese,
# Devanagari, Japanese, dan Korean. App hanya memakai pengenal Latin, jadi
# dependensi bahasa itu tidak disertakan; R8 cukup diberi tahu agar tidak
# gagal karena class yang memang tidak ada.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
