import 'package:flutter/material.dart';
import 'package:finacial/services/api_service.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Map<String, dynamic>? profileData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch user profile from the API
  Future<void> _fetchUserProfile() async {
    try {
      final data = await ApiService.getUserProfile();
      setState(() {
        profileData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal mengambil profil")),
      );
    }
  }

  // Display the user's profile in a table format
  Widget _buildProfile() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (profileData == null) {
      return const Center(child: Text("Tidak ada data profil."));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(  // Center hanya di tabel
          child: Card(
            elevation: 5,
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(8.0), // Reduced padding
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 800),  // Batasi lebar tabel, lebih lebar
                child: Table(
                  border: TableBorder.all(color: Colors.black),
                  columnWidths: {
                    0: FractionColumnWidth(0.4),  // Lebar kolom pertama lebih sempit
                    1: FractionColumnWidth(0.7),  // Lebar kolom kedua lebih lebar
                  },
                  children: [
                    TableRow(
                      children: [
                        _buildTableCell('Username', isHeader: true),
                        _buildTableCell(profileData?['username'] ?? 'N/A'),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildTableCell('Email', isHeader: true),
                        _buildTableCell(profileData?['email'] ?? 'N/A'),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildTableCell('First Name', isHeader: true),
                        _buildTableCell(profileData?['first_name'] ?? 'N/A'),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildTableCell('Last Name', isHeader: true),
                        _buildTableCell(profileData?['last_name'] ?? 'N/A'),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildTableCell('Phone', isHeader: true),
                        _buildTableCell(profileData?['phone'] ?? 'N/A'),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildTableCell('Date Joined', isHeader: true),
                        _buildTableCell(profileData?['date_joined'] ?? 'N/A'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to create table cells
  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0), // Reduce padding further
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14, // Reduced font size
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
        ),
        textAlign: isHeader ? TextAlign.center : TextAlign.start,  // Center only headers
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Setting", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              try {
                await ApiService.logout(); // Pastikan metode logout sudah ada
                Navigator.pushReplacementNamed(context, '/login');
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Gagal Logout!")),
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildProfile(), // Tampilkan profil dalam tabel
      ),
    );
  }
}
