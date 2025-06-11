import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:recyclo/qr_scan_page.dart';

// Tambah Firebase packages:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRResult extends StatefulWidget {
  final String code;
  final Function() closeScreen;

  const QRResult({
    super.key,
    required this.code,
    required this.closeScreen,
  });

  @override
  State<QRResult> createState() => _QRResultState();
}

class _QRResultState extends State<QRResult> {
  bool isUpdating = false;
  int updatedPoints = 0;
  int updatedBottles = 0;

  @override
  void initState() {
    super.initState();
    updateUserData();
  }

  Future<void> updateUserData() async {
    setState(() {
      isUpdating = true;
    });

    try {
      // Dapatkan current user id
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }
      final userId = user.uid;

      // Contoh: Parse 'code' untuk dapatkan jumlah botol (contoh: code = "bottle:3")
      int bottleCount = 1; // default 1 bottle if no parsing
      final codeParts = widget.code.split(':');
      if (codeParts.length == 2 && codeParts[0].toLowerCase() == 'botol') {
        bottleCount = int.tryParse(codeParts[1]) ?? 1;
      }

      final userDoc = FirebaseFirestore.instance.collection('user').doc(userId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDoc);

        int currentPoints = 0;
        int currentBottles = 0;
        if (snapshot.exists) {
          currentPoints = snapshot.get('points') ?? 0;
          currentBottles = snapshot.get('botol') ?? 0;
        }

        final newPoints = currentPoints + (bottleCount * 100); // 1 bottle = 100 points
        final newBottles = currentBottles + bottleCount;
        final now = DateTime.now();

        transaction.set(userDoc, {
          'points': newPoints,
          'botol': newBottles,
          'timestamp': now.toIso8601String(),
        }, SetOptions(merge: true));

        setState(() {
          updatedPoints = newPoints;
          updatedBottles = newBottles;
        });
      });
    } catch (e) {
      print("Error updating user data: $e");
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return QRScanner();
                },
              ),
            );
          },
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
        ),
        centerTitle: true,
        title: Text(
          "Scanned Result",
          style: TextStyle(
            color: Colors.white,
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Column(
            children: [
              SizedBox(height: 120),
              QrImageView(
                data: widget.code,
                size: 300,
                version: QrVersions.auto,
              ),
              SizedBox(height: 20),
              Text(
                "Scanned QR",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.code,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 20),

              if (isUpdating)
                CircularProgressIndicator()
              else
                Column(
                  children: [
                    Text(
                      "Points: $updatedPoints",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Bottles: $updatedBottles",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

              SizedBox(height: 20),

              SizedBox(
                width: MediaQuery.of(context).size.width - 150,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                  child: Text(
                    "Copy",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
