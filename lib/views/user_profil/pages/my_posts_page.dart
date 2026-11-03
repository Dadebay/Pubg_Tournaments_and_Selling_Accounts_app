import 'package:game_app/models/get_posts_model.dart';
import 'package:game_app/repository/ucdayy_api.dart';
import 'package:game_app/views/cards/show_all_accounts_card.dart';
import 'package:game_app/views/constants/index.dart';

/// The logged in user's own posts, from `/accounts/get-my-posts/`.
class MyPostsPage extends StatelessWidget {
  const MyPostsPage({super.key});

  Future<List<GetPostsAccountModel>> _load() async {
    final result = await UcdayyApi.getMyPosts();
    if (!result.ok) {
      throw Exception(result.error ?? 'status ${result.statusCode}');
    }
    return apiItems(result.data).map(GetPostsAccountModel.fromJson).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryColorBlack,
      appBar: const MyAppBar(backArrow: true, iconRemove: true, fontSize: 0.0, name: 'myPosts', elevationWhite: true),
      body: FutureBuilder<List<GetPostsAccountModel>>(
        future: _load(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: spinKit());
          } else if (snapshot.hasError) {
            return errorData(onTap: () {});
          } else if (snapshot.data!.isEmpty) {
            return emptyData();
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 3 / 4),
            itemBuilder: (context, index) => ShowAllProductsCard(fav: false, model: snapshot.data![index]),
          );
        },
      ),
    );
  }
}
