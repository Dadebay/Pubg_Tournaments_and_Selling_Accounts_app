// ignore_for_file: prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import 'connection_check.dart';
import 'controllers/all_controller_bindings.dart';
import 'utils/translations.dart';
import 'views/constants/index.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel', // id
  'High Importance Notifications', // title
  // 'This channel is used for important notifications.',
  description: 'This channel is used for important notifications.', // description
  importance: Importance.high,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  await flutterLocalNotificationsPlugin.show(
    message.data.hashCode,
    message.notification!.title,
    message.notification!.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        // '',
        channelDescription: channel.description,
        color: Colors.white,
        styleInformation: const BigTextStyleInformation(''),
        icon: '@mipmap/ic_launcher',
      ),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  HttpOverrides.global = MyHttpOverrides();
  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: null,
    macOS: null,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: kPrimaryColorBlack,
      statusBarColor: kPrimaryColorBlack,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyAppRun());
}

class MyAppRun extends StatefulWidget {
  const MyAppRun({Key? key}) : super(key: key);

  @override
  State<MyAppRun> createState() => _MyAppRunState();
}

class _MyAppRunState extends State<MyAppRun> {
  final storage = GetStorage();

  dynamic firebaseMessagingPart() {
    FirebaseMessaging.instance.subscribeToTopic('EVENT');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      flutterLocalNotificationsPlugin.show(
        message.data.hashCode,
        message.notification!.title,
        message.notification!.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            // '',
            channelDescription: channel.description,
            styleInformation: const BigTextStyleInformation(''),
            color: Colors.white,
            icon: '@mipmap/ic_launcher',
          ),
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      Get.to(() => ConnectionCheck());
    });
  }

  @override
  void initState() {
    super.initState();
    firebaseMessagingPart();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AllControllerBindings(),
      defaultTransition: Transition.fade,
      locale: storage.read('langCode') != null
          ? Locale(storage.read('langCode'))
          : const Locale(
              'tr',
            ),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: josefinSansRegular,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      fallbackLocale: const Locale('tr'),
      translations: MyTranslations(),
      debugShowCheckedModeBanner: false,
      home: ConnectionCheck(),
    );
  }
}
