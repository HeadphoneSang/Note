import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 用户信息模型
class UserInfo {
  final int id;
  final String account;
  final String gender;
  final String nickname;
  final String? avatar;
  final String? phoneNumber;

  const UserInfo({
    required this.id,
    required this.account,
    required this.gender,
    required this.nickname,
    this.avatar,
    this.phoneNumber,
  });
}

/// 全局用户状态管理
/// 用 `context.read<UserStore>()` 读取，`context.watch<UserStore>()` 监听变化
class UserStore extends ChangeNotifier {
  static const _kTokenKey = 'user_token';

  // ---- 状态 ----
  UserInfo? _user;
  String? _token;
  bool _isLoggedIn = false;
  bool _initialized = false;

  // ---- Getter ----
  UserInfo? get user => _user;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get initialized => _initialized;

  /// 启动时调用：从本地读取 token，恢复登录状态
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kTokenKey);
    _isLoggedIn = _token != null;
    _initialized = true;
    debugPrint('[UserStore] init() — token=${_token != null ? "已存在 ($_token)" : "无"}');
    notifyListeners();
  }

  // ---- 登录 ----
  Future<void> login({required UserInfo user, required String token}) async {
    _user = user;
    _token = token;
    _isLoggedIn = true;

    // 持久化 token
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTokenKey, token);
    debugPrint('[UserStore] login() — token 已保存到本地 ($token)');

    notifyListeners();
  }

  // ---- 登出 ----
  Future<void> logout() async {
    _user = null;
    _token = null;
    _isLoggedIn = false;

    // 清除本地 token
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    debugPrint('[UserStore] logout() — 本地 token 已清除');

    notifyListeners();
  }

  // ---- 更新用户信息（不改登录状态） ----
  void updateUser(UserInfo user) {
    _user = user;
    notifyListeners();
  }
}
