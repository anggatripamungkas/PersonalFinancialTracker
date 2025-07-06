import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'transfer_page.dart';

class DompetPage extends StatefulWidget {
  const DompetPage({super.key});

  @override
  State<DompetPage> createState() => _DompetPageState();
}

class _DompetPageState extends State<DompetPage> {
  bool isLoading = true;
  bool hasError = false;
  Map<String, dynamic>? walletData;

  @override
  void initState() {
    super.initState();
    fetchWallets();
  }
  

  Future<void> fetchWallets() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final data = await ApiService.fetchDashboardData();
      setState(() {
        walletData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> addWallet(String name, double balance) async {
    try {
      final response = await ApiService.createWallet(name, balance);
      if (response['success']) {
        fetchWallets();
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    }
  }

 Future<void> updateWallet(String id, String name, bool isActive) async {
  try {
    final response = await ApiService.updateWallet(
      id,
      name,
      isActive,
    );
    if (response['success']) {
      fetchWallets();  // Refresh wallets setelah update
    } else {
      setState(() {
        hasError = true;
      });
    }
  } catch (e) {
    setState(() {
      hasError = true;
    });
  }
}

  Future<void> deleteWallet(String id) async {
    try {
      final response = await ApiService.deleteWallet(id);
      if (response['success']) {
        fetchWallets();
      } else {
        setState(() {
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
      });
    }
  }

  String formatCurrency(num? value) {
    if (value == null) return '0';
    return NumberFormat('#,##0', 'id_ID').format(value.toInt());
  }

  void _showAddWalletDialog() {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Wallet"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Wallet Name"),
              ),
              TextField(
                controller: balanceController,
                decoration: const InputDecoration(labelText: "Balance"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text;
              final balance = double.tryParse(balanceController.text) ?? 0;
              if (name.isNotEmpty) {
                addWallet(name, balance);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

void _showEditWalletDialog(String walletId, String walletName, double walletBalance, bool isActive) {
  final nameController = TextEditingController(text: walletName);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Edit Wallet"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Wallet Name"),
            ),
            SwitchListTile(
              title: const Text("Is Active?"),
              value: isActive,
              onChanged: (value) {
                setState(() {
                  isActive = value;  // Update status isActive sesuai dengan switch
                });
              },
            ),
            const SizedBox(height: 10),
            isActive
                ? const Text("Wallet is active", style: TextStyle(color: Colors.green))
                : const Text("Wallet is inactive", style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () async {
            final name = nameController.text;
            if (name.isNotEmpty) {
              // Kirim pembaruan ke API dengan status terbaru
              await updateWallet(walletId, name, isActive);
              Navigator.pop(context);
            }
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}

  void _showWalletOptionsDialog(String walletId, String walletName, double walletBalance, dynamic walletType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Options for $walletName"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showEditWalletDialog(walletId, walletName, walletBalance, walletType);
              },
              child: const Text("Edit Wallet"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteWallet(walletId);
              },
              child: const Text("Delete Wallet"),
            ),
          ],
        ),
      ),
    );
  }

 @override
Widget build(BuildContext context) {
  final wallets = walletData?['results'] ?? [];

  // Menghitung total balance
  double totalWalletBalance = 0;
  for (var wallet in wallets) {
    final walletBalance = double.tryParse(wallet['current_balance'].toString()) ?? 0;
    totalWalletBalance += walletBalance;
  }

  return isLoading
      ? const Center(child: CircularProgressIndicator())
      : hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Gagal memuat data dompet"),
                  const SizedBox(height: 10),
                  ElevatedButton(
                      onPressed: fetchWallets,
                      child: const Text("Coba Lagi")),
                ],
              ),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: fetchWallets, // Tambahkan refresh ketika tarik ke bawah
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "My Wallets",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: _showAddWalletDialog,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Total Balance
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xffe7f1ff),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Total Balance",
                                      style: TextStyle(color: Colors.black54)),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatCurrency(totalWalletBalance),
                                    style: const TextStyle(
                                        fontSize: 28, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade200,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text("IDR",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Tombol Transfer
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TransferPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Transfer",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Wallet Cards
                        Column(
                          children: List<Widget>.from(wallets.map((wallet) {
                            final walletName = wallet['name'];
                            final walletBalance =
                                double.tryParse(wallet['current_balance'].toString()) ?? 0;
                            final walletId = wallet['id'];
                            final isActive = wallet['is_active'];

                            IconData icon = Icons.account_balance_wallet;
                            Color color = Colors.blue;
                            String subtext = isActive ? "Active" : "Inactive";
                            Color subtextColor = isActive ? Colors.green : Colors.red;

                            if (walletName.toLowerCase().contains("bca")) {
                              icon = Icons.account_balance;
                              color = Colors.purple;
                              subtext = "Bank Account";
                              subtextColor = Colors.blue;
                            } else if (walletName.toLowerCase() == 'cash') {
                              icon = Icons.attach_money;
                              color = Colors.green;
                              subtext = "Cash";
                              subtextColor = Colors.green;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () {
                                  _showWalletOptionsDialog(walletId.toString(), walletName, walletBalance, wallet['is_active']);
                                },
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: color,
                                      child: Icon(icon, color: Colors.white),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(walletName,
                                              style: const TextStyle(fontWeight: FontWeight.bold)),
                                          Row(
                                            children: [
                                              Text(
                                                subtext,
                                                style: TextStyle(
                                                    color: subtextColor,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                isActive
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                color: subtextColor,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(
                                        formatCurrency(walletBalance),
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          })),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
}
}
