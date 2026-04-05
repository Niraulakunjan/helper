import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/models.dart';

const String baseUrl = 'http://127.0.0.1:8000';

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // --- Auth ---
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['error'] ?? 'Login failed');
  }

  static Future<UserModel> register(Map<String, String> data) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/auth/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    if (res.statusCode == 201) return UserModel.fromJson(jsonDecode(res.body));
    throw Exception('Registration failed: ${res.body}');
  }

  // --- Services ---
  static Future<List<ServiceModel>> getServices() async {
    final res = await http.get(Uri.parse('$baseUrl/api/services/'));
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => ServiceModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load services');
  }

  static Future<void> registerHelper({
    required int serviceId,
    required double price,
    required String location,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/helpers/register/'),
      headers: await _authHeaders(),
      body: jsonEncode({'service_id': serviceId, 'price': price, 'location': location}),
    );
    if (res.statusCode != 201) {
      throw Exception('Failed to set up profile: ${res.body}');
    }
  }

  static Future<List<HelperModel>> getHelpers({int? serviceId, String? location}) async {
    final uri = Uri.parse('$baseUrl/api/helpers/').replace(queryParameters: {
      if (serviceId != null) 'service_id': serviceId.toString(),
      if (location != null && location.isNotEmpty) 'location': location,
    });
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => HelperModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load helpers');
  }

  // --- Bookings ---
  static Future<BookingModel> createBooking(int helperId, String date) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/bookings/'),
      headers: await _authHeaders(),
      body: jsonEncode({'helper_id': helperId, 'date': date}),
    );
    if (res.statusCode == 201) return BookingModel.fromJson(jsonDecode(res.body));
    throw Exception('Booking failed: ${res.body}');
  }

  static Future<List<BookingModel>> getMyBookings() async {
    final res = await http.get(Uri.parse('$baseUrl/api/bookings/mine/'), headers: await _authHeaders());
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => BookingModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load bookings');
  }

  static Future<void> updateBookingStatus(int bookingId, String status) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/api/bookings/$bookingId/status/'),
      headers: await _authHeaders(),
      body: jsonEncode({'status': status}),
    );
    if (res.statusCode != 200) throw Exception('Status update failed');
  }

  // --- Chat History ---
  static Future<List<MessageModel>> getChatHistory(int otherId) async {
    final res = await http.get(Uri.parse('$baseUrl/api/chat/$otherId/'), headers: await _authHeaders());
    if (res.statusCode == 200) {
      return (jsonDecode(res.body) as List).map((e) => MessageModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load chat history');
  }
}
