import 'package:flutter/material.dart';

class RecyclingTipsScreen extends StatelessWidget {
  const RecyclingTipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text("QR Scan Page", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Icon(Icons.qr_code, size: 50, color: Colors.green),
        ],
      ),
    );
  }
}
