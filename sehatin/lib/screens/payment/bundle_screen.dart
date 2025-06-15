import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import './payment_screen.dart';

class BundleScreen extends StatelessWidget {
  final UserModel user;
  const BundleScreen({super.key, required this.user});

  void _onBundleSelected(BuildContext context, Map<String, String> bundle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => PaymentScreen(
              bundleName: bundle['title']!,
              price: bundle['price']!,
              user: user,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bundles = [
      {'title': '1 Consultation', 'subtitle': 'desc', 'price': 'IDR 2.000'},
      {'title': '3 Consultations', 'subtitle': 'desc', 'price': 'IDR 6.000'},
      {'title': '10 Consultations', 'subtitle': 'desc', 'price': 'IDR 20.000'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Bundle'),
        backgroundColor: const Color.fromARGB(255, 52, 43, 182),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bundles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final bundle = bundles[index];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(
                bundle['title']!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(bundle['subtitle']!),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    bundle['price']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              onTap: () => _onBundleSelected(context, bundle),
            ),
          );
        },
      ),
    );
  }
}
