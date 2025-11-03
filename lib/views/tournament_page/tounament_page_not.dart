import 'package:game_app/views/constants/index.dart';

class NotTournamentPage extends StatefulWidget {
  const NotTournamentPage({super.key});

  @override
  State<NotTournamentPage> createState() => _NotTournamentPageState();
}

class _NotTournamentPageState extends State<NotTournamentPage> {
  @override
  void initState() {
    super.initState();
  }

  // Complete translations for Turkmen and Russian
  final Map<String, Map<String, String>> translations = {
    'tr': {
      'headerTitle': 'Öwren we ösdür',
      'headerDescription': 'Ýaş PUBG oýunçylary üçin peýdaly maslahatlar we gollanmalar. Has köp öwrenmek üçin islendik karta basyň!',
      'tapToLearn': 'Öwrenmek üçin basyň',
      'bottomReminder': 'Ýatda saklaň: Elmydama howpsuz oýnaň we lezzet alyň!',

      // Safety Tips
      'safetyTitle': 'Howpsuzlyk maslahatlary',
      'safetyShort': 'Howpsuz we jogapkärli oýnamak',
      'safetyFull': 'Oýunlar mydama şatlykly we howpsuz bolmaly! PUBG Mobile oýnanyňyzda berjaý etmeli möhüm howpsuzlyk düzgünleri.',
      'playTimeTitle': 'Oýun wagty çäkleri',
      'playTimeDesc': 'Her 30-45 minutdan arakesme ediň. Gözüňiz we bedeniňiz dynç almalı!',
      'talkParentsTitle': 'Ene-atalar bilen gürleşiň',
      'talkParentsDesc': 'Ene-ataňyza haýsy oýunlary oýnaýandygyňyzy we kim bilen oýnaýandygyňyzy elmydama habar beriň.',
      'onlineFriendsTitle': 'Onlaýn dostlar',
      'onlineFriendsDesc': 'Hiç haçan şahsy maglumatlaryňyzy, salgyňyzy, telefon belgiňizi ýa-da mekdep adyňyzy onlaýn oýunçylar bilen paýlaşmaň.',
      'reportBadTitle': 'Erbet hereketleri habar beriň',
      'reportBadDesc': 'Eger kimdir biri erbet ýa-da sizi oňaýsyz duýýan bolsa, ulylara aýdyň we habar beriň.',
      'voiceChatTitle': 'Ses söhbetdeşlik howpsuzlygy',
      'voiceChatDesc': 'Ses söhbetdeşligini diňe hakyky durmuşda tanaýan adamlar bilen ulanyň. Beýleki oýunçylary sesini öçürip bilersiňiz.',

      // Beginner Tips
      'beginnerTitle': 'Başlangyç maslahatlary',
      'beginnerShort': 'Täze oýunçylar üçin möhüm maslahatlar',
      'beginnerFull': 'PUBG syýahatyňyzy başlaýarsyňyzmy? Bu maslahatlar has gowy oýunçy bolmaga we has köp lezzet almaga kömek eder!',
      'landSafeTitle': 'Howpsuz ýerlerde gonuň',
      'landSafeDesc': 'Başlanyňyzda, howpsuz talapkeşlik üçin uçaryň ýolunyň daşynda has asuda ýerlerde gonuň.',
      'learnControlsTitle': 'Dolandyryşy öwreniň',
      'learnControlsDesc': 'Basyşsyz hereketlenmek, atmak we zatlar ulanmagy öwrenmek üçin türgenleşik tertibinde wagt geçiriň.',
      'stickTeamTitle': 'Toparyňyz bilen bilelikde boluň',
      'stickTeamDesc': 'Elmydama toparýoldaşlaryňyza ýakyn boluň. Toparlaýyn iş sizi has güýçli edýär!',
      'watchCircleTitle': 'Tegelege gözegçilik ediň',
      'watchCircleDesc': 'Elmydama kartany barlaň we howpsuz zona ir geçiň. Iň soňky minuda garaşmaň!',
      'listenTitle': 'Ünsli diňläň',
      'listenDesc': 'Ses möhümdir! Ýakynlaşýan aýak sesleri we ulaglary eşitmek üçin nauşnik ulanyň.',

      // Teamwork Guide
      'teamworkTitle': 'Toparlaşyk gollanmasy',
      'teamworkShort': 'Ajaýyp toparýoldaş bolmak',
      'teamworkFull': 'PUBG bilelikde işleseňiz has lezzetlidir! Peýdaly we dostlukly toparýoldaş bolmagy öwreniň.',
      'shareItemsTitle': 'Zatlary paýlaşyň',
      'shareItemsDesc': 'Eger toparýoldaşyňyz ok-däri, sagaldyş toplumy ýa-da ýarag gerek bolsa, bar zatlaryňyzy paýlaşyň. Paýlaşmak ideg edýär!',
      'communicateTitle': 'Aýdyň aragatnaşyk ediň',
      'communicateDesc': 'Duşmanlar, zatlar ýa-da meýilnamalaryňyz barada topara habar bermek üçin çalt habarlary ýa-da ses söhbetini ulanyň.',
      'reviveTitle': 'Toparýoldaşlary dikeltmek',
      'reviveDesc': 'Eger toparýoldaş ýykylsa, olara çalt kömek ediň! Doly topar has güýçlidir.',
      'markMapTitle': 'Kartany belläň',
      'markMapDesc': 'Toparyňyza nirä gitmekçidigiňizi ýa-da duşmany nireden görendigi görkezmek üçin karta belliklerini ulanyň.',
      'bePositiveTitle': 'Oňyn boluň',
      'bePositiveDesc': 'Toparýoldaşlaryňyzy höweslendiriň! Hemmäni şatlykly saklamak üçin "gowy iş" we "gowy synanyşyk" diýiň.',

      // Survival Skills
      'survivalTitle': 'Diri galmak başarnyklary',
      'survivalShort': 'Duşuşyklarda has uzak diri galyň',
      'survivalFull': 'Duşuşyklarda has uzak galasymyňyz gelýärmi? Bu diri galmak maslahatlary howpdan gaçmaga we has akylly oýnamaga kömek eder!',
      'useCoverTitle': 'Ýapmagy akylly ulanyň',
      'useCoverDesc': 'Elmydama agaçlaryň, daşlaryň ýa-da binalaryň aňyrsynda gizleniň. Hiç haçan açyk meýdanlarda durmaň!',
      'moveCarefulTitle': 'Seresaplylyk bilen hereket ediň',
      'moveCarefulDesc': 'Göni çyzykda ylgamaň. Hereket edenimizde zikzak ediň we depeleri ýa-da binalary ýapma hökmünde ulanyň.',
      'checkSurroundTitle': 'Töweregiňizi barlaň',
      'checkSurroundDesc': 'Talamakdan ýa-da lagerde durmanka, duşmanlary gözläň. Ünsli boluň!',
      'manageBackpackTitle': 'Sumkanyňyzy dolandyryň',
      'manageBackpackDesc': 'Diňe zerur zatlary göterň. Möhüm zatlar üçin ýer açmak üçin artykmaç zatlary taşlaň.',
      'healSafeTitle': 'Howpsuz wagtlarda bejeriliň',
      'healSafeDesc': 'Sagaldyş zatlaryny ulanmazdan ozal ýapma tapyň. Duşmanlaryň görýän ýerinde bejerilmeň!',

      // Healthy Gaming
      'healthyTitle': 'Sagdyn oýun',
      'healthyShort': 'Oýun oýnanyňyzda özüňize ideg ediň',
      'healthyFull': 'Oýun lezzetlidir, ýöne saglygyňyz ilkinji orunda durýar! Oýnanyňyzda sagdyn bolmak üçin şu maslahatlary berjaý ediň.',
      'goodPostureTitle': 'Dogry oturyş',
      'goodPostureDesc': 'Göni oturyň we enjamyňyzy göz derejesinde saklaň. Bu boýnuňyzy we arkañyzy goraýar!',
      'eyeCareTitle': 'Göz idegi',
      'eyeCareDesc': 'Her 20 minutdan ekrandan daşaryk seredň we ýygy-ýygydan göz açyň. Bu gözleriňizi sagdyn saklaýar!',
      'stayActiveTitle': 'Işjeň boluň',
      'stayActiveDesc': 'Daşarda oýnaň, sport bilen meşgullanyň ýa-da her gün maşk ediň. Diňe oturyp, günüň dowamynda oýun oýnamaň!',
      'eatDrinkTitle': 'Iýiň we içiň',
      'eatDrinkDesc': 'Suw içiň we sagdyn nahar iýiň. Oýun sebäpli nahar wagtyny geçirmeň!',
      'sleepWellTitle': 'Gowy uklaň',
      'sleepWellDesc': 'Ýatmazdan 1 sagat öň oýnamakdan bes ediň. Güýçli bolmak üçin 8-10 sagat uklamaly!',

      // Game Controls
      'controlsTitle': 'Oýun dolandyryşlary',
      'controlsShort': 'Esasy dolandyryşlary öwrenmek',
      'controlsFull': 'Dolandyryşlary düşünmek oýny has aňsat we lezzetli edýär. Her knopkanyň nämäni edýändigini öwreniň!',
      'moveJoystickTitle': 'Hereket joýstigi',
      'moveJoystickDesc': 'Çep joýstik siziň keşbiňizi hereket etdirýär. Dürli ugurda tekiz hereket etmegi öwreniň.',
      'lookAroundTitle': 'Daş-töwerege seredmek',
      'lookAroundDesc': 'Daş-töwerege seretmek üçin ekrany süpüriň. Keşbiňizi hereket etdirmän duşmanlary görüp bilersiňiz!',
      'shootButtonTitle': 'Atyş knopkalary',
      'shootButtonDesc': 'Ot knopkasy ýaragyňyzy atýar. Awtomatiki ýaraglar üçin saklaň, ýekeje ok üçin basyň.',
      'jumpCrouchTitle': 'Bökmek we çökmek',
      'jumpCrouchDesc': 'Päsgelçilikleriň üstünden böküň we kiçi ýapmalaryň aňyrsynda gizlenmek üçin çöküň. Ikisini-de öwreniň!',
      'interactTitle': 'Täsirleşme knopkasy',
      'interactDesc': 'Bu knopka gapylary açýar, zatlary alýar we ulaglara girýär. Gaty möhüm!',

      // Map Knowledge
      'mapTitle': 'Karta bilimi',
      'mapShort': 'Dürli ýerler hakda öwreniň',
      'mapFull': 'Kartany bilmek nirä gonmalydygyňyzy, nirede gizlenmelidigini we gowy zatlary nirede tapmalydygyňyzy saýlamaga kömek edýär!',
      'hotZonesTitle': 'Gyzgyn zolaklary',
      'hotZonesDesc': 'Uly şäherlerde ajaýyp talapkeşlik bar, ýöne köp oýunçy bar. Diňe ynanyňyz bar bolsa şol ýere gidiň!',
      'quietAreasTitle': 'Asuda ýerler',
      'quietAreasDesc': 'Kiçi şäherler we jaýlar täze başlanlar üçin has howpsuz. Az talapkeşlik, ýöne az duşman.',
      'highGroundTitle': 'Belent ýerler',
      'highGroundDesc': 'Depeler we beýik binalar has gowy görnüş berýär. Duşmanlary ýokary ýerden görüp bilersiňiz!',
      'safeRoutesTitle': 'Howpsuz ýollar',
      'safeRoutesDesc': 'Ýapma üçin agaçlar we daşlar bolan ýollary öwreniň. Hereket edeniňizde açyk ýollardan gaça duruň.',
      'zoneAwarenessTitle': 'Zona habardarly',
      'zoneAwarenessDesc': 'Gök zona size zyýan berýär! Howpsuz zonanyň kartada nirede bolandygyny elmydama biliň.',

      // Good Sportsmanship
      'sportsmanshipTitle': 'Gowy sport ruhy',
      'sportsmanshipShort': 'Mylakatly we adalatly oýunçy boluň',
      'sportsmanshipFull': 'Gowy sportçy bolmak oýny hemmeler üçin lezzetli edýär! Mertebe bilen ýeňmegi we abraý bilen ýeňilmegi öwreniň.',
      'respectTitle': 'Hemmä hormat goýuň',
      'respectDesc': 'Beýleki oýunçylara özüňize edilmegini isleýän ýaly çemeleşiň. Mylakatly we dostlukly boluň!',
      'noBadWordsTitle': 'Erbet sözler ýok',
      'noBadWordsDesc': 'Hiç haçan erbet sözleri ýa-da kemsidişleri ulanmaň. Söhbetdeşligi ähli ýaşlar üçin dostlukly saklaň.',
      'acceptDefeatTitle': 'Ýeňlişi kabul ediň',
      'acceptDefeatDesc': 'Her duşuşykda ýeňiş gazanmarsyňyz, bu kadaly zat! Ýalňyşlyklardan öwreniň we täzeden synanyşyň.',
      'celebrateFairTitle': 'Adalatly baýramçylyk ediň',
      'celebrateFairDesc': 'Iýeneňizde, sada boluň. Öwünmeň ýa-da beýlekileri erbet duýmaň.',
      'helpNewTitle': 'Täze oýunçylara kömek ediň',
      'helpNewDesc': 'Eger täze biri bilen oýnaýan bolsaňyz, oňa öwrenmäge kömek ediň! Hemme başlangyçdy!',
    },
    'ru': {
      'headerTitle': 'Учись и развивайся',
      'headerDescription': 'Полезные советы и руководства для юных игроков PUBG. Нажмите на любую карточку, чтобы узнать больше!',
      'tapToLearn': 'Нажми, чтобы узнать',
      'bottomReminder': 'Помни: Всегда играй безопасно и получай удовольствие!',

      // Safety Tips
      'safetyTitle': 'Советы по безопасности',
      'safetyShort': 'Учись играть безопасно и ответственно',
      'safetyFull': 'Игра должна быть весёлой и безопасной! Вот важные правила безопасности при игре в PUBG Mobile.',
      'playTimeTitle': 'Ограничение игрового времени',
      'playTimeDesc': 'Делай перерывы каждые 30-45 минут. Твоим глазам и телу нужен отдых!',
      'talkParentsTitle': 'Говори с родителями',
      'talkParentsDesc': 'Всегда сообщай родителям, во что ты играешь и с кем играешь.',
      'onlineFriendsTitle': 'Онлайн друзья',
      'onlineFriendsDesc': 'Никогда не делись личной информацией, такой как адрес, номер телефона или название школы с онлайн-игроками.',
      'reportBadTitle': 'Сообщай о плохом поведении',
      'reportBadDesc': 'Если кто-то ведет себя плохо или тебе некомфортно, скажи взрослому и используй кнопку жалобы.',
      'voiceChatTitle': 'Безопасность голосового чата',
      'voiceChatDesc': 'Используй голосовой чат только с людьми, которых знаешь в реальной жизни. Ты можешь отключить звук других игроков.',

      // Beginner Tips
      'beginnerTitle': 'Советы для начинающих',
      'beginnerShort': 'Важные советы для новых игроков',
      'beginnerFull': 'Начинаешь своё путешествие в PUBG? Эти советы помогут тебе стать лучшим игроком и получать больше удовольствия!',
      'landSafeTitle': 'Приземляйся в безопасных местах',
      'landSafeDesc': 'В начале приземляйся в более спокойных местах вдали от пути самолёта для безопасной практики.',
      'learnControlsTitle': 'Изучай управление',
      'learnControlsDesc': 'Проводи время в тренировочном режиме, чтобы практиковать движение, стрельбу и использование предметов без давления.',
      'stickTeamTitle': 'Держись со своей командой',
      'stickTeamDesc': 'Всегда оставайся рядом с товарищами по команде. Командная работа делает тебя сильнее!',
      'watchCircleTitle': 'Следи за кругом',
      'watchCircleDesc': 'Всегда проверяй карту и переходи в безопасную зону заранее. Не жди до последней минуты!',
      'listenTitle': 'Слушай внимательно',
      'listenDesc': 'Звук важен! Используй наушники, чтобы слышать шаги и приближающиеся машины.',

      // Teamwork Guide
      'teamworkTitle': 'Руководство по командной работе',
      'teamworkShort': 'Как быть отличным товарищем',
      'teamworkFull': 'PUBG веселее, когда вы работаете вместе! Учись быть полезным и дружелюбным товарищем по команде.',
      'shareItemsTitle': 'Делись предметами',
      'shareItemsDesc': 'Если твоему товарищу нужны патроны, аптечки или броня, поделись тем, что у тебя есть. Делиться - значит заботиться!',
      'communicateTitle': 'Чётко общайся',
      'communicateDesc': 'Используй быстрые сообщения или голосовой чат, чтобы сообщить команде о врагах, предметах или твоих планах.',
      'reviveTitle': 'Оживляй товарищей',
      'reviveDesc': 'Если товарищ сбит, быстро помоги ему! Полная команда намного сильнее.',
      'markMapTitle': 'Отмечай на карте',
      'markMapDesc': 'Используй метки на карте, чтобы показать команде, куда хочешь пойти или где видел врагов.',
      'bePositiveTitle': 'Будь позитивным',
      'bePositiveDesc': 'Подбадривай товарищей! Говори "хорошая работа" и "хорошая попытка", чтобы все были счастливы.',

      // Survival Skills
      'survivalTitle': 'Навыки выживания',
      'survivalShort': 'Оставайся в живых дольше',
      'survivalFull': 'Хочешь дольше продержаться в матчах? Эти советы по выживанию помогут избегать опасностей и играть умнее!',
      'useCoverTitle': 'Мудро используй укрытие',
      'useCoverDesc': 'Всегда прячься за деревьями, камнями или зданиями. Никогда не стой на открытых полях!',
      'moveCarefulTitle': 'Двигайся осторожно',
      'moveCarefulDesc': 'Не беги по прямым линиям. Двигайся зигзагом и используй холмы или здания как укрытие.',
      'checkSurroundTitle': 'Проверяй окружение',
      'checkSurroundDesc': 'Перед тем как собирать добычу или разбивать лагерь, осмотрись на врагов. Будь начеку!',
      'manageBackpackTitle': 'Управляй рюкзаком',
      'manageBackpackDesc': 'Носи только то, что нужно. Выбрасывай лишние вещи, чтобы освободить место для важного.',
      'healSafeTitle': 'Лечись в безопасное время',
      'healSafeDesc': 'Найди укрытие перед использованием лечебных предметов. Не лечись на открытом месте, где враги могут тебя видеть!',

      // Healthy Gaming
      'healthyTitle': 'Здоровый гейминг',
      'healthyShort': 'Заботься о себе во время игры',
      'healthyFull': 'Игра - это весело, но твоё здоровье на первом месте! Следуй этим советам, чтобы оставаться здоровым во время игры.',
      'goodPostureTitle': 'Правильная осанка',
      'goodPostureDesc': 'Сиди прямо и держи устройство на уровне глаз. Это защищает твою шею и спину!',
      'eyeCareTitle': 'Забота о глазах',
      'eyeCareDesc': 'Каждые 20 минут отводи взгляд от экрана и часто моргай. Это сохраняет твои глаза здоровыми!',
      'stayActiveTitle': 'Будь активным',
      'stayActiveDesc': 'Играй на улице, занимайся спортом или упражняйся каждый день. Не сиди весь день и не играй только в игры!',
      'eatDrinkTitle': 'Ешь и пей',
      'eatDrinkDesc': 'Пей воду и ешь здоровую пищу. Не пропускай приёмы пищи из-за игр!',
      'sleepWellTitle': 'Хорошо спи',
      'sleepWellDesc': 'Прекращай играть за 1 час до сна. Тебе нужно 8-10 часов сна, чтобы стать сильным!',

      // Game Controls
      'controlsTitle': 'Управление игрой',
      'controlsShort': 'Освой базовое управление',
      'controlsFull': 'Понимание управления делает игру проще и веселее. Узнай, что делает каждая кнопка!',
      'moveJoystickTitle': 'Джойстик движения',
      'moveJoystickDesc': 'Левый джойстик двигает твоего персонажа. Практикуй плавное движение в разных направлениях.',
      'lookAroundTitle': 'Осмотр',
      'lookAroundDesc': 'Проводи по экрану, чтобы осмотреться. Ты можешь видеть врагов, не двигая персонажа!',
      'shootButtonTitle': 'Кнопки стрельбы',
      'shootButtonDesc': 'Кнопка огня стреляет из оружия. Удерживай для автоматического оружия, нажимай для одиночных выстрелов.',
      'jumpCrouchTitle': 'Прыжок и присед',
      'jumpCrouchDesc': 'Прыгай через препятствия и приседай, чтобы спрятаться за маленьким укрытием. Практикуй оба движения!',
      'interactTitle': 'Кнопка взаимодействия',
      'interactDesc': 'Эта кнопка открывает двери, поднимает предметы и садится в транспорт. Очень важно!',

      // Map Knowledge
      'mapTitle': 'Знание карты',
      'mapShort': 'Узнай о разных локациях',
      'mapFull': 'Знание карты помогает выбрать, где приземлиться, где спрятаться и где найти хорошие предметы!',
      'hotZonesTitle': 'Горячие зоны',
      'hotZonesDesc': 'В больших городах отличная добыча, но много игроков. Иди туда, только если уверен!',
      'quietAreasTitle': 'Спокойные места',
      'quietAreasDesc': 'Маленькие городки и дома безопаснее для новичков. Меньше добычи, но меньше врагов.',
      'highGroundTitle': 'Высокая позиция',
      'highGroundDesc': 'Холмы и высокие здания дают лучший обзор. Ты можешь заметить врагов сверху!',
      'safeRoutesTitle': 'Безопасные маршруты',
      'safeRoutesDesc': 'Изучай пути с деревьями и камнями для укрытия. Избегай открытых дорог при движении.',
      'zoneAwarenessTitle': 'Осведомлённость о зоне',
      'zoneAwarenessDesc': 'Синяя зона причиняет вред! Всегда знай, где находится безопасная зона на карте.',

      // Good Sportsmanship
      'sportsmanshipTitle': 'Хорошее спортивное поведение',
      'sportsmanshipShort': 'Будь добрым и честным игроком',
      'sportsmanshipFull': 'Быть хорошим спортсменом делает игру весёлой для всех! Учись побеждать с достоинством и проигрывать с честью.',
      'respectTitle': 'Уважай всех',
      'respectDesc': 'Относись к другим игрокам так, как хочешь, чтобы относились к тебе. Будь добрым и дружелюбным!',
      'noBadWordsTitle': 'Никаких плохих слов',
      'noBadWordsDesc': 'Никогда не используй плохие слова или оскорбления. Держи чат дружелюбным и весёлым для всех возрастов.',
      'acceptDefeatTitle': 'Принимай поражение',
      'acceptDefeatDesc': 'Ты не выиграешь каждый матч, и это нормально! Учись на ошибках и пробуй снова.',
      'celebrateFairTitle': 'Празднуй справедливо',
      'celebrateFairDesc': 'Когда побеждаешь, будь скромным. Не хвастайся и не заставляй других чувствовать себя плохо.',
      'helpNewTitle': 'Помогай новым игрокам',
      'helpNewDesc': 'Если играешь с новичком, помоги ему учиться! Все когда-то были новичками.',
    },
  };

  // Translation helper function
  String t(String key) {
    final locale = Get.locale?.languageCode ?? 'tr';
    return translations[locale]?[key] ?? translations['tr']?[key] ?? key;
  }

  // Information categories with translation keys
  List<Map<String, dynamic>> getInformationCategories() => [
        {
          'titleKey': 'safetyTitle',
          'icon': Icons.security,
          'color': Colors.blue,
          'image': 'assets/images/safety_info.png',
          'shortKey': 'safetyShort',
          'fullKey': 'safetyFull',
          'tips': [
            {
              'titleKey': 'playTimeTitle',
              'descKey': 'playTimeDesc',
              'icon': Icons.schedule,
            },
            {
              'titleKey': 'talkParentsTitle',
              'descKey': 'talkParentsDesc',
              'icon': Icons.family_restroom,
            },
            {
              'titleKey': 'onlineFriendsTitle',
              'descKey': 'onlineFriendsDesc',
              'icon': Icons.privacy_tip,
            },
            {
              'titleKey': 'reportBadTitle',
              'descKey': 'reportBadDesc',
              'icon': Icons.report,
            },
            {
              'titleKey': 'voiceChatTitle',
              'descKey': 'voiceChatDesc',
              'icon': Icons.mic_off,
            },
          ],
        },
        {
          'titleKey': 'beginnerTitle',
          'icon': Icons.lightbulb,
          'color': Colors.orange,
          'image': 'assets/images/beginner_tips.png',
          'shortKey': 'beginnerShort',
          'fullKey': 'beginnerFull',
          'tips': [
            {
              'titleKey': 'landSafeTitle',
              'descKey': 'landSafeDesc',
              'icon': Icons.location_on,
            },
            {
              'titleKey': 'learnControlsTitle',
              'descKey': 'learnControlsDesc',
              'icon': Icons.gamepad,
            },
            {
              'titleKey': 'stickTeamTitle',
              'descKey': 'stickTeamDesc',
              'icon': Icons.groups,
            },
            {
              'titleKey': 'watchCircleTitle',
              'descKey': 'watchCircleDesc',
              'icon': Icons.circle,
            },
            {
              'titleKey': 'listenTitle',
              'descKey': 'listenDesc',
              'icon': Icons.headphones,
            },
          ],
        },
        {
          'titleKey': 'teamworkTitle',
          'icon': Icons.people,
          'color': Colors.green,
          'image': 'assets/images/teamwork_guide.png',
          'shortKey': 'teamworkShort',
          'fullKey': 'teamworkFull',
          'tips': [
            {
              'titleKey': 'shareItemsTitle',
              'descKey': 'shareItemsDesc',
              'icon': Icons.volunteer_activism,
            },
            {
              'titleKey': 'communicateTitle',
              'descKey': 'communicateDesc',
              'icon': Icons.chat_bubble,
            },
            {
              'titleKey': 'reviveTitle',
              'descKey': 'reviveDesc',
              'icon': Icons.medical_services,
            },
            {
              'titleKey': 'markMapTitle',
              'descKey': 'markMapDesc',
              'icon': Icons.push_pin,
            },
            {
              'titleKey': 'bePositiveTitle',
              'descKey': 'bePositiveDesc',
              'icon': Icons.thumb_up,
            },
          ],
        },
        {
          'titleKey': 'survivalTitle',
          'icon': Icons.shield,
          'color': Colors.purple,
          'image': 'assets/images/survival_skills.png',
          'shortKey': 'survivalShort',
          'fullKey': 'survivalFull',
          'tips': [
            {
              'titleKey': 'useCoverTitle',
              'descKey': 'useCoverDesc',
              'icon': Icons.nature,
            },
            {
              'titleKey': 'moveCarefulTitle',
              'descKey': 'moveCarefulDesc',
              'icon': Icons.directions_run,
            },
            {
              'titleKey': 'checkSurroundTitle',
              'descKey': 'checkSurroundDesc',
              'icon': Icons.visibility,
            },
            {
              'titleKey': 'manageBackpackTitle',
              'descKey': 'manageBackpackDesc',
              'icon': Icons.backpack,
            },
            {
              'titleKey': 'healSafeTitle',
              'descKey': 'healSafeDesc',
              'icon': Icons.healing,
            },
          ],
        },
        {
          'titleKey': 'healthyTitle',
          'icon': Icons.favorite,
          'color': Colors.red,
          'image': 'assets/images/healthy_gaming.png',
          'shortKey': 'healthyShort',
          'fullKey': 'healthyFull',
          'tips': [
            {
              'titleKey': 'goodPostureTitle',
              'descKey': 'goodPostureDesc',
              'icon': Icons.airline_seat_recline_normal,
            },
            {
              'titleKey': 'eyeCareTitle',
              'descKey': 'eyeCareDesc',
              'icon': Icons.remove_red_eye,
            },
            {
              'titleKey': 'stayActiveTitle',
              'descKey': 'stayActiveDesc',
              'icon': Icons.directions_bike,
            },
            {
              'titleKey': 'eatDrinkTitle',
              'descKey': 'eatDrinkDesc',
              'icon': Icons.restaurant,
            },
            {
              'titleKey': 'sleepWellTitle',
              'descKey': 'sleepWellDesc',
              'icon': Icons.bedtime,
            },
          ],
        },
        {
          'titleKey': 'controlsTitle',
          'icon': Icons.sports_esports,
          'color': Colors.teal,
          'image': 'assets/images/controls_guide.png',
          'shortKey': 'controlsShort',
          'fullKey': 'controlsFull',
          'tips': [
            {
              'titleKey': 'moveJoystickTitle',
              'descKey': 'moveJoystickDesc',
              'icon': Icons.control_camera,
            },
            {
              'titleKey': 'lookAroundTitle',
              'descKey': 'lookAroundDesc',
              'icon': Icons.rotate_90_degrees_ccw,
            },
            {
              'titleKey': 'shootButtonTitle',
              'descKey': 'shootButtonDesc',
              'icon': Icons.radio_button_checked,
            },
            {
              'titleKey': 'jumpCrouchTitle',
              'descKey': 'jumpCrouchDesc',
              'icon': Icons.height,
            },
            {
              'titleKey': 'interactTitle',
              'descKey': 'interactDesc',
              'icon': Icons.touch_app,
            },
          ],
        },
        {
          'titleKey': 'mapTitle',
          'icon': Icons.map,
          'color': Colors.brown,
          'image': 'assets/images/map_knowledge.png',
          'shortKey': 'mapShort',
          'fullKey': 'mapFull',
          'tips': [
            {
              'titleKey': 'hotZonesTitle',
              'descKey': 'hotZonesDesc',
              'icon': Icons.local_fire_department,
            },
            {
              'titleKey': 'quietAreasTitle',
              'descKey': 'quietAreasDesc',
              'icon': Icons.home,
            },
            {
              'titleKey': 'highGroundTitle',
              'descKey': 'highGroundDesc',
              'icon': Icons.landscape,
            },
            {
              'titleKey': 'safeRoutesTitle',
              'descKey': 'safeRoutesDesc',
              'icon': Icons.route,
            },
            {
              'titleKey': 'zoneAwarenessTitle',
              'descKey': 'zoneAwarenessDesc',
              'icon': Icons.circle_outlined,
            },
          ],
        },
        {
          'titleKey': 'sportsmanshipTitle',
          'icon': Icons.emoji_events,
          'color': Colors.amber,
          'image': 'assets/images/sportsmanship.png',
          'shortKey': 'sportsmanshipShort',
          'fullKey': 'sportsmanshipFull',
          'tips': [
            {
              'titleKey': 'respectTitle',
              'descKey': 'respectDesc',
              'icon': Icons.handshake,
            },
            {
              'titleKey': 'noBadWordsTitle',
              'descKey': 'noBadWordsDesc',
              'icon': Icons.speaker_notes_off,
            },
            {
              'titleKey': 'acceptDefeatTitle',
              'descKey': 'acceptDefeatDesc',
              'icon': Icons.sports_kabaddi,
            },
            {
              'titleKey': 'celebrateFairTitle',
              'descKey': 'celebrateFairDesc',
              'icon': Icons.celebration,
            },
            {
              'titleKey': 'helpNewTitle',
              'descKey': 'helpNewDesc',
              'icon': Icons.support_agent,
            },
          ],
        },
      ];

  void _showFullInformation(Map<String, dynamic> category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: kPrimaryColorBlack,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Icon and Title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: category['color'].withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            category['icon'],
                            color: category['color'],
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            t(category['titleKey']),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Category Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        category['image'],
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: category['color'].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            category['icon'],
                            size: 60,
                            color: category['color'].withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Full Description
                    Text(
                      t(category['fullKey']),
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tips List
                    ...List.generate(
                      (category['tips'] as List).length,
                      (index) {
                        final tip = category['tips'][index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: category['color'].withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: category['color'].withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  tip['icon'],
                                  color: category['color'],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      t(tip['titleKey']),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      t(tip['descKey']),
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: const MyAppBar(
          fontSize: 22.0,
          backArrow: false,
          icon: SizedBox(),
          iconRemove: false,
          name: 'Lobbi',
          elevationWhite: true,
        ),
        backgroundColor: kPrimaryColorBlack,
        body: Column(
          children: [
            // Header Info
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[900]!, Colors.purple[900]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t('headerTitle'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t('headerDescription'),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Information Cards Grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: getInformationCategories().length,
                itemBuilder: (context, index) {
                  final category = getInformationCategories()[index];
                  return InkWell(
                    onTap: () => _showFullInformation(category),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: category['color'].withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: category['color'].withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              category['icon'],
                              color: category['color'],
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Title
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              t(category['titleKey']),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Short Description
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              t(category['shortKey']),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Tap to learn badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: category['color'].withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t('tapToLearn'),
                                  style: TextStyle(
                                    color: category['color'],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_forward,
                                  color: category['color'],
                                  size: 12,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Safety Reminder
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.green[200]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t('bottomReminder'),
                      style: TextStyle(
                        color: Colors.green[100],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
