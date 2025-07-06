import 'package:finacial/pages/repots_page.dart';
import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'dompet_page.dart';
import 'add_transaction_page.dart'; // ✅ IMPORT HALAMAN BARU
import 'setting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const DompetPage(),
    const ReportsPage(), // Placeholder
    const SettingPage(), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabIcon(Icons.home, 0),
            _buildTabIcon(Icons.wallet, 1),
            const SizedBox(width: 40), // For FAB spacing
            _buildTabIcon(Icons.bar_chart_outlined, 2),
            _buildTabIcon(Icons.settings_outlined, 3),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ✅ BUKA HALAMAN ADD TRANSACTION
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildTabIcon(IconData icon, int index) {
    final isSelected = _currentIndex == index;
    return IconButton(
      icon: Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
      onPressed: () {
        setState(() {
          _currentIndex = index;
        });
      },
    );
  }
}
