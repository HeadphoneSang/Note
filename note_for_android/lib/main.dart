import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/network/http_client.dart';

void main() {
  HttpClient.init(
    baseUrl: 'http://47.104.25.40:8080',
    // Chrome CORS 调试：用 --disable-web-security 启动浏览器
    // 或直接切换到 Windows 桌面模式跑：flutter run -d windows
  );
  runApp(const App());
}
