// show_all_account_controller.dart
import 'package:game_app/models/get_posts_model.dart'; // Import GetPostsAccountModel
import 'package:get/get.dart'; // Ensure Get is imported for RxList, etc.

// Remove this import if AccountsForSaleModel is not actually used for the list items
// import '../models/accouts_for_sale_model.dart';

class ShowAllAccountsController extends GetxController {
  RxString sortType = ''.obs;
  RxString sortName = ''.obs;
  RxString sortCityType = ''.obs;
  RxString sortCityName = ''.obs;
  RxString sortTypePrice = ''.obs;
  RxString sortNamePrice = ''.obs;
  RxString sortTypePriceMax = ''.obs;
  RxString sortNamePriceMax = ''.obs;

  // Use GetPostsAccountModel if that's what your API returns and card uses
  RxList<GetPostsAccountModel> list = <GetPostsAccountModel>[].obs;
  RxInt pageNumber = 1.obs;
  // RxInt loading = 0.obs; // You can replace this with a more descriptive boolean
  RxBool isLoading = true.obs; // For initial loading state
  RxBool isLoadingMore = false.obs; // For pagination loading state

  Map<String, String> _getCurrentParams() {
    final Map<String, String> params = {
      'page': pageNumber.value.toString(),
      'size': '10',
    };
    if (sortName.value.isNotEmpty && sortType.value.isNotEmpty) {
      params[sortName.value] = sortType.value;
    }
    if (sortCityName.value.isNotEmpty && sortCityType.value.isNotEmpty) {
      params[sortCityName.value] = sortCityType.value;
    }
    if (sortNamePrice.value.isNotEmpty && sortTypePrice.value.isNotEmpty) {
      params[sortNamePrice.value] = sortTypePrice.value;
    }
    if (sortNamePriceMax.value.isNotEmpty && sortTypePriceMax.value.isNotEmpty) {
      params[sortNamePriceMax.value] = sortTypePriceMax.value;
    }
    // Important: Remove entries where key or value might be empty if the API doesn't like it
    // Or ensure default values are robust. For instance, if sortName is empty, don't add it.
    params.removeWhere((key, value) => key.isEmpty || value.isEmpty);
    return params;
  }

  Future<void> fetchPosts({bool DANGEROUS_clearList = false}) async {
    if (DANGEROUS_clearList) {
      isLoading.value = true;
      pageNumber.value = 1;
      list.clear();
    } else {
      // Don't set isLoading to true for "load more"
      // you might want a separate isLoadingMore if you need specific UI for it
      isLoadingMore.value = true;
    }

    try {
      final newItems = await GetPostsAccountModel().getPosts(parametrs: _getCurrentParams());
      if (newItems.isNotEmpty) {
        list.addAll(newItems);
      }
      // Update: This should be handled by SmartRefresher's loadComplete/loadNoData
      // else if (!DANGEROUS_clearList) {
      //   // No more items to load for pagination
      // }
    } catch (e) {
      print('Error fetching posts: $e');
      // Handle error appropriately
    } finally {
      if (DANGEROUS_clearList) {
        isLoading.value = false;
      } else {
        isLoadingMore.value = false;
      }
    }
  }

  void clearAndFetch() {
    // This method is called when filters change
    pageNumber.value = 1; // Reset page number
    // list.clear(); // fetchPosts with DANGEROUS_clearList: true will do this
    fetchPosts(DANGEROUS_clearList: true);
  }

  dynamic clearData() {
    sortName.value = '';
    sortType.value = '';
    sortCityName.value = '';
    sortCityType.value = '';
    sortTypePrice.value = '';
    sortNamePrice.value = '';
    sortTypePriceMax.value = '';
    sortNamePriceMax.value = '';
    list.clear();
    pageNumber.value = 1;
    // isLoading.value = true; // Or false, depending on desired state after full clear
  }
}
