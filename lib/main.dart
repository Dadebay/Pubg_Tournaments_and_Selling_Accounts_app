import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:game_app/provider/getkonkur.dart';
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

Future<void> backgroundNotificationHandler(RemoteMessage message) async {
  await FCMConfig().sendNotification(body: message.notification!.body!, title: message.notification!.title!);
  return;
}

Future<void> main() async {
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
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
    ErrorWidget.builder = (FlutterErrorDetails details) => const Material();
  }

  dynamic firebaseTask() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      FCMConfig().sendNotification(body: message.notification!.body!, title: message.notification!.title!);
    });
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
