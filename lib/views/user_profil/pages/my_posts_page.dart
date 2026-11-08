import 'package:game_app/models/get_posts_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/cards/show_all_accounts_card.dart';
import 'package:game_app/views/constants/index.dart';
import 'package:hugeicons/hugeicons.dart';

/// The logged in user's own posts, from `/accounts/get-my-posts/`. Each post has a
/// delete button (`POST /accounts/delete-post/{id}/`).
class MyPostsPage extends StatefulWidget {
  const MyPostsPage({super.key});

  @override
  State<MyPostsPage> createState() => _MyPostsPageState();
}

class _MyPostsPageState extends State<MyPostsPage> {
  late Future<List<GetPostsAccountModel>> _future = _load();
  final Set<int> _deleted = {};

  Future<List<GetPostsAccountModel>> _load() async {
    final result = await UcdayyApi.getMyPosts();
    if (!result.ok) {
      throw Exception(result.error ?? 'status ${result.statusCode}');
    }
    return apiItems(result.data).map(GetPostsAccountModel.fromJson).toList();
  }

  Future<void> _confirmDelete(GetPostsAccountModel post) async {
    final yes = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.4)),
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF2A1A1A), Color(0xFF131315)]),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: Color(0xFFFF6B6B), size: 40, strokeWidth: 1.8),
              const SizedBox(height: 14),
              Text(
                'deletePostConfirm'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 19, height: 1.25),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => Navigator.pop(context, true),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), color: const Color(0xFFFF6B6B)),
                  child: Text(
                    'delete'.tr,
                    style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 17),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'cancel'.tr,
                  style: const TextStyle(color: Colors.white54, fontFamily: gilroySemiBold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (yes != true || post.id == null) {
      return;
    }
    final result = await UcdayyApi.deleteAccountPost(post.id!);
    if (!mounted) {
      return;
    }
    if (result.ok) {
      setState(() => _deleted.add(post.id!));
    } else {
      // 404: the post is gone or is not the caller's.
      showSnackBar('noConnection3', result.statusCode == 404 ? 'catalogGone' : 'tournamentInfo14', Colors.red);
      if (result.statusCode == 404) {
        setState(() => _future = _load());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(backArrow: true, iconRemove: true, fontSize: 0.0, name: 'myPosts', elevationWhite: true),
      body: FutureBuilder<List<GetPostsAccountModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinKit());
          } else if (snapshot.hasError) {
            return errorData(onTap: () => setState(() => _future = _load()));
          }
          final posts = [
            for (final post in snapshot.data ?? const <GetPostsAccountModel>[])
              if (!_deleted.contains(post.id)) post,
          ];
          if (posts.isEmpty) {
            return emptyData();
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            physics: const BouncingScrollPhysics(),
            itemCount: posts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 3 / 4),
            itemBuilder: (context, index) => Stack(
              children: [
                Positioned.fill(child: ShowAllProductsCard(fav: false, model: posts[index])),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _confirmDelete(posts[index]),
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.65),
                        border: Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.7)),
                      ),
                      child: const HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: Color(0xFFFF6B6B), size: 19, strokeWidth: 1.8),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
