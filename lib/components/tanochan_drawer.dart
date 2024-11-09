// lib/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:mr_collection/components/dialog/paypay_dialog.dart';

class TanochanDrawer extends StatelessWidget {
  const TanochanDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF2F2F2),
      width: MediaQuery.of(context).size.width * 0.71,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Text(
              "設定",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 40),
            _buildMenuItem(
              context,
              text: "PayPay連携",
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const PayPayDialog(),
                );
              },
            ),
            const SizedBox(height: 20),
            _buildMenuItem(
              context,
              text: "ログアウト",
              onTap: () {
                // ログアウトの処理をここに記述
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context,
      {required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.black,
              width: 1,
            ),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
