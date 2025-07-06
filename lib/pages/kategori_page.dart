import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Ganti dengan import ApiService yang sebenarnya

class KategoriPage extends StatefulWidget {
  @override
  _KategoriPageState createState() => _KategoriPageState();
}

class _KategoriPageState extends State<KategoriPage> {
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _iconController = TextEditingController();
  TextEditingController _colorController = TextEditingController();
  String _selectedType = 'income'; // Defaultnya adalah income

  // Ambil kategori dan tag
  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Ambil kategori dari API
  Future<void> _fetchCategories() async {
    try {
      final categories = await ApiService.fetchCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error mengambil kategori: $e');
    }
  }

  // Menambahkan kategori baru
  Future<void> _addCategory() async {

    try {
      _fetchCategories();
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kategori berhasil ditambahkan')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error menambahkan kategori: $e')));
    }
  }

  // Mengedit kategori yang sudah ada
  Future<void> _editCategory(String id) async {

    try {
      _fetchCategories();
      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kategori berhasil diperbarui')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error memperbarui kategori: $e')));
    }
  }

  // Menghapus kategori
  Future<void> _deleteCategory(String id) async {
    try {
      await ApiService.deleteRequest('finance/categories/$id/');
      _fetchCategories();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Kategori berhasil dihapus')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error menghapus kategori: $e')));
    }
  }

  // Membersihkan form input
  void _clearForm() {
    _nameController.clear();
    _iconController.clear();
    _colorController.clear();
    _selectedType = 'income'; // Reset tipe ke default setelah form dibersihkan
  }

  // Menampilkan dialog untuk menambah atau mengedit kategori
  void _showCategoryDialog({String? id}) {
    if (id != null) {
      // Jika kita mengedit kategori yang sudah ada, isi form dengan data kategori tersebut
      final category = _categories.firstWhere((cat) => cat['id'] == int.parse(id));
      _nameController.text = category['name'];
      _iconController.text = category['icon'];
      _colorController.text = category['color'];
      _selectedType = category['type']; // Set tipe berdasarkan kategori yang ada
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(id == null ? 'Tambah Kategori' : 'Edit Kategori'),
          content: SingleChildScrollView(  // Membuat konten bisa digulir
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Nama Kategori'),
                ),
                TextField(
                  controller: _iconController,
                  decoration: InputDecoration(labelText: 'Ikon'),
                ),
                TextField(
                  controller: _colorController,
                  decoration: InputDecoration(labelText: 'Warna (misal: merah)'),
                ),
                // Dropdown untuk memilih tipe kategori
                DropdownButton<String>(
                  value: _selectedType,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedType = newValue!;
                    });
                  },
                  items: <String>['income', 'expense']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value[0].toUpperCase() + value.substring(1)), // Menampilkan dengan huruf kapital
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (id == null) {
                  _addCategory();
                } else {
                  _editCategory(id);
                }
                Navigator.pop(context);
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  // Menampilkan daftar kategori
  Widget _buildCategoryList() {
    return ListView.builder(
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return ListTile(
          leading: Icon(Icons.category), // Anda bisa menambahkan ikon khusus dari category['icon']
          title: Text(category['name']),
          subtitle: Text('Warna: ${category['color']}, Tipe: ${category['type']}'), // Menambahkan tipe kategori
          trailing: PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'edit') {
                _showCategoryDialog(id: category['id'].toString());
              } else if (action == 'delete') {
                _deleteCategory(category['id'].toString());
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
              PopupMenuItem<String>(value: 'delete', child: Text('Hapus')),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kategori'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showCategoryDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildCategoryList(),
    );
  }
}
