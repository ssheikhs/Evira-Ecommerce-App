import 'package:flutter/material.dart';

/// Ways a customer can pay at checkout.
enum PaymentMethod {
  cashOnDelivery(
    value: 'cash_on_delivery',
    title: 'Cash on Delivery',
    subtitle: 'Pay in cash when your order arrives',
    icon: Icons.payments_outlined,
  ),
  aamarPay(
    value: 'aamarpay',
    title: 'aamarPay',
    subtitle: 'bKash, Nagad, Rocket or card (sandbox)',
    icon: Icons.account_balance_wallet_outlined,
  );

  final String value;
  final String title;
  final String subtitle;
  final IconData icon;

  const PaymentMethod({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  bool get isOnline => this == PaymentMethod.aamarPay;

  static PaymentMethod fromValue(String? value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => PaymentMethod.cashOnDelivery,
    );
  }
}
