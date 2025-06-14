class StringUtils {
  /// تحويل الأرقام العربية إلى أرقام إنجليزية
  static String convertArabicToEnglishNumbers(String input) {
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];

    for (int i = 0; i < arabic.length; i++) {
      input = input.replaceAll(arabic[i], english[i]);
    }

    return input;
  }

  /// تحويل النص إلى رقم مع دعم الأرقام العربية
  static double parseDouble(String text) {
    final convertedText = convertArabicToEnglishNumbers(text);
    return double.parse(convertedText);
  }

  /// تحويل النص إلى عدد صحيح مع دعم الأرقام العربية
  static int parseInt(String text) {
    final convertedText = convertArabicToEnglishNumbers(text);
    return int.parse(convertedText);
  }
}
