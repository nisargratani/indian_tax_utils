class DiscountCalculator {
  static double percentage({
    required double amount,
    required double percent,
  }) {
    return amount * percent / 100;
  }

  static double fixed({
    required double amount,
    required double discount,
  }) {
    return amount - discount;
  }
}
