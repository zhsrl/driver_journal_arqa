import 'dart:convert';
import 'package:driver_journal_arqa/data/trip.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Базовый адрес FastAPI бэкенда для Web
  static const String baseUrl = 'http://127.0.0.1:8000';

  static Future<DailySummary?> fetchSummary(String dateStr) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/trips/summary?date=$dateStr'),
      );

      if (response.statusCode == 200) {
        return DailySummary.fromJson(jsonDecode(response.body));
      }

      return null;
    } catch (e) {
      throw Exception('Error api: $e');
    }
  }

  static Future<Map<String, dynamic>> addTrip(Trip trip) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/trips'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(trip.toJson()),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка сохранения: ${response.body}');
    }
  }
}
