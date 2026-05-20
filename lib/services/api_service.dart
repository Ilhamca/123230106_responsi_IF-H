// ============================================================
// SERVICE - HTTP REQUEST
// ============================================================
// Service adalah class yang bertanggung jawab untuk:
// 1. Mengambil data dari API (HTTP GET)
// 2. Mengirim data ke API (HTTP POST/PUT/DELETE)
//
// Konsep penting:
// - async/await: operasi asinkron (tidak memblokir UI)
// - Future<T>: nilai yang akan ada di masa depan
// - try/catch: menangani error
// - http package: library untuk HTTP request
// ============================================================

import 'dart:convert'; // Untuk jsonDecode
import 'package:http/http.dart' as http; // Prefix 'as http' agar tidak bentrok
import '../models/article.dart';
import '../models/category.dart';

class ApiService {
  // ============================================================
  // BASE URL - Dipisah agar mudah diganti
  // Tips: Simpan base URL di satu tempat saja (single source of truth)
  // Jika URL berubah, hanya perlu ubah di sini
  // ============================================================
  // BASE URL untuk produk
  static const String _baseUrl = 'https://dummyjson.com/products';


  // ============================================================
  // FETCH LIST DATA
  // Mengambil daftar produk dari API
  //
  // Parameter:
  // - limit: jumlah item per halaman (default 10)
  // - skip: mulai dari item ke berapa (untuk pagination)
  //
  // Return: Future<List<Article>>
  // Future artinya fungsi ini akan selesai di masa depan (async)
  //
  // Contoh: 
  // fetchArticles(limit: 10, skip: 0) → mengambil 10 produk pertama
  // fetchArticles(limit: 10, skip: 10) → mengambil 10 produk berikutnya (halaman 2)
  // ============================================================
  static Future<List<Article>> fetchArticles({
    int limit = 10,
    int skip = 0,
  }) async {
    // Uri.parse + queryParameters: cara aman membuat URL dengan parameter
    // Hasil: https://dummyjson.com/products?limit=10&skip=0
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'limit': limit.toString(),
        'skip': skip.toString(),
      },
    );

    try {
      // await: tunggu sampai HTTP request selesai
      // http.get() mengembalikan Future<Response>
      final response = await http.get(uri);

      // Cek status code HTTP
      // 200 = OK, 404 = Not Found, 500 = Server Error, dll
      if (response.statusCode == 200) {
        // response.body adalah String JSON
        // jsonDecode mengubah String JSON → Map<String, dynamic>
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        // Gunakan model ArticleResponse untuk parse data
        final articleResponse = ArticleResponse.fromJson(jsonData);
        return articleResponse.results;
      } else {
        // Jika status bukan 200, lempar Exception
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      // catch semua error (network error, parse error, dll)
      throw Exception('Error: $e');
    }
  }

  // Fetch product categories
  static Future<List<Category>> fetchCategories() async {
    final uri = Uri.parse('https://dummyjson.com/products/category-list');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((e) {
          if (e is Map<String, dynamic>) {
            return Category.fromJson(e);
          }
          final value = e.toString();
          return Category(slug: value, name: value);
        }).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Fetch products by category
  static Future<List<Article>> fetchProductsByCategory(String category,
      {int limit = 10, int skip = 0}) async {
    final uri = Uri.parse('https://dummyjson.com/products/category/$category')
        .replace(queryParameters: {
      'limit': limit.toString(),
      'skip': skip.toString(),
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final articleResponse = ArticleResponse.fromJson(jsonData);
        return articleResponse.results;
      } else {
        throw Exception('Failed to load category data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // ============================================================
  // FETCH DETAIL DATA
  // Mengambil detail satu produk berdasarkan ID
  // Berguna untuk: menampilkan detail produk sebelum ditambahkan ke cart
  //
  // Contoh URL: https://dummyjson.com/products/1
  // 
  // Gunakan saat:
  // - User membuka halaman detail produk
  // - User akan menambahkan produk ke cart
  // ============================================================
  static Future<Article> fetchArticleDetail({
    required int id,
  }) async {
    final uri = Uri.parse('$_baseUrl/$id');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        // Untuk detail, API langsung mengembalikan object produk
        // (bukan list), jadi langsung parse ke Article
        return Article.fromJson(jsonData);
      } else {
        throw Exception('Failed to load details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
