// ignore_for_file: use_key_in_widget_constructors

import 'package:game_app/controllers/settings_controller.dart';
import 'package:game_app/views/constants/index.dart';

class NewNotificationPage extends StatefulWidget {
  @override
  State<NewNotificationPage> createState() => _NewNotificationPageState();
}

class _NewNotificationPageState extends State<NewNotificationPage> {
  final SettingsController controller = Get.put(SettingsController());

  // Mock notifications data for kids
  final List<Map<String, dynamic>> mockNotifications = [
    {
      'id': 1,
      'titleTk': 'Täze oýun tertibi!',
      'titleRu': 'Новый игровой режим!',
      'contentTk': 'Dostlaryň bilen täze topar oýnuny synap gör! Täze ssenariýler we ajaýyp baýraklar sizi garaşýar. Bu mode teamwork skills-iňizi ösdürmäge kömek eder.',
      'contentRu': 'Попробуй новую командную игру с друзьями! Тебя ждут новые сценарии и удивительные награды. Этот режим поможет развить навыки командной работы.',
      'icon': Icons.stars,
      'color': Colors.purple,
      'time': '2 sagat öň / 2 часа назад',
      'isNew': false,
      'category': 'game',
    },
    {
      'id': 2,
      'titleTk': 'Howpsuzlyk ýatlatmasy',
      'titleRu': 'Напоминание о безопасности',
      'contentTk': 'Her 30 minutdan dynç alyş almany ýatdan çykarma! Gözüň we bedenň dynç almalı. Suw iç we arakesme et.',
      'contentRu': 'Не забывай делать перерыв каждые 30 минут! Твоим глазам и телу нужен отдых. Пей воду и делай паузы.',
      'icon': Icons.health_and_safety,
      'color': Colors.green,
      'time': '5 sagat öň / 5 часов назад',
      'isNew': false,
      'category': 'safety',
    },
    {
      'id': 3,
      'titleTk': 'Türgenleşik tertibi güncellendi',
      'titleRu': 'Обновлён тренировочный режим',
      'contentTk': 'Täze türgenleşik meýdany açyldy! Täze ýaraglary synap gör, nişan alyş başarnyklaryny ösdür. Dostlaryňy çagyryp, bile türgenleş!',
      'contentRu': 'Открыт новый тренировочный полигон! Испытай новое оружие, развивай навыки прицеливания. Пригласи друзей и тренируйтесь вместе!',
      'icon': Icons.fitness_center,
      'color': Colors.orange,
      'time': 'Düýn / Вчера',
      'isNew': false,
      'category': 'training',
    },
    {
      'id': 4,
      'titleTk': 'Ene-atalaryň ünsüne!',
      'titleRu': 'Внимание родителей!',
      'contentTk': 'Çagaňyzyň oýun wagtyny gözegçilikde saklamak üçin tertibimizdäki "Ene-atalar gözegçiligi" bölümini ulanyň. Sagdyn oýun üçin çäkleri kesgitläň.',
      'contentRu': 'Используй раздел "Родительский контроль" в настройках для контроля игрового времени ребёнка. Установи лимиты для здорового гейминга.',
      'icon': Icons.family_restroom,
      'color': Colors.blue,
      'time': '2 gün öň / 2 дня назад',
      'isNew': false,
      'category': 'parent',
    },
    {
      'id': 5,
      'titleTk': 'Hepdelik maslahat',
      'titleRu': 'Совет недели',
      'contentTk': 'Toparýoldaşlaryň bilen aragatnaşyk açaryň! Mikrofondan peýdalanyň, meýilnamalary paýlaşyň we bilelikde strategiýa döredň. Toparlaşyk ýeňiş getirýär!',
      'contentRu': 'Общайся с товарищами по команде! Используй микрофон, делись планами и создавайте стратегию вместе. Командная работа приносит победу!',
      'icon': Icons.lightbulb,
      'color': Colors.amber,
      'time': '3 gün öň / 3 дня назад',
      'isNew': false,
      'category': 'tip',
    },
    {
      'id': 6,
      'titleTk': 'Dostlary goşmak aňsat!',
      'titleRu': 'Легко добавлять друзей!',
      'contentTk': 'Täze dostlar tapmak isleýärsiňmi? Toparlaşyk oýunlarynda gowy oýunçylar bilen tanyş! Dostlukly boluň we bilelikde oýnaň.',
      'contentRu': 'Хочешь найти новых друзей? Знакомься с хорошими игроками в командных играх! Будь дружелюбным и играйте вместе.',
      'icon': Icons.people_alt,
      'color': Colors.pink,
      'time': '4 gün öň / 4 дня назад',
      'isNew': false,
      'category': 'social',
    },
    {
      'id': 7,
      'titleTk': 'Ýeňişli oýnaň strategiýa bilen!',
      'titleRu': 'Играй с умом со стратегией!',
      'contentTk': 'Kartany öwreniň, howpsuz ýerlerde goniň we toparyňyz bilen bilelikde hereketleniň. Akylly oýun has köp ýeňiş getirýär!',
      'contentRu': 'Изучай карту, приземляйся в безопасных местах и двигайся вместе с командой. Умная игра приносит больше побед!',
      'icon': Icons.psychology,
      'color': Colors.teal,
      'time': '5 gün öň / 5 дней назад',
      'isNew': false,
      'category': 'strategy',
    },
    {
      'id': 8,
      'titleTk': 'Baýramçylyk başlanýar!',
      'titleRu': 'Начинается праздник!',
      'contentTk': 'Bu hepdäniň ahyrynda ajaýyp baýramçylyk oýunlary! Gatnaşyp, täze keşpleri, emoji we beýleki sowgatlary gazanyň. Lezzet alyň!',
      'contentRu': 'В эти выходные удивительные праздничные игры! Участвуй и получай новые скины, эмодзи и другие награды. Получай удовольствие!',
      'icon': Icons.celebration,
      'color': Colors.red,
      'time': '1 hepde öň / 1 неделю назад',
      'isNew': false,
      'category': 'event',
    },
  ];

  String getTitle(Map<String, dynamic> notification) {
    final locale = Get.locale?.languageCode ?? 'tr';
    return locale == 'ru' ? notification['titleRu'] : notification['titleTk'];
  }

  String getContent(Map<String, dynamic> notification) {
    final locale = Get.locale?.languageCode ?? 'tr';
    return locale == 'ru' ? notification['contentRu'] : notification['contentTk'];
  }

  IconData getCategoryIcon(String category) {
    switch (category) {
      case 'game':
        return Icons.sports_esports;
      case 'safety':
        return Icons.shield;
      case 'training':
        return Icons.military_tech;
      case 'parent':
        return Icons.supervised_user_circle;
      case 'tip':
        return Icons.tips_and_updates;
      case 'social':
        return Icons.groups;
      case 'strategy':
        return Icons.map;
      case 'event':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(
        fontSize: 18.0,
        backArrow: true,
        iconRemove: false,
        name: 'notification',
        elevationWhite: true,
      ),
      body: Column(
        children: [
          // Header with count
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[900]!, Colors.blue[700]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications_active, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bildirişler / Уведомления',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${mockNotifications.where((n) => n['isNew'] == true).length} täze / новых',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${mockNotifications.length}',
                    style: TextStyle(
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Notifications List
          Expanded(
            child: mockNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_off, size: 80, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          'Bildiriş ýok / Нет уведомлений',
                          style: TextStyle(color: Colors.grey[400], fontSize: 16),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: mockNotifications.length,
                    itemBuilder: (BuildContext context, int index) {
                      final notification = mockNotifications[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: notification['isNew'] ? (notification['color'] as Color).withOpacity(0.5) : Colors.grey[800]!,
                            width: 2,
                          ),
                          boxShadow: notification['isNew']
                              ? [
                                  BoxShadow(
                                    color: (notification['color'] as Color).withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            leading: Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: (notification['color'] as Color).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    notification['icon'],
                                    color: notification['color'],
                                    size: 28,
                                  ),
                                ),
                                if (notification['isNew'])
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Text(
                                        'N',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              getTitle(notification),
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: josefinSansSemiBold,
                                fontSize: 16,
                                fontWeight: notification['isNew'] ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    notification['time'],
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: Icon(
                              Icons.keyboard_arrow_down,
                              color: notification['color'],
                            ),
                            collapsedIconColor: notification['color'],
                            iconColor: notification['color'],
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      getContent(notification),
                                      style: const TextStyle(
                                        fontFamily: josefinSansMedium,
                                        fontSize: 15,
                                        color: Colors.white,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(
                                          getCategoryIcon(notification['category']),
                                          size: 16,
                                          color: notification['color'],
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          notification['category'].toUpperCase(),
                                          style: TextStyle(
                                            color: notification['color'],
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                      ],
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
        ],
      ),
    );
  }
}
