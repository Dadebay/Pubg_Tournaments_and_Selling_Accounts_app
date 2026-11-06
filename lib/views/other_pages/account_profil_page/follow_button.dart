import 'package:cached_network_image/cached_network_image.dart';
import 'package:game_app/models/user_models/auth_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/constants/index.dart';

/// Follow / unfollow toggle for the owner of a post, with a menu that lists
/// the owner's followers and followings.
class FollowButton extends StatefulWidget {
  const FollowButton({required this.userId, super.key});

  final int userId;

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool _following = false;
  bool _busy = false;

  Future<void> _toggle() async {
    final token = await Auth().getToken();
    if (token == null || token.isEmpty) {
      showSnackBar('loginError', 'loginError1', Colors.red);
      return;
    }
    setState(() => _busy = true);
    final result = await UcdayyApi.toggleFollow(widget.userId);
    if (!mounted) {
      return;
    }
    if (result.ok) {
      final data = result.data;
      final flag = data is Map ? (data['following'] ?? data['followed'] ?? data['is_following']) : null;
      _following = flag is bool ? flag : !_following;
    } else {
      showSnackBar('noConnection3', result.error ?? 'errorEmpty', Colors.red);
    }
    setState(() => _busy = false);
  }

  void _showList({required bool followers}) {
    Get.bottomSheet(
      _UserList(userId: widget.userId, followers: followers),
      backgroundColor: kPrimaryColorBlack,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, right: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: _busy ? null : _toggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: _following ? Colors.white.withValues(alpha: 0.4) : kPrimaryColor, borderRadius: BorderRadius.circular(20)),
              child: Text(
                (_following ? 'unfollow' : 'follow').tr,
                style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold, fontSize: 15),
              ),
            ),
          ),
          PopupMenuButton<bool>(
            color: kPrimaryColorBlack,
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onSelected: (followers) => _showList(followers: followers),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: true,
                child: Text(
                  'followers'.tr,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyRegular),
                ),
              ),
              PopupMenuItem(
                value: false,
                child: Text(
                  'followings'.tr,
                  style: const TextStyle(color: Colors.white, fontFamily: gilroyRegular),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UserList extends StatelessWidget {
  const _UserList({required this.userId, required this.followers});

  final int userId;
  final bool followers;

  String _name(Map item) {
    // Each row is either the user itself or `{ follower: {...} }` / `{ following: {...} }`.
    final inner = item[followers ? 'follower' : 'following'];
    final user = inner is Map ? inner : item;
    final name = '${user['pubg_username'] ?? user['first_name'] ?? user['phone'] ?? ''}';
    return name;
  }

  String? _image(Map item) {
    final inner = item[followers ? 'follower' : 'following'];
    final user = inner is Map ? inner : item;
    final image = user['image'];
    return image is String && image.isNotEmpty ? '$serverURL$image' : null;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.size.height * 0.6,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              (followers ? 'followers' : 'followings').tr,
              style: const TextStyle(color: Colors.white, fontFamily: gilroyBold, fontSize: 20),
            ),
          ),
          Expanded(
            child: FutureBuilder<ApiResult>(
              future: followers ? UcdayyApi.getFollowers(userId) : UcdayyApi.getFollowings(userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: spinKit());
                }
                final items = apiItems(snapshot.data!.data);
                if (!snapshot.data!.ok || items.isEmpty) {
                  return Center(
                    child: Text(
                      'errorEmpty'.tr,
                      style: const TextStyle(color: Colors.white70, fontFamily: gilroySemiBold),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final image = _image(items[index]);
                    return ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.white24, backgroundImage: image == null ? null : CachedNetworkImageProvider(image)),
                      title: Text(
                        _name(items[index]),
                        style: const TextStyle(color: Colors.white, fontFamily: gilroySemiBold),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
