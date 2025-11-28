import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

const String API_BASE_URL = "http://192.168.1.71:8000";

class AuthService {
  Future<String?> login(String username, String password) async {
    try {
      final url = Uri.parse("$API_BASE_URL/login");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Accept": "application/json",
        },
        body: {
          "username": username,
          "password": password,
        },
      );

      print("[LOGIN] STATUS: ${response.statusCode}");
      print("[LOGIN] BODY: ${response.body}");

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final token = jsonData["access_token"];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("jwt_token", token);

        return token;
      }

      return null;
    } catch (e) {
      print("[AuthService] Error en login: $e");
      return null;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("jwt_token");
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("jwt_token");
  }
}
