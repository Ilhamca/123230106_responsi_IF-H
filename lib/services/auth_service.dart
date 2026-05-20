import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _sessionKey = 'is_logged_in';
  static const String _usernameKey = 'current_username';
  static const String _storedUsernameKey = 'stored_username';
  static const String _storedPasswordKey = 'stored_password';
  static const String _cartKey = 'cart_ids';
  static const String _profileImageKey = 'profile_image_path';

  static Future<bool> register(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storedUsernameKey, username);
      await prefs.setString(_storedPasswordKey, password);
      await prefs.setBool(_sessionKey, true);
      await prefs.setString(_usernameKey, username);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> login(String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUsername = prefs.getString(_storedUsernameKey);
      final storedPassword = prefs.getString(_storedPasswordKey);

      if (storedUsername != null && storedPassword != null) {
        if (storedUsername != username || storedPassword != password) {
          return false;
        }
      } else {
        await prefs.setString(_storedUsernameKey, username);
        await prefs.setString(_storedPasswordKey, password);
      }

      await prefs.setBool(_sessionKey, true);
      await prefs.setString(_usernameKey, username);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, false);
    await prefs.remove(_usernameKey);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sessionKey) ?? false;
  }

  static Future<String> getCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey) ?? 'User';
  }

  static Future<List<String>> getCartIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_cartKey) ?? <String>[];
  }

  static Future<bool> isInCart(int productId) async {
    final cartIds = await getCartIds();
    return cartIds.contains(productId.toString());
  }

  static Future<List<String>> toggleCartId(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final cartIds = prefs.getStringList(_cartKey) ?? <String>[];
    final id = productId.toString();

    if (cartIds.contains(id)) {
      cartIds.remove(id);
    } else {
      cartIds.add(id);
    }

    await prefs.setStringList(_cartKey, cartIds);
    return cartIds;
  }

  static Future<void> setCartIds(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_cartKey, ids);
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }

  static Future<String> getProfileImagePath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileImageKey) ?? '';
  }

  static Future<void> setProfileImagePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImageKey, path);
  }
}
