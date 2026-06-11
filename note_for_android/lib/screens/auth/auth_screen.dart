import 'package:flutter/material.dart';
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

  Future<void> _login() async {
    // 避免重复点击
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final store = context.read<UserStore>();

      // 模拟登录请求 — 后续换成真实 API
      await Future.delayed(const Duration(seconds: 1));

      // 假设登录成功，拿到服务端返回的数据
      await store.login(
        token: 'mock_token_abc123',
        user: UserInfo(
          id: 1,
          account: _accountCtrl.text,
          gender: 'male',
          nickname: '用户${_accountCtrl.text}',
        ),
      );

      if (!mounted) return;

      // 登录成功后跳回首页
      Navigator.pushReplacementNamed(context, '/');
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
