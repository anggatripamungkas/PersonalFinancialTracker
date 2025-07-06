import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Import NumberFormat
import '../services/api_service.dart';  // Import ApiService untuk mengakses fungsi API
import 'kategori_page.dart';  // Import KategoriPage untuk navigasi

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  // Menyimpan data kategori pengeluaran
  List<Map<String, dynamic>> _expenseCategories = [];

  @override
  void initState() {
    super.initState();
    _fetchExpenseCategories();
  }

  // Mengambil kategori pengeluaran dari API
  Future<void> _fetchExpenseCategories() async {
    try {
      final categories = await ApiService.fetchExpenseCategories();
      setState(() {
        _expenseCategories = categories;
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Laporan',
          style: TextStyle(
            color: Colors.white, // Menetapkan warna teks menjadi putih
            fontWeight: FontWeight.bold, // Menebalkan teks
          ),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              // Navigasi ke halaman Kategori
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => KategoriPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan Bulanan
            _buildSectionTitle('Ringkasan Bulanan'),
            _buildMonthlySummary(),

            const SizedBox(height: 20), // Jarak antara bagian

            // Pengeluaran per Kategori
            _buildSectionTitle('Pengeluaran per Kategori'),
            _buildExpenseByCategory(),
          ],
        ),
      ),
    );
  }

  // Widget untuk menampilkan judul bagian
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget untuk Ringkasan Bulanan
  Widget _buildMonthlySummary() {
    return FutureBuilder<Map<String, dynamic>>(
      future: ApiService.fetchMonthlySummary(), // Memanggil fungsi fetchMonthlySummary
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.hasData) {
          final data = snapshot.data!; // Mengambil data dari API
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.white,  // Warna latar belakang putih
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryItem('Total Pemasukan Bulanan', data['income'], Colors.green),
                  const SizedBox(height: 10),
                  _buildSummaryItem('Total Pengeluaran Bulanan', data['expense'], Colors.red),
                  const Divider(thickness: 1),  // Garis pemisah antara Pengeluaran dan Saldo
                  const SizedBox(height: 10),
                  _buildSummaryItem('Saldo Bulanan', data['balance'], Colors.black, isBold: true),
                ],
              ),
            ),
          );
        } else {
          return const Center(child: Text('No data available.'));
        }
      },
    );
  }

  // Widget untuk membuat bagian ringkasan (Total Pemasukan, Pengeluaran, Saldo)
  Widget _buildSummaryItem(String label, dynamic value, Color color, {bool isBold = false}) {
    double amount = double.tryParse(value.toString()) ?? 0.0;
    final formattedValue = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0).format(amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        Text(
          formattedValue,
          style: TextStyle(
            fontSize: 16,
            color: color,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Widget untuk Pengeluaran per Kategori
  Widget _buildExpenseByCategory() {
    return _expenseCategories.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _expenseCategories.map((category) {
                  return _buildCategoryExpense(category['name'], category['color']);
                }).toList(),
              ),
            ),
          );
  }

  // Widget untuk menampilkan pengeluaran per kategori dengan persen
  Widget _buildCategoryExpense(String category, String color) {
    // Menggunakan metode Colors untuk menangani nama warna
    Color categoryColor;

    try {
      // Jika nama warna ada dalam Colors, gunakan warna tersebut
      categoryColor = _getColorFromName(color);
    } catch (e) {
      // Jika warna tidak dikenali, fallback ke grey
      categoryColor = Colors.grey;
      print('Invalid color value: $color, fallback to grey');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Lingkaran warna di sebelah kiri teks kategori
        Row(
          children: [
            Icon(Icons.circle, color: categoryColor, size: 16), // Lingkaran warna
            SizedBox(width: 8), // Jarak antara lingkaran dan teks kategori
            Text(category, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  // Fungsi untuk mengonversi nama warna menjadi warna yang sesuai
  Color _getColorFromName(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'grey':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
