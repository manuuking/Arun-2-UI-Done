class GstCalculator {
  static const double defaultGstRate = 5.0; // 5% total (2.5% CGST + 2.5% SGST)

  static double calculateGstAmount(double amount, double rate) {
    return (amount * rate) / 100.0;
  }

  static Map<String, double> calculateTaxes({
    required double amount,
    required bool isInterState, // true for IGST, false for CGST+SGST
    double totalRate = defaultGstRate,
  }) {
    if (isInterState) {
      return {
        'cgst': 0.0,
        'sgst': 0.0,
        'igst': calculateGstAmount(amount, totalRate),
      };
    } else {
      double halfRate = totalRate / 2;
      return {
        'cgst': calculateGstAmount(amount, halfRate),
        'sgst': calculateGstAmount(amount, halfRate),
        'igst': 0.0,
      };
    }
  }

  static double getRoundOff(double grandTotalWithoutRoundoff) {
    double rounded = grandTotalWithoutRoundoff.roundToDouble();
    return rounded - grandTotalWithoutRoundoff;
  }
}
