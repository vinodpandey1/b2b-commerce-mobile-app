import 'package:flutter/material.dart';

class PaymentDefaultCard extends StatelessWidget {
  const PaymentDefaultCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF183B56), Color(0xFF0B172A)],
          ),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'EazySupplies',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Spacer(),
            Text(
              '••••  ••••  ••••  5456',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'CARD HOLDER',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                Text('MM/YY', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
