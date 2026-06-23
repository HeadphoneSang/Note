import 'package:flutter/material.dart';
import 'package:note_for_android/core/network/http_client.dart';
import 'package:provider/provider.dart';
import '../../core/store/user_store.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _accountCtrl = TextEditingController(text: 'test');
  final _passwordCtrl = TextEditingController(text: '123456');

  // 💡 新增控制状态
  bool _obscurePassword = true; // 密码是否隐藏
  bool _isLoading = false; // 是否正在登录中

  @override
  void dispose() {
    _accountCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handlerLoginResponse(
    ApiResponse<Map<String, dynamic>> response,
  ) async {
    if (response.code == 200) {
      Map<String, dynamic> data = response.data!;
      String bToken = data['token']!;
      Map<String, dynamic> userInfo = data['userInfo']!;
      final store = context.read<UserStore>();
      await store.login(token: bToken, user: UserInfo.fromJson(userInfo));
    } else if (response.code == 400) {
      // 处理登录失败的情况，例如账号或密码错误
      final errorMessage = response.data?['message'] ?? '登录失败，请检查账号和密码';
      throw Exception(errorMessage);
    } else {
      throw Exception('登录失败，未知错误');
    }
  }

  Future<void> _login() async {
    // 避免重复点击
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final ApiResponse<Map<String, dynamic>> loginResponse = await HttpClient
          .instance
          .post(
            '/user/login',
            data: {
              'account': _accountCtrl.text,
              'password': _passwordCtrl.text,
            },
          );
      try {
        await _handlerLoginResponse(loginResponse);
        // 登录成功后跳回首页
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
      } catch (e) {
        // print('处理登录时的正常错误，比如密码错误，用户不存在等：$e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // 异常处理（可选，这里先恢复 loading 状态）
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取当前主题色，保证组件色彩和谐
    final theme = Theme.of(context);

    return Scaffold(
      // 使用 SingleChildScrollView 防止键盘弹起时布局溢出报错（Overflow）
      body: SingleChildScrollView(
        child: Container(
          // 让背景铺满整个屏幕高度
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [theme.primaryColor.withOpacity(0.15), Colors.white],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 顶部 Logo 或 欢迎标语区
                Icon(
                  Icons.lock_person_rounded,
                  size: 80,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),
                const Text(
                  '欢迎回来',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '请登录您的账号以继续',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 48),

                // 2. 账号输入框
                TextField(
                  controller: _accountCtrl,
                  decoration: InputDecoration(
                    labelText: '账号',
                    hintText: '请输入账号',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. 密码输入框
                TextField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: '密码',
                    hintText: '请输入密码',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    // 💡 右侧切换密码显隐的小眼睛按钮
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),

                // 4. 忘记密码（预留视觉占位）
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      '忘记密码？',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 5. 登录按钮（包含优雅的 Loading 动效）
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: theme.primaryColor.withOpacity(
                      0.6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          '登 录',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
