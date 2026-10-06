class NumberToWords {
  static const List<String> _ones = [
    "",
    "One",
    "Two",
    "Three",
    "Four",
    "Five",
    "Six",
    "Seven",
    "Eight",
    "Nine",
    "Ten",
    "Eleven",
    "Twelve",
    "Thirteen",
    "Fourteen",
    "Fifteen",
    "Sixteen",
    "Seventeen",
    "Eighteen",
    "Nineteen",
  ];

  static const List<String> _tens = [
    "",
    "",
    "Twenty",
    "Thirty",
    "Forty",
    "Fifty",
    "Sixty",
    "Seventy",
    "Eighty",
    "Ninety",
  ];

  static String _convertLessThanOneThousand(int number) {
    String current = "";

    if (number % 100 < 20) {
      current = _ones[number % 100];
      number ~/= 100;
    } else {
      current = _ones[number % 10];
      number ~/= 10;

      current = "${_tens[number % 10]} $current";
      number ~/= 10;
    }

    if (number == 0) return current.trim();
    return "${_ones[number]} Hundred $current".trim();
  }

  static String convert(double number) {
    if (number == 0) return "Zero";

    int amount = number.floor();
    int paise = ((number - amount) * 100).round();

    String result = "";

    if (amount >= 10000000) {
      result += "${_convertLessThanOneThousand(amount ~/ 10000000)} Crore ";
      amount %= 10000000;
    }
    if (amount >= 100000) {
      result += "${_convertLessThanOneThousand(amount ~/ 100000)} Lakh ";
      amount %= 100000;
    }
    if (amount >= 1000) {
      result += "${_convertLessThanOneThousand(amount ~/ 1000)} Thousand ";
      amount %= 1000;
    }

    result += _convertLessThanOneThousand(amount);

    String finalResult = result.trim();

    if (paise > 0) {
      finalResult += " and ${_convertLessThanOneThousand(paise)} Paise";
    }

    return "$finalResult Only";
  }
}
