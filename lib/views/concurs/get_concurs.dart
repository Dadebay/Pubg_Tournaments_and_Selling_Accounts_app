import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/provider/getkonkur.dart';
import 'package:game_app/views/concurs/concurs_by_id.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timer_count_down/timer_count_down.dart';

class GetConcursScreen extends StatefulWidget {
  const GetConcursScreen({super.key});

  @override
  State<GetConcursScreen> createState() => _GetConcursScreenState();
}

class _GetConcursScreenState extends State<GetConcursScreen> {
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  dynamic fetchData() async {
    await Provider.of<getConcursProvider>(context, listen: false).getConcursCart(context);
  }

  String getFormattedDate(String date) {
    final localDate = DateTime.parse(date).toLocal();
    final inputFormat = DateFormat('yyyy-MM-dd HH:mm');
    final inputDate = inputFormat.parse(localDate.toString());
    final outputFormat = DateFormat('dd/MM/yyyy HH:mm');
    final outputDate = outputFormat.format(inputDate);

    return outputDate.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBarNew(
        backArrow: true,
        iconRemove: true,
        elevationWhite: true,
        name: 'Konkurs',
        fontSize: 0.0,
      ),
      body: Consumer<getConcursProvider>(
        builder: (_, concurs, __) {
          if (concurs.isLoading == true) {
            return Center(child: spinKit());
          } else {
            return ListView.builder(
              itemCount: concurs.concursCart.length,
              itemBuilder: (BuildContext context, int index) {
                return ConcursCard(
                  title: concurs.concursCart[index].nameTm,
                  startDate: 'startDate'.tr + getFormattedDate(concurs.concursCart[index].createdDate.toString()),
                  imageUrl: concurs.concursCart[index].image,
                  endDate: concurs.concursCart[index].finishedDate,
                  id: concurs.concursCart[index].id.toString(),
                  price: concurs.concursCart[index].price.toString(),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ConcursCard extends StatefulWidget {
  final String id;
  final String title;
  final String startDate;
  final String imageUrl;
  final String price;
  final DateTime endDate;

  const ConcursCard({required this.title, required this.startDate, required this.imageUrl, required this.endDate, required this.id, required this.price, super.key});
  @override
  State<ConcursCard> createState() => _ConcursCardState();
}

class _ConcursCardState extends State<ConcursCard> {
  @override
  Widget build(BuildContext context) {
    final Duration duration = widget.endDate.difference(DateTime.now());
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ConcursByID(
                id: widget.id,
                name: widget.title,
                price: widget.price,
              ),
            ),
          );
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: kPrimaryColor,
            border: Border.all(color: kPrimaryColor),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(15), topLeft: Radius.circular(15)),
                  child: CachedNetworkImage(
                    imageUrl: '$serverURL${widget.imageUrl}',
                    fit: BoxFit.cover,
                    height: Get.size.height,
                    progressIndicatorBuilder: (context, url, downloadProgress) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: kPrimaryColorBlack, borderRadius: BorderRadius.only(bottomRight: Radius.circular(25))),
                      child: Text(
                        widget.startDate,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: josefinSansSemiBold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        widget.title,
                        style: const TextStyle(color: Colors.black, fontSize: 18, fontFamily: josefinSansBold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: kPrimaryColorBlack, borderRadius: BorderRadius.only(topRight: Radius.circular(25))),
                      child: Countdown(
                        seconds: duration.inSeconds,
                        build: (BuildContext ctx, double time) {
                          final int days = (time / (24 * 3600)).floor();
                          final int hours = ((time % (24 * 3600)) / 3600).floor();
                          final int minutes = ((time % 3600) / 60).floor();
                          final int seconds = (time % 60).floor();
                          final String textt = Get.locale!.languageCode == 'tr' ? '$days gün $hours sag $minutes min $seconds s' : '$days день $hours час $minutes мин $seconds s';
                          return Text(
                            'endDate'.tr + textt,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, fontFamily: josefinSansSemiBold, color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
