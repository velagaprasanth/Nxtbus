// lib/pages/payment_page.dart
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth/Login_Screen.dart'; // make sure you have this path correct

class PaymentPage extends StatefulWidget {
  final int amount;
  final List<String> selectedSeats;
  final String busId;

  const PaymentPage({
    super.key,
    required this.amount,
    required this.selectedSeats,
    required this.busId,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late Razorpay _razorpay;
  User? currentUser;
  String? userEmail;
  String? userPhone;

  @override
  void initState() {
    super.initState();

    currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      // 🚨 No user logged in → send to login screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      });
    } else {
      // ✅ Fetch user details from Firestore
      FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser!.uid)
          .get()
          .then((doc) {
        if (doc.exists) {
          setState(() {
            userEmail = doc["email"];
            userPhone = doc["phone"];
          });
          _openCheckout();
        }
      });
    }

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _openCheckout() {
    var options = {
      'key': 'rzp_test_RCmYb3XTMb99xT', // replace with your key
      'amount': widget.amount * 100,
      'name': 'Bus Booking',
      'description': 'Seat booking for Bus ${widget.busId}',
      'prefill': {
        'contact': userPhone ?? "0000000000",
        'email': userEmail ?? "guest@example.com",
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Navigator.pop(context, true); // return success to SeatsPage
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Navigator.pop(context, false); // return failure
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("External Wallet: ${response.walletName}")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
