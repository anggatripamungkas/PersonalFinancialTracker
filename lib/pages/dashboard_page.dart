import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart'; // Pastikan ApiService sudah benar
import 'transactions_page.dart'; // Halaman transaksi
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import FlutterSecureStorage

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Map<String, dynamic>? dashboardData;
  List<dynamic> wallets = [];
  List<dynamic> recentTransactions = []; // Menambahkan variabel untuk transaksi terbaru
  bool isLoading = true;
  bool hasError = false;
  String userName = ''; // Menyimpan nama pengguna
  double percentageChange = 0; // Menyimpan persentase perubahan saldo
  double lastTotalBalance = 0; // Menyimpan total saldo terakhir
  final storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _getUserName(); // Memanggil untuk mendapatkan nama pengguna
    _getLastTotalBalance(); // Mendapatkan saldo total terakhir dari penyimpanan
    fetchDashboard();
  }


  // Mengambil nama pengguna dari FlutterSecureStorage
  Future<void> _getUserName() async {
    final storedName = await storage.read(key: 'username'); // Ambil nama pengguna dari Secure Storage
    setState(() {
      userName = storedName ?? 'User'; // Jika nama tidak ditemukan, tampilkan 'User'
    });
  }

  // Mengambil saldo terakhir dari SecureStorage
  Future<void> _getLastTotalBalance() async {
    final storedBalance = await storage.read(key: 'last_total_balance');
    setState(() {
      lastTotalBalance = storedBalance != null ? double.tryParse(storedBalance) ?? 0 : 0;
    });
  }

  // Menyimpan saldo terakhir ke SecureStorage
  Future<void> _saveLastTotalBalance(double totalBalance) async {
    await storage.write(key: 'last_total_balance', value: totalBalance.toString());
  }

  // Ambil data dashboard dari API
  Future<void> fetchDashboard() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final data = await ApiService.fetchDashboardData();
      final walletData = await ApiService.fetchWallets(); // Menggunakan fetchWallets di sini

      // Ambil 3 transaksi terbaru
      final transactions = await ApiService.fetchTransactions(page: 1, pageSize: 3);

      double totalBalance = 0;
      for (var wallet in walletData) {
        totalBalance += double.tryParse(wallet['current_balance'].toString()) ?? 0;
      }

      if (lastTotalBalance != 0) {
        setState(() {
          percentageChange = ((totalBalance - lastTotalBalance) / lastTotalBalance) * 100;
        });
      } else {
        setState(() {
          percentageChange = 0;
        });
      }

      await _saveLastTotalBalance(totalBalance);

      setState(() {
        dashboardData = data;
        wallets = walletData;
        recentTransactions = transactions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // Fungsi untuk memformat nilai mata uang
  String formatCurrency(dynamic value, {bool isWallet = false}) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    double doubleValue = double.tryParse(value.toString()) ?? 0;

    if (isWallet && doubleValue >= 100000000) {
      return NumberFormat("#,##0").format(doubleValue).replaceAll(',', '.');
    }

    return currency.format(doubleValue);
  }

  // Fungsi untuk menghitung total saldo dari semua wallet
  double calculateTotalBalance() {
    double totalBalance = 0;
    for (var wallet in wallets) {
      final balance = double.tryParse(wallet['current_balance'].toString()) ?? 0;
      totalBalance += balance;
    }
    return totalBalance;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : hasError
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Gagal memuat data dashboard'),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: fetchDashboard,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              )
            : SafeArea(
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: fetchDashboard,  // Memanggil ulang fungsi fetchDashboard
                        child: _buildContent(context),
                      ),
                    ),
                  ],
                ),
              );
  }

  Widget _buildHeader() {
    double totalBalance = calculateTotalBalance(); // Menghitung total saldo

    return Container(
      color: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hi, $userName', // Menampilkan nama pengguna dari SecureStorage
                  style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('A', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Total Saldo', style: TextStyle(color: Colors.white.withOpacity(0.7))),
          Text(
            formatCurrency(totalBalance), // Menampilkan total saldo
            style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('${wallets.length} Dompet', style: TextStyle(color: Colors.white.withOpacity(0.8))),
              const SizedBox(width: 10),
              Text(
                '${percentageChange.toStringAsFixed(2)}% perubahan',
                style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final transactions = recentTransactions.take(3).toList(); // Gunakan recentTransactions di sini

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Dompet Saya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: wallets.length,
              itemBuilder: (context, index) {
                final wallet = wallets[index];

                IconData icon = Icons.account_balance_wallet;
                Color color = Colors.blue;
                String subtext = wallet['is_active'] ? 'Active' : 'Inactive';
                Color subtextColor = wallet['is_active'] ? Colors.green : Colors.red;

                if (wallet['name'].toLowerCase() == 'bca') {
                  icon = Icons.account_balance;
                  color = Colors.purple;
                  subtext = wallet['is_active'] ? "Active" : "Inactive";
                  subtextColor = wallet['is_active'] ? Colors.green : Colors.red;
                } else if (wallet['name'].toLowerCase() == 'cash') {
                  icon = Icons.attach_money;
                  color = Colors.green;
                  subtext = wallet['is_active'] ? "Active" : "Inactive";
                  subtextColor = wallet['is_active'] ? Colors.green : Colors.red;
                }

                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50 * ((index % 8) + 1)],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                            Text(wallet['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            Row(
                              children: [
                                Text(
                                  subtext,
                                  style: TextStyle(color: subtextColor, fontSize: 12),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  subtextColor == Colors.green
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: subtextColor,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatCurrency(wallet['current_balance'], isWallet: true),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Transaksi Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionsPage()),
                  );
                },
                child: const Text('Lihat Semua', style: TextStyle(color: Colors.grey)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          transactions.isEmpty
              ? const Center(child: Text('Transaksi belum ada'))
              : Column(
                  children: List.generate(transactions.length, (index) {
                    final tx = transactions[index];
                    final isIncome = tx['type'] == 'income';
                    IconData icon;
                    Color iconColor;

                    String description = tx['description'] ?? 'Tidak ada deskripsi';

                    icon = Icons.account_balance_wallet;
                    iconColor = isIncome ? Colors.green : Colors.red;

                    return Card(
                      child: ListTile(
                        leading: Icon(icon, color: iconColor),
                        title: Text(description),
                        subtitle: Text(tx['transaction_date'] ?? ''),
                        trailing: Text(
                          '${isIncome ? '+' : '-'}${formatCurrency(tx['amount'])}',
                          style: TextStyle(
                            color: iconColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
        ],
      ),
    );
  }
}
