import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recyclo/auth/auth_service.dart';
import 'package:recyclo/auth/login_screen.dart';
import 'package:recyclo/history.dart';
import 'package:recyclo/profile_page.dart';
import 'package:recyclo/qr_scan_page.dart';
import 'dart:async';

import 'package:recyclo/voucher_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final auth = AuthService();
  String name = "";
  int points = 0;
  int bottles = 0;
  bool isLoading = true;
  int _selectedIndex = 0;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0;
  late Timer _timer;
  List<Map<String, dynamic>> redeemHistory = [];
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchUserData();
    if (user != null) {
      _fetchRedeemHistory();
    }
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % 2;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _fetchUserData() async {
    try {
      user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('user')
            .doc(user!.uid)
            .get();

        if (userData.exists) {
          setState(() {
            name = userData['name'] ?? "User";
            points = userData['points'] ?? 0;
            bottles = userData['botol'] ?? 0;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        name = "Error";
        isLoading = false;
      });
    }
  }

  Future<void> _fetchRedeemHistory() async {
    print("Entered _fetchRedeemHistory function");
  if (user != null) {
    print("Fetching redeem history for user UID: ${user!.uid}");
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("user")  // Check this collection name!
          .doc(user!.uid)
          .collection("redeem_history")
          .orderBy("timestamp", descending: true)
          .get(); 

      print("Documents fetched: ${snapshot.docs.length}");
      if (snapshot.docs.isEmpty) {
        print("No redeem history found.");
      } else {
        for (var doc in snapshot.docs) {
          print("Doc ID: ${doc.id}, Data: ${doc.data()}");
        }
      }

      setState(() {
        redeemHistory = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Error fetching redeem history: $e");
    }
  } else {
    print("User is null, cannot fetch redeem history");
  }
}

  void _logout() async {
    await auth.signout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Home - no navigation, just update index
        break;
      case 1:
        _navigateToScanQR(context);
        break;
      case 2:
        _navigateToRedeemPointsPage(context);
        break;
      case 3:
        _navigateToProfile(context);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF3E4CFF), Color(0xFF2C34FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(30)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Hello, $name 👋",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Lexend')),
                              IconButton(
                                onPressed: _logout,
                                icon: const Icon(Icons.logout, color: Colors.white),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text("Welcome back to Recyclo!",
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  fontFamily: 'Lexend')),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Banners
                    SizedBox(
                      height: 150,
                      child: PageView(
                        controller: _pageController,
                        children: [
                          _buildBanner("images/banner1.png"),
                          _buildBanner("images/banner2.png"),
                        ],
                      ),
                    ),

                    // Points and Bottles
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _infoCard("Points", points.toString(), Icons.stars),
                          _infoCard("Bottles", bottles.toString(), Icons.local_drink),
                        ],
                      ),
                    ),

                    // Redeem History Section
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(
                        "Recent Redeems",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: redeemHistory.isEmpty
                            ? [const Text("No redeem history yet.")]
                            : redeemHistory.map((entry) => _redeemCard(entry)).toList(),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
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
          // BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildBanner(String image) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          )
        ],
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _infoCard(String title, String value, IconData icon) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.indigoAccent),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 14, fontFamily: 'Lexend')),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Lexend')),
        ],
      ),
    );
  }

 Widget _redeemCard(Map<String, dynamic> entry) {
  final timestamp = entry['timestamp'] as Timestamp?;
  final formattedDate = timestamp != null
      ? "${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}"
      : "Unknown date";

  final String voucherName = entry['title'] ?? "Redeem item";
  // final int pointsSpent = entry['points'] ?? 0;
  final String? logoUrl = entry['imageURL'];
  
  return Card(
    margin: const EdgeInsets.only(bottom: 10),
    child: ListTile(
      leading: logoUrl != null
          ? CircleAvatar(
              backgroundImage: NetworkImage(logoUrl),
              backgroundColor: Colors.transparent,
            )
          : CircleAvatar(
              child: Icon(Icons.card_giftcard, color: Colors.white),
              backgroundColor: Colors.blueAccent,
            ),
      title: Text(
        voucherName,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      
      trailing: Text(
        formattedDate,
        style: const TextStyle(color: Colors.grey),
      ),
    ),
  );
}

  void _navigateToScanQR(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const QRScanner()));
  }

  void _navigateToRedeemPointsPage(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const VoucherPage()));
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }
}
