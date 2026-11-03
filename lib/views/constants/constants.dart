import 'package:flutter/material.dart';

/// The ucdayy mobile API (docs: /api/docs/). The old backend on port 80 has its
/// own database, so balances and accounts set in the admin panel (port 9090)
/// only exist here.
const String serverURL = 'http://ucdayy.com.tm:8080';
const Color backgroundColor = Color(0xfff2f2f2);
const Color kPrimaryColor = Color(0xFFFF9800);
const kAccentColor = Color(0xFFFFB74D);
const kDarkOrange = Color(0xFFF57C00);
const Color kPrimaryColorBlack = Colors.black;
const Color kPrimaryColorBlack1 = Color.fromARGB(255, 37, 42, 51);
const MaterialColor colorCustom = MaterialColor(0xff55b539, color);

const Map<int, Color> color = {
  50: Color.fromRGBO(255, 92, 87, .1),
  100: Color.fromRGBO(255, 92, 87, .2),
  200: Color.fromRGBO(255, 92, 87, .3),
  300: Color.fromRGBO(255, 92, 87, .4),
  400: Color.fromRGBO(255, 92, 87, .5),
  500: Color.fromRGBO(255, 92, 87, .6),
  600: Color.fromRGBO(255, 92, 87, .7),
  700: Color.fromRGBO(255, 92, 87, .8),
  800: Color.fromRGBO(255, 92, 87, .9),
  900: Color.fromRGBO(255, 92, 87, 1),
};

///BorderRadius
const BorderRadius borderRadius5 = BorderRadius.all(Radius.circular(5));
const BorderRadius borderRadius10 = BorderRadius.all(Radius.circular(10));
const BorderRadius borderRadius15 = BorderRadius.all(Radius.circular(15));
const BorderRadius borderRadius20 = BorderRadius.all(Radius.circular(20));
const BorderRadius borderRadius25 = BorderRadius.all(Radius.circular(25));
const BorderRadius borderRadius30 = BorderRadius.all(Radius.circular(30));
/////////////////////////////////
const String gilroyRegular = 'GilroyRegular';
const String gilroyMedium = 'GilroyMedium';
const String gilroySemiBold = 'GilroySemiBold';
const String gilroyBold = 'GilroyBold';
//Language icons
const String tmIcon = 'assets/lang/tm.png';
const String ruIcon = 'assets/lang/ru.png';
const String trIcon = 'assets/lang/tr.png';
const String accountBackImage = 'assets/image/3.png';
const String logo = 'assets/image/logo.png';
const String loader = 'assets/lottie/spinKit.json';
const String noDataLottie = 'assets/lottie/noData.json';
const String appName = 'UC Daýy';
const String appShareLink = 'https://ucdayy.online/';
const String playStoreLink = 'https://play.google.com/store/apps/details?id=com.gurbanov.ucdayy';
const String appStoreLink = 'https://apps.apple.com/tm/app/uc-dayy/id6737436233';
const String loremImpsum =
    'Lorem ipsum, yaygın olarak kullanılan bir yer tutucu metne verilen isimdir. Dolgu veya sahte metin olarak da bilinen bu tip yer tutucu metinler, aslında anlamlı bir şey söylemeden bir alanı doldurmaya yarayan metinlerdir,Lorem ipsum, yaygın olarak kullanılan bir yer tutucu metne verilen isimdir. Dolgu veya sahte metin olarak da bilinen bu tip yer tutucu metinler, aslında anlamlı bir şey söylemeden bir alanı doldurmaya yarayan metinlerdir,Lorem ipsum, yaygın olarak kullanılan bir yer tutucu metne verilen isimdir. Dolgu veya sahte metin olarak da bilinen bu tip yer tutucu metinler, aslında anlamlı bir şey söylemeden bir alanı doldurmaya yarayan metinlerdir,Lorem ipsum, yaygın olarak kullanılan bir yer tutucu metne verilen isimdir. Dolgu veya sahte metin olarak da bilinen bu tip yer tutucu metinler, aslında anlamlı bir şey söylemeden bir alanı doldurmaya yarayan metinlerdir';

/////////////////////////////////////////////////

const List sortData = [
  {
    'id': 1,
    'name': 'sortDefault',
    'sort_column': 'price',
    'sort_direction': '',
  },
  {
    'id': 2,
    'name': 'sortPriceLowToHigh',
    'sort_column': 'price',
    'sort_direction': 'high',
  },
  {
    'id': 3,
    'name': 'sortPriceHighToLow',
    'sort_column': 'price',
    'sort_direction': 'low',
  },
  {
    'id': 4,
    'name': 'sortCreatedAtHighToLow',
    'sort_column': 'date',
    'sort_direction': 'new',
  },
  {
    'id': 5,
    'name': 'sortCreatedAtLowToHigh',
    'sort_column': 'date',
    'sort_direction': 'old',
  },
];
