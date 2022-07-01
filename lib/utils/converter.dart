List<String> persianChars = ['آ', 'ا', 'ب', 'پ', 'ت', 'ث', 'ج', 'چ', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'ژ', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ک', 'گ', 'ل', 'م', 'ن', 'و', 'ه', 'ی', '‌', '۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
List<String> persianNums = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
String normalize(String text) {
  for (int i = 0; i < persianChars.length; i++) {
    text = text.replaceAll(".$i.", persianChars[i]);
  }
  return text;
}

String unNormalize(String text) {
  for (int i = 0; i < persianChars.length; i++) {
    text = text.replaceAll(persianChars[i], ".$i.");
  }
  return text;
}

String persianNumber(int price) {
  String p = price.toString();
  for (int i = 0; i < persianNums.length; i++) {
    p = p.replaceAll(i.toString(), persianNums[i]);
  }
  p = p.split('').reversed.join();
  String a = "";
  for (int i = 0; i < p.length; i++) {
    a += p[i];
    if ((i + 1) % 3 == 0 && i != p.length - 1) a += ",";
  }
  return a.split('').reversed.join();
}

String englishToPersian(String s) {
  String p = "";
  for (int i = 0; i < s.length; i++) {
    p += persianNums[int.parse(s[i])];
  }
  return p;
}