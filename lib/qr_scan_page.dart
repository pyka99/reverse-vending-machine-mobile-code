import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_scanner_overlay/qr_scanner_overlay.dart';
import 'package:recyclo/qr_result.dart';
import 'package:recyclo/home_screen.dart';
import 'package:recyclo/profile_page.dart';
import 'package:recyclo/voucher_page.dart';

class QRScanner extends StatefulWidget {
  const QRScanner({super.key});
  
  @override
  _QRScannerState createState() => _QRScannerState();
}

class _QRScannerState extends State<QRScanner> {
  int _selectedIndex = 1;
  final MobileScannerController _cameraController = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  @override
  void initState() {
    super.initState();
    _cameraController.start();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) {
      _navigateToHome(context);
    } else if (index == 1) {
      // current page
    } else if (index == 2) {
      _navigateToRedeemPointsPage(context);
    } else if (index == 3) {
      _navigateToProfile(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Container(
            height: 300,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2934CA), Color(0xFF2332FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                     
                      const Text(
                        "QR Scanner",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Place the QR code in the designated area",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const Text(
                    "The scan starts automatically!",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  const SizedBox(height: 30),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        MobileScanner(
                          controller: _cameraController,
                          onDetect: (barcode) {
                            if (barcode.barcodes.isNotEmpty) {
                              final String code = barcode.barcodes.first.rawValue ?? "---";
                              _cameraController.stop();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QRResult(
                                    code: code,
                                    closeScreen: () {
                                      Navigator.pop(context);
                                      _cameraController.start();
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        QRScannerOverlay(
                          overlayColor: Colors.black26,
                          borderColor: Colors.white,
                          borderRadius: 20,
                          borderStrokeWidth: 5,
                          scanAreaWidth: 250,
                          scanAreaHeight: 250,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: "Scan"),
          BottomNavigationBarItem(icon: Icon(Icons.card_giftcard), label: "Redeem"),
        ],
      ),
    );
  }

  void _navigateToHome(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  void _navigateToRedeemPointsPage(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const VoucherPage()));
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }
}
