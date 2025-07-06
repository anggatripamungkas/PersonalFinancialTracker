import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';  // Untuk penyimpanan aman

class ApiService {
  static const String baseUrl = 'https://jurnal.fahrifirdaus.cloud/api/v1/';
  static final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  // Fungsi untuk mengambil token dari penyimpanan yang aman
  static Future<String?> getAccessToken() async {
    String? token = await secureStorage.read(key: 'access_token');
    print('Access Token: $token'); // Log token untuk cek
    return token;
  }

  // Fungsi untuk membuat POST request (misalnya untuk login)
  static Future<Map<String, dynamic>> postRequest(String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + endpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final responseData = json.decode(response.body);
        throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Fungsi untuk mengambil data dashboard (wallets dan total balance)
 static Future<Map<String, dynamic>> fetchDashboardData({String? search, String? ordering}) async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    final uri = Uri.parse(baseUrl + 'finance/wallets/')
      .replace(queryParameters: {
        'search': search ?? '',
        'ordering': ordering ?? '',
        // Bisa menambahkan page dan page_size jika diperlukan
      });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan: $e');
  }
}

  // Fungsi untuk menambahkan wallet
  static Future<Map<String, dynamic>> createWallet(String name, double balance) async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        throw Exception('Tidak ada akses token');
      }

      final response = await http.post(
        Uri.parse(baseUrl + 'finance/wallets/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode({
          'name': name,
          'current_balance': balance,  // Menggunakan current_balance sesuai API response
          'initial_balance': balance,  // Jika diperlukan untuk menyimpan saldo awal
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final responseData = json.decode(response.body);
        throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

static Future<Map<String, dynamic>> updateWallet(String id, String name, bool isActive) async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    final response = await http.put(
      Uri.parse(baseUrl + 'finance/wallets/$id/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'name': name,
        'is_active': isActive,  // Pastikan is_active bertipe bool
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan: $e');
  }
}

  // Fungsi untuk menghapus wallet
  static Future<Map<String, dynamic>> deleteWallet(String id) async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        throw Exception('Tidak ada akses token');
      }

      // Log nilai id
      print('ID Wallet untuk dihapus: $id');

      final response = await http.delete(
        Uri.parse(baseUrl + 'finance/wallets/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final responseData = json.decode(response.body);
        throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Fungsi untuk mengambil data wallet
  static Future<List<Map<String, dynamic>>> fetchWallets() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        throw Exception('Tidak ada akses token');
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'finance/wallets/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['results']);
      } else {
        final responseData = json.decode(response.body);
        throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Fungsi untuk membuat transfer baru antar wallet
 // Fungsi untuk membuat transfer baru antar wallet
static Future<Map<String, dynamic>> createTransfer(
    int fromWalletId, int toWalletId, double amount, double fee) async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    final response = await http.post(
      Uri.parse(baseUrl + 'finance/transfers/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'from_wallet': fromWalletId,
        'to_wallet': toWalletId,
        'amount': amount.toString(),
        'fee': fee.toString(),
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan: $e');
  }
}

  // Fungsi untuk mengambil detail transfer berdasarkan ID
  static Future<Map<String, dynamic>> fetchTransferDetails(String id) async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) {
        throw Exception('Tidak ada akses token');
      }

      final response = await http.get(
        Uri.parse(baseUrl + 'finance/transfers/$id/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final responseData = json.decode(response.body);
        throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }


  // Fungsi untuk menghapus token dari penyimpanan yang aman (untuk logout)
  static Future<void> logout() async {
    await secureStorage.delete(key: 'access_token');
    print('Access token deleted');
  }

  // Fungsi untuk mengambil histori transfer
static Future<List<Map<String, dynamic>>> fetchTransferHistory() async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    final response = await http.get(
      Uri.parse(baseUrl + 'finance/transfers/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan: $e');
  }
}

static Future<Map<String, dynamic>> createTransaction({
  required int wallet,
  required int category,
  required String amount,
  required String type,
  required String description,
  required DateTime transactionDate,
  required List<int> tags,
}) async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    final response = await http.post(
      Uri.parse(baseUrl + 'finance/transactions/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode({
        'wallet': wallet,
        'category': category,
        'amount': amount.toString(),
        'type': type,
        'description': description,
        'transaction_date': transactionDate.toIso8601String().split('T')[0],  // Menyaring hanya tanggal (yyyy-MM-dd)
        'tag_ids': tags,
      }),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final responseData = json.decode(response.body);
      print('Response Error: ${responseData['message']}');
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    print('Error during request: $e');
    throw Exception('Terjadi kesalahan: $e');
  }
}


static Future<List<Map<String, dynamic>>> fetchTransactions({
  String? search,
  String? startDate,  // Tanggal mulai
  String? endDate,    // Tanggal akhir
  int page = 1,
  int pageSize = 10,
}) async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    // Mengambil transaksi dari API dengan filter tanggal
    final uri = Uri.parse(baseUrl + 'finance/transactions/').replace(queryParameters: {
      'search': search ?? '',
      'start_date': startDate,  // Kirim tanggal mulai
      'end_date': endDate,      // Kirim tanggal akhir
      'page': '$page',
      'page_size': '$pageSize',
    });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan: $e');
  }
}



// Fungsi untuk mengambil laporan bulanan transaksi
static Future<List<Map<String, dynamic>>> fetchMonthlyReport() async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    final uri = Uri.parse(baseUrl + 'finance/transactions/monthly_report/');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan: $e');
  }
}

// Fungsi untuk mengambil daftar kategori
static Future<List<Map<String, dynamic>>> fetchCategories() async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    final response = await http.get(
      Uri.parse(baseUrl + 'finance/categories/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan: $e');
  }
}

// Fungsi untuk mengambil daftar tags
static Future<List<Map<String, dynamic>>> fetchTags() async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    final response = await http.get(
      Uri.parse(baseUrl + 'finance/tags/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan: $e');
  }
}

// Fungsi untuk mengambil ringkasan bulanan
static Future<Map<String, dynamic>> fetchMonthlySummary() async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    final response = await http.get(
      Uri.parse(baseUrl + 'finance/transactions/summary/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan: $e');
  }
}

// Fungsi untuk mengambil kategori pengeluaran
static Future<List<Map<String, dynamic>>> fetchExpenseCategories() async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    final response = await http.get(
      Uri.parse(baseUrl + 'finance/categories/expense/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan: $e');
  }
}

static Future<Map<String, dynamic>> putRequest(String endpoint, Map<String, dynamic> body) async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    final response = await http.put(
      Uri.parse(baseUrl + endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan: $e');
  }
}

static Future<Map<String, dynamic>> deleteRequest(String endpoint) async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    final response = await http.delete(
      Uri.parse(baseUrl + endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan: $e');
  }
}

  // Fungsi untuk POST request
  static Future<Map<String, dynamic>> postKategori(String endpoint, Map<String, dynamic> body) async {
    try {
      final accessToken = await getAccessToken(); // Fungsi untuk mendapatkan access token
      if (accessToken == null) {
        throw Exception('Tidak ada akses token');
      }

      final response = await http.post(
        Uri.parse(baseUrl + endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        // Jika request sukses dan status code adalah 201 (Created)
        return json.decode(response.body);
      } else {
        final responseData = json.decode(response.body);
        throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Get User Profile
static Future<Map<String, dynamic>> getUserProfile() async {
  try {
    final accessToken = await getAccessToken();
    if (accessToken == null) {
      throw Exception('Tidak ada akses token');
    }

    final response = await http.get(
      Uri.parse(baseUrl + 'auth/profile/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final responseData = json.decode(response.body);
      throw Exception('Error: ${responseData['message'] ?? 'Request gagal'}');
    }
  } catch (e) {
    throw Exception('Terjadi kesalahan: $e');
  }
}

}

