import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart'; // Pastikan import API service yang benar
import 'transfer_history_page.dart'; // Pastikan import halaman histori transfer

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  List<Map<String, dynamic>> wallets = [];
  String? selectedFrom;
  String? selectedTo;
  final TextEditingController amountController = TextEditingController();

  double fee = 0;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
  }

  // Fungsi untuk format mata uang
  String formatCurrency(num value) {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(value);
  }

  // Mengambil data wallet dari API
  Future<void> _loadWalletData() async {
    try {
      final data = await ApiService.fetchWallets(); // Ambil data dompet dari API
      print(data);  // Debug: Tampilkan data yang diterima

      if (data.isNotEmpty) {
        setState(() {
          // Convert current_balance to double if it's a string
          wallets = data.map((wallet) {
            wallet['current_balance'] = double.tryParse(wallet['current_balance'].toString()) ?? 0.0;
            return wallet;
          }).toList();

          selectedFrom = wallets.isNotEmpty ? wallets[0]['name'] : null;
          selectedTo = wallets.isNotEmpty && wallets.length > 1 ? wallets[1]['name'] : null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No wallets available")));
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to load wallet data")));
    }
  }

  // Fungsi untuk menghitung fee
  void _calculateFee(double amount) {
    setState(() {
      fee = amount * 0.01; // Fee 1% dari jumlah transfer
    });
  }

  // Fungsi untuk meng-handle transfer
  Future<void> _handleTransfer() async {
    if (selectedFrom == null || selectedTo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select both source and destination wallets")));
      return;
    }

    final fromWallet = wallets.firstWhere((w) => w['name'] == selectedFrom);
    final toWallet = wallets.firstWhere((w) => w['name'] == selectedTo);

    final amountText = amountController.text.replaceAll('.', '');
    final double? amount = double.tryParse(amountText);

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a valid amount")));
      return;
    }

    if (selectedFrom == selectedTo) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Source and destination must be different")));
      return;
    }

    final double fromBalance = (fromWallet['current_balance'] != null)
        ? double.tryParse(fromWallet['current_balance'].toString()) ?? 0.0
        : 0.0;

    if (fromBalance < (amount + fee)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Insufficient balance")));
      return;
    }

    // Membuat transfer
    try {
      final response = await ApiService.createTransfer(
        fromWallet['id'],
        toWallet['id'],
        amount.toDouble(),
        fee,
      );

      if (response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Transfer successful")));
        setState(() {
          amountController.clear();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // Navigasi ke halaman histori transfer
  void _navigateToTransferHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TransferHistoryPage()), // Pastikan halaman histori transfer sudah dibuat
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Tombol untuk ke halaman histori transfer
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: const Icon(Icons.history, color: Colors.blue),
                        onPressed: _navigateToTransferHistory, // Navigasi ke halaman histori transfer
                        tooltip: 'View Transfer History',
                      ),
                    ),
                    // TextField untuk input jumlah
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Amount",
                        prefixText: "Rp ",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final amount = double.tryParse(value.replaceAll('.', ''));
                        if (amount != null) {
                          _calculateFee(amount); // Hitung fee saat jumlah berubah
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    // Dropdown untuk memilih wallet sumber
                    Row(
                      children: [
                        const Icon(Icons.arrow_forward, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedFrom,
                            decoration: const InputDecoration(labelText: "From"),
                            items: wallets.map((wallet) {
                              return DropdownMenuItem<String>( 
                                value: wallet['name'],
                                child: Text(
                                    '${wallet['name']} (${formatCurrency(wallet['current_balance'])})'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedFrom = value;
                                if (selectedTo == value) {
                                  selectedTo = wallets
                                      .firstWhere((w) => w['name'] != value)['name'];
                                }
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Dropdown untuk memilih wallet tujuan
                    Row(
                      children: [
                        const Icon(Icons.arrow_back, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedTo,
                            decoration: const InputDecoration(labelText: "To"),
                            items: wallets
                                .where((wallet) => wallet['name'] != selectedFrom)
                                .map((wallet) {
                              return DropdownMenuItem<String>( 
                                value: wallet['name'],
                                child: Text(
                                    '${wallet['name']} (${formatCurrency(wallet['current_balance'])})'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedTo = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Menampilkan fee
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.orange),
                        const SizedBox(width: 12),
                        const Text("Fee"),
                        const SizedBox(width: 16),
                        Text(
                          formatCurrency(fee),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Confirm Transfer Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleTransfer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Confirm Transfer',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
