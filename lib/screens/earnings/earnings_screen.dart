import 'package:flutter/material.dart';

import '../payments/payments_screen.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Redirect to the new integrated payments screen
    // This provides a unified experience for earnings and payments
    return const PaymentsScreen();
  }
}