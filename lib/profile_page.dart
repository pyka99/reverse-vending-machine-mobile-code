import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recyclo/qr_scan_page.dart';
import 'package:recyclo/home_screen.dart';
import 'package:recyclo/voucher_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    else if (index == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const QRScanner()));
    else if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const VoucherPage()));
  }

  Future<Map<String, dynamic>> _fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance.collection('user').doc(user.uid).get();
        return {
          'name': userData['name'] ?? 'User',
          'points': userData['points'] ?? 0,
          'botol': userData['botol'] ?? 0,
        };
      }
    } catch (e) {
      print("Error: $e");
    }
    return {'name': 'Error', 'points': 0, 'botol': 0};
  }

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[700],
        title: Text('Profile', style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Lexend')),
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const Center(child: Text('User not logged in'))
          : FutureBuilder<Map<String, dynamic>>(
              future: _fetchUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data ?? {};
                final points = data['points'] ?? 0;
                final bottles = data['botol'] ?? 0;

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Icon(Icons.account_circle, size: 100, color: Colors.blue[700]),
                      const SizedBox(height: 20),
                      Text(data['name'] ?? 'No Name',
                          style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Lexend')),
                      const SizedBox(height: 5),
                      Text(user.email ?? '',
                          style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Lexend')),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _statCard('Points', points.toString(), Icons.star),
                          _statCard('Bottles', bottles.toString(), Icons.local_drink),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        icon: const Icon(Icons.logout),
                        label: Text('Log Out', style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Lexend')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                );
              },
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, color: Colors.blue[700], size: 32),
            const SizedBox(height: 10),
            Text(value, style: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(
            fontFamily: 'Lexend',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.white,
          ),),
          ],
        ),
      ),
    );
  }
}
