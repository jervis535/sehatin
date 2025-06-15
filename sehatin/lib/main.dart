import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sehatin/services/session_service.dart';
import 'package:sehatin/services/auth_service.dart';
import 'package:sehatin/models/user_model.dart';
import 'package:sehatin/screens/login/login_screen.dart'; 
import 'package:sehatin/screens/home/home_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background notification
  print("Handling a background message: ${message.messageId}");
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Firebase.initializeApp();
  dotenv.load(fileName: ".env");
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await _initNotifications();
  runApp(const MyApp());
}

Future<void> _initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sehatin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner:false,
      home: const RootDecider(),
      routes: {
        '/login': (_) => const LoginScreen(),
      },
    );
  }
}

class RootDecider extends StatelessWidget {
  const RootDecider({super.key});

  Future<Widget> _decide() async {
    final token = await SessionService.getToken();
    final userId = await SessionService.getUserId();

    if (token != null && userId != null) {
      try {
        final userJson =
            await AuthService.fetchUserWithToken(userId, token);
        final user = UserModel.fromJson(userJson);

        // ─── NEW: initialize FCM and request permission
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        await messaging.requestPermission(); // iOS

        // ─── NEW: get the FCM token
        String? fcmToken = await messaging.getToken();
        print("🔑 Obtained FCM token: $fcmToken");

        if (fcmToken != null) {
          // ─── NEW: send it to your backend
          final url = Uri.parse('${dotenv.env['API_URL']}/register-token');
          final response = await http.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              'token': fcmToken,
              'platform': 'flutter', // or detect 'android' / 'ios' if you like
            }),
          );
          if (response.statusCode == 200) {
            print('✅ FCM token registered on backend');
          } else {
            print('❌ Failed to register FCM token: ${response.body}');
          }
        }

        // ─── NEW: set up foreground notification handling
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          final notification = message.notification;
          final android = message.notification?.android;
          if (notification != null && android != null) {
            FlutterLocalNotificationsPlugin()
                .show(
                  notification.hashCode,
                  notification.title,
                  notification.body,
                  NotificationDetails(
                    android: AndroidNotificationDetails(
                      'chat_messages',       // channelId
                      'Chat Messages',       // channelName
                      importance: Importance.max,
                      priority: Priority.high,
                    ),
                  ),
                  payload: jsonEncode(message.data),
                )
                .then((_) => print("🔔 Displayed a foreground notification"));
          }
        });

        // ─── NEW: optional: handle taps when app is opened/resumed
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          print("🚀 onMessageOpenedApp data: ${message.data}");
          // e.g. navigate to the specific chat screen using message.data['channel_id']
        });

        // ─── Return your HomeScreen only after we have registered the token
        return HomeScreen(user: user, token: token);
      } catch (_) {
        await SessionService.clearSession();
      }
    }
    return const LoginScreen();
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _decide(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return snapshot.data!;
      },
    );
  }
}
