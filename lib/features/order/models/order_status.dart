/// Where an order is in its life cycle.
enum OrderStatus {
  confirmed('confirmed', 'Confirmed'),
  shipped('shipped', 'Shipped'),
  delivered('delivered', 'Delivered'),
  cancelled('cancelled', 'Cancelled');

  final String value;
  final String label;

  const OrderStatus(this.value, this.label);

  static OrderStatus fromValue(String? value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.confirmed,
    );
  }
}

/// Whether the order has been paid for.
enum PaymentStatus {
  unpaid('unpaid', 'Pay on delivery'),
  paid('paid', 'Paid');

  final String value;
  final String label;

  const PaymentStatus(this.value, this.label);

  static PaymentStatus fromValue(String? value) {
    return PaymentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => PaymentStatus.unpaid,
    );
  }
}
