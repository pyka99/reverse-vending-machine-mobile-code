import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:recyclo/home_screen.dart';
import 'package:recyclo/profile_page.dart';
import 'package:recyclo/qr_scan_page.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({Key? key}) : super(key: key);

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  int userPoints = 0;
  int userBottles = 0;
 int _selectedIndex = 2;
 final userId = FirebaseAuth.instance.currentUser!.uid;
  @override
  void initState() {
    super.initState();
    fetchUserData();
  }
void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        _navigateToHome(context);
        break;
      case 1:
        _navigateToScanQR(context);
        break;
      case 2:
        break;
      case 3:
        _navigateToProfile(context);
        break;
    }
  }

  void fetchUserData() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    print("Fetching user data for UID: ${user.uid}");
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('user').doc(user.uid).get();

    if (userDoc.exists) {
      setState(() {
        userPoints = userDoc.get('points') ?? 0;
        userBottles = userDoc.get('botol') ?? 0;
      });
      print("User points: $userPoints, User bottles: $userBottles");
    } else {
      print("User document does not exist");
    }
  } else {
    print("No user is currently signed in");
  }
}

void _redeemVoucherFirestore(String docId, int pointsRequired) async {
  print("Attempting to redeem voucher ID: $docId for $pointsRequired points");
  if (userPoints >= pointsRequired) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final voucherDoc = await FirebaseFirestore.instance.collection('voucher').doc(docId).get();
      final voucherData = voucherDoc.data() as Map<String, dynamic>;
      final String voucherTitle = voucherData['title'] ?? 'Untitled';

      print("Voucher title: $voucherTitle");

      // Kurangkan mata
      setState(() {
        userPoints -= pointsRequired;
      });

      print("New user points after redeem: $userPoints");

      // Kemas kini data pengguna
      await FirebaseFirestore.instance.collection('user').doc(user.uid).update({
        "points": userPoints,
      });

      print("User points updated in Firestore");

      

        await FirebaseFirestore.instance
          .collection('user')
          .doc(userId)
          .collection('redeem_history')
          .add({
            'voucherId': docId,
            'title': voucherTitle,
            'timestamp': FieldValue.serverTimestamp(),
            'imageURL': voucherData['imageURL'] ?? '',
            
          });

      print("Redemption history added");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Successfully redeemed!"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      print("User not found during voucher redemption");
    }
  } else {
    print("Not enough points to redeem voucher");
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8FD), // Light blue background
      appBar: AppBar(
        automaticallyImplyLeading: false, // No back arrow
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "🎁 My Rewards",
          style: TextStyle(
            color: Color(0xFF326BBA), // Blue color
            fontWeight: FontWeight.bold,
            fontFamily: 'Lexend',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User points section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF326BBA), // Blue color
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  const Text(
                    "Your Points",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Lexend',
                    ),
                  ),
                  Text(
                    "$userPoints",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Vouchers section
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('voucher').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final vouchers = snapshot.data!.docs;

                  if (vouchers.isEmpty) {
                    return const Center(child: Text("No vouchers available"));
                  }

                  return ListView.builder(
                    itemCount: vouchers.length,
                    itemBuilder: (context, index) {
                      final voucher = vouchers[index];
                      final data = voucher.data() as Map<String, dynamic>;

                      final int pointsRequired = data['pointsRequired'] ?? 0;
                      final String title = data['title'] ?? 'No title';
                      final String imageUrl = data['imageURL'] ?? '';

                      final canRedeem = userPoints >= pointsRequired;

                      return Opacity(
                        opacity: canRedeem ? 1.0 : 0.6,
                        child: Card(
                          elevation: 5,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      width: 45,
                                      height: 45,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const Icon(Icons.broken_image, size: 45),
                                    )
                                  : const Icon(Icons.image_not_supported, size: 45),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              "$pointsRequired points required",
                              style: const TextStyle(fontFamily: 'Lexend'),
                            ),
                            trailing: ElevatedButton(
                              onPressed: canRedeem
                                  ? () => _redeemVoucherFirestore(voucher.id, pointsRequired)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: canRedeem ? Colors.blueAccent : Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              ),
                              child: const Text(
                                "Redeem",
                                style: TextStyle(
                                  fontFamily: 'Lexend',
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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

   void _navigateToScanQR(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const QRScanner()));
  }

 void _navigateToHome(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
  
  void _navigateToRedeemPointsPage(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const VoucherPage()));
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }
}
