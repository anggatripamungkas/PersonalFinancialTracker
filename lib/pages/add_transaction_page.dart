import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../services/api_service.dart';  // Pastikan ApiService sudah benar

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  int _category = 0;  // Tipe data diubah menjadi int
  int _wallet = 0;    // Tipe data diubah menjadi int
  String _type = 'income';  // Defaultkan ke income
  String _amount = '0.00';  // Tipe data amount diubah menjadi String
  String _description = '';
  DateTime _transactionDate = DateTime.now();
  List<dynamic> _categories = [];
  List<dynamic> _wallets = [];
  List<dynamic> _tags = [];
  List<int> _selectedTags = []; // List untuk tag yang dipilih

  // Ambil data kategori, wallet, dan tag dari API
  Future<void> _fetchData() async {
    try {
      final categories = await ApiService.fetchCategories();  // Ambil kategori dari API
      final wallets = await ApiService.fetchWallets();         // Ambil wallet dari API
      final tags = await ApiService.fetchTags();               // Ambil tags dari API
      setState(() {
        _categories = categories;
        _wallets = wallets;
        _tags = tags;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat data: $e')));
      print("Error fetching data: $e");  // Log error ke debug console
    }
  }

  Future<void> _addTransaction() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Mengambil data dari form
      _formKey.currentState?.save();

      // Log data yang dikirimkan ke API
      print('Data yang dikirimkan ke API:');
      print('Category: $_category');
      print('Wallet: $_wallet');
      print('Type: $_type');
      print('Amount: $_amount');
      print('Description: $_description');
      print('Transaction Date: $_transactionDate');
      print('Selected Tags: $_selectedTags');

      // Format amount sebagai string dengan 2 desimal (contoh: "700000.00")
      String amountFormatted = _amount;  // Langsung gunakan amount dalam format string

      // Menambahkan transaksi
      try {
        final response = await ApiService.createTransaction(
          wallet: _wallet,  // Kirim wallet sebagai int
          category: _category,  // Kirim category sebagai int
          amount: amountFormatted,  // Kirim amount sebagai string
          type: _type,
          description: _description,
          transactionDate: _transactionDate,  // Kirim transactionDate sebagai DateTime
          tags: _selectedTags,  // Mengirimkan tags yang dipilih
        );

        // Log respons dari API untuk debugging
        print('API Response: $response'); // Log respons penuh

        // Mengecek respons dari API
        if (response['status'] == 'success') {  // Tidak perlu lagi memeriksa apakah response null
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi berhasil ditambahkan!')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${response['message']}')));
          print('API error response: ${response['message']}');  // Log error dari API
        }
      } catch (e) {
        // Menangani error yang terjadi pada saat request
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        print('Error adding transaction: $e');  // Log error ke debug console
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();  // Ambil data kategori, wallet, dan tags saat halaman dimuat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: SingleChildScrollView(  // Membungkus seluruh form dengan SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Dropdown untuk memilih Wallet
                DropdownButtonFormField<int>(
                  value: _wallet != 0 ? _wallet : null,  // Perbaiki pengkondisian null
                  hint: const Text('Pilih Wallet'),
                  items: _wallets.map((wallet) {
                    return DropdownMenuItem<int>(
                      value: wallet['id'],
                      child: Text(wallet['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _wallet = value ?? 0;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Wallet'),
                  validator: (value) {
                    if (value == null || value == 0) {
                      return 'Wallet harus dipilih';
                    }
                    return null;
                  },
                ),
                // Dropdown untuk memilih Kategori
                DropdownButtonFormField<int>(
                  value: _category != 0 ? _category : null,  // Perbaiki pengkondisian null
                  hint: const Text('Pilih Kategori'),
                  items: _categories.map((category) {
                    return DropdownMenuItem<int>(
                      value: category['id'],
                      child: Text(category['name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _category = value ?? 0;
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  validator: (value) {
                    if (value == null || value == 0) {
                      return 'Kategori harus dipilih';
                    }
                    return null;
                  },
                ),
                // Dropdown untuk memilih Jenis Transaksi (Pemasukan/Pengeluaran)
                DropdownButtonFormField<String>(
                  value: _type,
                  items: const [
                    DropdownMenuItem(value: 'income', child: Text('Pemasukan')),
                    DropdownMenuItem(value: 'expense', child: Text('Pengeluaran')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _type = value ?? 'income';
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Jenis Transaksi'),
                ),
                // Form untuk memasukkan jumlah
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Jumlah'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _amount = value ?? '0.00',  // Simpan sebagai string
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah harus diisi';
                    }
                    // Pastikan jumlah dalam format yang benar (misalnya "700000.00")
                    try {
                      double.parse(value);
                    } catch (e) {
                      return 'Jumlah tidak valid';
                    }
                    return null;
                  },
                ),
                // Form untuk memasukkan deskripsi
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  onSaved: (value) => _description = value ?? '',
                ),
                // MultiSelect untuk memilih Tags
                MultiSelectDialogField<int>(
                  items: _tags.map((tag) {
                    return MultiSelectItem<int>(tag['id'], tag['name']);
                  }).toList(),
                  title: const Text('Pilih Tags'),
                  onConfirm: (selected) {
                    setState(() {
                      _selectedTags = selected.cast<int>();
                    });
                  },
                  initialValue: _selectedTags,
                ),
                // Memberikan margin untuk posisi tombol lebih ke bawah
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 32.0),  // Mengatur jarak atas dan bawah
                  child: ElevatedButton(
                    onPressed: _addTransaction,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15), // Lebar dan tinggi lebih besar
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),  // Sudut yang lebih bulat
                      ),
                      backgroundColor: Colors.blueAccent,  // Warna latar belakang tombol
                      shadowColor: Colors.blueAccent.withOpacity(0.5), // Efek bayangan
                      elevation: 10,  // Memberikan efek bayangan untuk tombol mengambang
                    ),
                    child: const Text(
                      'Simpan Transaksi',
                      style: TextStyle(
                        fontSize: 15,  // Ukuran font lebih besar
                        fontWeight: FontWeight.bold,  // Tebalkan teks
                        color: Colors.white,  // Warna teks
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
