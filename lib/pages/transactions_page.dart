import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Import ApiService untuk mengambil data transaksi

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _searchQuery = '';
  DateTime? _startDate;  // Tanggal mulai untuk filter
  DateTime? _endDate;    // Tanggal akhir untuk filter

  @override
  void initState() {
    super.initState();
    _fetchTransactions();  // Inisialisasi data pertama kali
  }

  // Fungsi untuk mengambil data transaksi
  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Format tanggal menjadi "YYYY-MM-DD"
      String? startDateFormatted = _startDate != null
          ? "${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}"
          : null;
      String? endDateFormatted = _endDate != null
          ? "${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}"
          : null;

      final data = await ApiService.fetchTransactions(
        search: _searchQuery,
        startDate: startDateFormatted,  // Kirim tanggal mulai ke API
        endDate: endDateFormatted,      // Kirim tanggal akhir ke API
      );
      setState(() {
        _transactions = List<Map<String, dynamic>>.from(data);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      print('Error: $e'); // Log error
    }
  }

  // Fungsi untuk menampilkan daftar transaksi
  Widget _buildTransactionList() {
    return ListView.builder(
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        final transactionType = transaction['type'];  // Jenis transaksi: income/expense
        final amount = transaction['amount'];

        // Tentukan warna berdasarkan jenis transaksi
        Color amountColor = transactionType == 'income' ? Colors.green : Colors.red;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              transaction['description'] ?? 'No description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            subtitle: Text(
              transaction['transaction_date'] ?? 'No date',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            trailing: Text(
              'Rp $amount',
              style: TextStyle(
                color: amountColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  // Fungsi untuk filter pencarian
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          labelText: 'Cari Transaksi',
          prefixIcon: Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          _fetchTransactions();
        },
      ),
    );
  }

  // Fungsi untuk memilih tanggal mulai
  Widget _buildStartDateSelector() {
    return Row(
      children: [
        const Text('Pilih Tanggal Mulai:', style: TextStyle(fontWeight: FontWeight.bold)),
        IconButton(
          icon: Icon(Icons.calendar_today, color: Colors.blueAccent),
          onPressed: () async {
            DateTime? newStartDate = await showDatePicker(
              context: context,
              initialDate: _startDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            setState(() {
              _startDate = newStartDate;
            });
          },
        ),
        Text(_startDate != null
            ? "${_startDate!.toLocal()}".split(' ')[0]
            : 'Pilih Tanggal Mulai', style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  // Fungsi untuk memilih tanggal akhir
  Widget _buildEndDateSelector() {
    return Row(
      children: [
        const Text('Pilih Tanggal Akhir:', style: TextStyle(fontWeight: FontWeight.bold)),
        IconButton(
          icon: Icon(Icons.calendar_today, color: Colors.blueAccent),
          onPressed: () async {
            DateTime? newEndDate = await showDatePicker(
              context: context,
              initialDate: _endDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            setState(() {
              _endDate = newEndDate;
            });
          },
        ),
        Text(_endDate != null
            ? "${_endDate!.toLocal()}".split(' ')[0]
            : 'Pilih Tanggal Akhir', style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  // Fungsi untuk tombol pencarian berdasarkan rentang tanggal
  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: _fetchTransactions,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,  // Set background color to blueAccent
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Rounded corners
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24), // Padding for button
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Set text style
      ),
      child: Text(
        'Cari Transaksi',  // Button text
        style: TextStyle(
          color: Colors.white,  // Set text color to white
          fontWeight: FontWeight.bold,  // Make text bold
          fontSize: 16,  // Set font size
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Transaksi'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView( // Use SingleChildScrollView to allow scrolling
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              _buildStartDateSelector(),
              _buildEndDateSelector(),
              _buildSearchButton(),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                      ? Center(child: const Text('Gagal mengambil transaksi'))
                      : Container( // Wrap the ListView inside a Container
                          height: 400, // Set a fixed height for the list to avoid overflow
                          child: _buildTransactionList(),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
