import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nxtbus/auth/Login_Screen.dart';
import 'package:nxtbus/auth/Register_Screen.dart';
import '../auth/Login_Screen.dart';
import '../auth/Register_Screen.dart';

// Color theme
const Color primaryBlue = Color(0xFF1E88E5);
const Color darkBlue = Color(0xFF1565C0);
const Color lightText = Color(0xFF757575);
const Color darkText = Color(0xFF212121);
const Color white = Colors.white;
const Color backgroundColor = Color(0xFFF5F5F5);

class ProfileMoreScreen extends StatelessWidget {
  const ProfileMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            final user = snapshot.data;

            return Column(
              children: [
                _buildHeader(user),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        if (user != null)
                          ..._buildLoggedInMenuItems(context, user)
                        else
                          ..._buildGuestMenuItems(context),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: const Text(
                            'App Version: 10.1.6',
                            style: TextStyle(
                              color: lightText,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ===================== HEADER =====================
  Widget _buildHeader(User? user) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryBlue, darkBlue],
        ),
      ),
      child: user != null ? _buildLoggedInHeader(user) : _buildGuestHeader(),
    );
  }

  Widget _buildLoggedInHeader(User user) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              gradient: const LinearGradient(
                colors: [Colors.orange, Colors.yellow],
              ),
            ),
            child: const Icon(Icons.person, size: 40, color: white),
          ),
          const SizedBox(height: 16),
          Text(
            user.displayName ?? "User",
            style: const TextStyle(
              color: white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email ?? "",
            style: const TextStyle(
              color: white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestHeader() {
    return const Padding(
      padding: EdgeInsets.all(24.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_outline, size: 40, color: white),
          ),
          SizedBox(height: 16),
          Text(
            'Welcome to NXTBus',
            style: TextStyle(color: white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Login to access all features',
            style: TextStyle(color: white, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ===================== MENU ITEMS =====================
  List<Widget> _buildLoggedInMenuItems(BuildContext context, User user) {
    return [
      const SizedBox(height: 20),
      _buildMenuItem(Icons.person_outline, 'Profile', () => _navigateToPage(context, 'Profile')),
      _buildMenuItem(Icons.luggage_outlined, 'My Trips', () => _navigateToPage(context, 'MyTrips')),
      _buildMenuItem(Icons.account_balance_wallet_outlined, 'Wallet', () => _navigateToPage(context, 'Wallet')),
      _buildMenuItem(Icons.star_outline, 'Review & Rating', () => _navigateToPage(context, 'ReviewRating')),
      _buildMenuItem(Icons.support_agent_outlined, 'Support', () => _navigateToPage(context, 'Support')),
      _buildMenuItem(Icons.policy_outlined, 'Cancellation Policy', () => _navigateToPage(context, 'CancellationPolicy')),
      _buildMenuItem(Icons.logout, 'Logout', () => _logoutUser(context)),
      _buildMenuItem(Icons.delete_forever, 'Delete Account', () => _deleteUser(context), isDestructive: true),
    ];
  }

  List<Widget> _buildGuestMenuItems(BuildContext context) {
    return [
      const SizedBox(height: 20),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage()));
                },
                child: const Text("Login"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                child: const Text("Register"),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 32),
      _buildMenuItem(Icons.support_agent_outlined, 'Support', () => _navigateToPage(context, 'Support')),
      _buildMenuItem(Icons.policy_outlined, 'Cancellation Policy', () => _navigateToPage(context, 'CancellationPolicy')),
      _buildMenuItem(Icons.info_outline, 'About Us', () => _navigateToPage(context, 'AboutUs')),
    ];
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : darkText),
        title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : darkText, fontSize: 16)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // ===================== HELPERS =====================
  void _navigateToPage(BuildContext context, String pageName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Navigating to $pageName')),
    );
  }

  // ✅ Logout user via Firebase
  void _logoutUser(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Logged out successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: $e")),
      );
    }
  }

  // ✅ Delete account
  void _deleteUser(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting account: $e")),
        );
      }
    }
  }
}
