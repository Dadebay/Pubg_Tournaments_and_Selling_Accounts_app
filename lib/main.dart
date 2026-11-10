import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:game_app/provider/getkonkur.dart';
import 'package:game_app/utils/api_logger.dart';
import 'package:game_app/controllers/notification_badge_controller.dart';
import 'package:game_app/utils/guard_client.dart';
import 'package:game_app/utils/order_push.dart';
import 'package:game_app/utils/server_status.dart';
import 'package:game_app/utils/support_push.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:game_app/views/constants/notification_service.dart';
import 'package:game_app/views/home_page/paymant/data/team_members_provider.dart';
import 'package:game_app/views/home_page/paymant/data/tournament_provider.dart';
import 'package:game_app/views/home_page/paymant/data/transfer_provider.dart';
import 'package:provider/provider.dart';

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

@pragma('vm:entry-point')
Future<void> backgroundNotificationHandler(RemoteMessage message) async {
  // The system already shows a push that carries a `notification`; only data pushes are drawn here.
  final notification = message.notification;
  if (notification != null && SupportPush.isSupport(message)) {
    return;
  }
  final title = notification?.title ?? '${message.data['title'] ?? ''}';
  final body = notification?.body ?? '${message.data['body'] ?? ''}';
  if (title.isEmpty && body.isEmpty) {
    return;
  }
  await FCMConfig().sendNotification(title: title, body: body, payload: OrderPush.payload(message));
}

void main() {
  // Every `http.get` / `http.post` of the app goes through the guard (maintenance and ban
  // answers); in debug mode also through the colored logger.
  http.runWithClient(_main, () => GuardClient(kDebugMode ? LoggingClient(IOClient()) : IOClient()));
}

Future<void> _main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  HttpOverrides.global = MyHttpOverrides();
  await Firebase.initializeApp();
  await FCMConfig().requestPermission();
  await FCMConfig().initAwesomeNotification();
  FirebaseMessaging.onBackgroundMessage(backgroundNotificationHandler);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: kPrimaryColorBlack,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarContrastEnforced: false,
      statusBarColor: kPrimaryColorBlack,
    ),
  );

  // Hide the Android system navigation bar; it comes back for a moment on an edge swipe.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky, overlays: [SystemUiOverlay.top]);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConCatigoryProvider()),
        ChangeNotifierProvider(create: (_) => getGiftsProvider()),
        ChangeNotifierProvider(create: (_) => getConcursProvider()),
        ChangeNotifierProvider(create: (_) => getConcursByIDProvider()),
        ChangeNotifierProvider(create: (_) => postPaymentProvider()),
        ChangeNotifierProvider(create: (_) => TransferProvider()),
        ChangeNotifierProvider(create: (_) => TournamentProvider()),
        ChangeNotifierProvider(create: (_) => TeamMembersProvider()),
      ],
      child: const MyAppRun(),
    ),
  );
}

class MyAppRun extends StatefulWidget {
  const MyAppRun({super.key});

  @override
  State<MyAppRun> createState() => _MyAppRunState();
}

class _MyAppRunState extends State<MyAppRun> {
  final storage = GetStorage();

  @override
  void initState() {
    super.initState();
    firebaseTask();
    ServerStatus.instance.start();
    ErrorWidget.builder = (FlutterErrorDetails details) => const Material();
  }

  dynamic firebaseTask() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // A broadcast of the admin (topic EVENT): a new notification, so the bell badge is refreshed.
      if ((message.from ?? '').endsWith('/EVENT') && Get.isRegistered<NotificationBadgeController>()) {
        Get.find<NotificationBadgeController>().refreshCount();
      }
      final support = SupportPush.isSupport(message);
      if (support) {
        SupportPush.refreshUnread();
        // The open chat shows the reply itself.
        if (SupportPush.chatOpen) {
          return;
        }
      }
      final title = message.notification?.title ?? '${message.data['title'] ?? ''}';
      final body = message.notification?.body ?? '${message.data['body'] ?? ''}';
      if (title.isEmpty && body.isEmpty) {
        return;
      }
      FCMConfig().sendNotification(title: title, body: body, payload: OrderPush.payload(message));
    });
    // The app was in the background and a notification was tapped.
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (SupportPush.isSupport(message)) {
        SupportPush.open();
      } else if (OrderPush.isOrder(message)) {
        OrderPush.open();
      }
    });
    // The app was closed and a notification started it.
    final initial = await FirebaseMessaging.instance.getInitialMessage();
    if (initial != null && SupportPush.isSupport(initial)) {
      SupportPush.open();
    } else if (initial != null && OrderPush.isOrder(initial)) {
      OrderPush.open();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialBinding: AllControllerBindings(),
      defaultTransition: Transition.fade,
      locale: storage.read('langCode') != null ? Locale(storage.read('langCode')) : const Locale('tr'),
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Gilroy',
        // Pure black pages, and an app bar that keeps its colour when content scrolls under it.
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black, scrolledUnderElevation: 0, surfaceTintColor: Colors.transparent),
      ),
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Gilroy',
        useMaterial3: true,
        // Pure black pages, and an app bar that keeps its colour when content scrolls under it.
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black, scrolledUnderElevation: 0, surfaceTintColor: Colors.transparent),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      fallbackLocale: const Locale('tr'),
      translations: MyTranslations(),
      debugShowCheckedModeBanner: false,
      home: const ConnectionCheck(),
    );
  }
}
