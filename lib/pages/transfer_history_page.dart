import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart'; // Pastikan import API service yang benar

class TransferHistoryPage extends StatefulWidget {
  const TransferHistoryPage({super.key});

  @override
  State<TransferHistoryPage> createState() => _TransferHistoryPageState();
}

class _TransferHistoryPageState extends State<TransferHistoryPage> {
  List<Map<String, dynamic>> transferHistory = [];

  @override
  void initState() {
    super.initState();
    _loadTransferHistory();
  }

  // Fungsi untuk mengambil data histori transfer
  Future<void> _loadTransferHistory() async {
    try {
      final data = await ApiService.fetchTransferHistory(); // Panggil API untuk mengambil histori transfer
      print(data);  // Debug: Tampilkan data yang diterima
      if (data.isNotEmpty) {
        setState(() {
          transferHistory = data;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No transfer history available")));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to load transfer history")));
    }
  }

  // Fungsi untuk format mata uang
  String formatCurrency(dynamic value) {
    // Pastikan nilai 'value' dalam format double
    double amount = value is String ? double.tryParse(value) ?? 0.0 : value.toDouble();
    
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  // Fungsi untuk format tanggal sesuai dengan zona waktu lokal
  String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal(); // Konversi ke waktu lokal
      return DateFormat('dd MMM yyyy').format(date);  // Hanya menampilkan tanggal tanpa waktu
    } catch (e) {
      return dateString; // Jika terjadi error dalam parsing tanggal
    }
  }

  // Fungsi untuk format waktu (created_at atau updated_at)
  String formatTime(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal(); // Konversi ke waktu lokal
      return DateFormat('dd MMM yyyy HH:mm').format(date);  // Menampilkan tanggal dengan waktu
    } catch (e) {
      return dateString; // Jika terjadi error dalam parsing tanggal
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer History', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
      body: transferHistory.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: transferHistory.length,
                itemBuilder: (context, index) {
                  final transfer = transferHistory[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      leading: Icon(Icons.swap_horiz, color: Colors.blue.shade600),
                      title: Text(
                        'From: ${transfer['from_wallet_name']} to ${transfer['to_wallet_name']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amount: ${formatCurrency(transfer['amount'])}',
                              style: TextStyle(color: Colors.green.shade700, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Transaction Date: ${formatDate(transfer['transaction_date'])}',  // Menggunakan format tanggal
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Created At: ${formatTime(transfer['created_at'])}',  // Menggunakan format waktu
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Hapus bagian ini untuk menghilangkan ikon panah
                      // trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue.shade600),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
