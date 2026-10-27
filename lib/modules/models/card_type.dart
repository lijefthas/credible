// AUTHOR: L. I. Jefthas
// DATE: October 2026

/// Supported card networks, each with its display label and CVV length.
enum CardType {
  visa('Visa', 3),
  mastercard('Mastercard', 3),
  amex('American Express', 4),
  discover('Discover', 3),
  dinersClub('Diners Club', 3),
  jcb('JCB', 3),
  unionPay('UnionPay', 3),
  maestro('Maestro', 3),
  unknown('Unknown', 4);

  const CardType(this.label, this.cvvLength);

  final String label;
  final int cvvLength;

  /// Card types that can be picked manually in the form.
  static List<CardType> get selectable =>
      values.where((type) => type != CardType.unknown).toList();
}
