import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RedeemHistoryPage extends StatefulWidget {
  @override
  _RedeemHistoryPageState createState() => _RedeemHistoryPageState();
}

class _RedeemHistoryPageState extends State<RedeemHistoryPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> redeemHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRedeemHistory();
  }

  Future<void> _fetchRedeemHistory() async {
    try {
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection("user")
            .doc(user!.uid)
            .collection("redeem_history")
            .orderBy("time", descending: true)
            .get();

        setState(() {
          redeemHistory = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
          isLoading = false;
        });

        print("Redeem history length: ${redeemHistory.length}");
      } else {
        print("User not logged in.");
      }
    } catch (e) {
      print("Error fetching redeem history: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Redeem History"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : redeemHistory.isEmpty
              ? Center(child: Text("No redeem history found."))
              : ListView.builder(
                  itemCount: redeemHistory.length,
                  itemBuilder: (context, index) {
                    final item = redeemHistory[index];
                    final points = item['points'] ?? 0;
                    final timestamp = item['time'] as Timestamp?;
                    final date = timestamp?.toDate();

                    return ListTile(
                      leading: Icon(Icons.card_giftcard),
                      title: Text("Points Redeemed: $points"),
                      subtitle: Text(
                        date != null
                            ? "${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute}"
                            : "No time info",
                      ),
                    );
                  },
                ),
    );
  }
}
