import 'dart:io';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../models/article.dart';
import '../models/category.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (loggedIn) {
      Get.offAllNamed('/main');
    }
  }

  Future<void> register(String username, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final success = await AuthService.register(username, password);
      if (success) {
        Get.snackbar(
          'Success',
          'Account created successfully. Please log in.',
          snackPosition: SnackPosition.TOP,
        );
        Get.offNamed('/login');
      } else {
        errorMessage.value = 'Username is already in use!';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String username, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final success = await AuthService.login(username, password);
      if (success) {
        Get.offAllNamed('/main');
      } else {
        errorMessage.value = 'Invalid username or password!';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    Get.offAllNamed('/login');
  }
}

class MainNavController extends GetxController {
  RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }
}

class StoreController extends GetxController {
  RxList<Article> products = <Article>[].obs;
  RxList<Category> categories = <Category>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxString selectedCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    fetchProducts();
  }

  Future<void> fetchProducts({String? category}) async {
    isLoading.value = true;
    errorMessage.value = '';
    selectedCategory.value = category ?? '';

    try {
      final data = category == null || category.isEmpty
          ? await ApiService.fetchArticles(limit: 20, skip: 0)
          : await ApiService.fetchProductsByCategory(
              category,
              limit: 20,
              skip: 0,
            );
      products.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCategories() async {
    try {
      categories.value = await ApiService.fetchCategories();
    } catch (_) {
      categories.clear();
    }
  }

  @override
  Future<void> refresh() async {
    await fetchProducts(
      category: selectedCategory.value.isEmpty ? null : selectedCategory.value,
    );
  }

  Future<Article?> findById(int id) async {
    try {
      final cached = products.where((item) => item.id == id).toList();
      if (cached.isNotEmpty) {
        return cached.first;
      }
      return await ApiService.fetchArticleDetail(id: id);
    } catch (_) {
      return null;
    }
  }
}

class DetailController extends GetxController {
  Rxn<Article> article = Rxn<Article>();
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  RxBool inCart = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final args = Get.arguments;
      if (args is Map<String, dynamic> && args['product'] is Article) {
        article.value = args['product'] as Article;
      } else if (args is Map<String, dynamic> && args['id'] is int) {
        final id = args['id'] as int;
        final storeController = Get.isRegistered<StoreController>()
            ? Get.find<StoreController>()
            : null;
        article.value = storeController != null
            ? await storeController.findById(id)
            : await ApiService.fetchArticleDetail(id: id);
      }

      if (article.value != null) {
        inCart.value = await AuthService.isInCart(article.value!.id);
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleCart() async {
    final current = article.value;
    if (current == null) {
      return;
    }

    final cartIds = await AuthService.toggleCartId(current.id);
    inCart.value = cartIds.contains(current.id.toString());

    if (Get.isRegistered<CartController>()) {
      await Get.find<CartController>().loadCartItems();
    }

    Get.snackbar(
      'Cart',
      inCart.value ? 'Product added to cart' : 'Product removed from cart',
      snackPosition: SnackPosition.TOP,
    );
  }
}

class CartController extends GetxController {
  RxList<Article> items = <Article>[].obs;
  RxBool isLoading = false.obs;
  RxBool isCheckingOut = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCartItems();
  }

  Future<void> loadCartItems() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final cartIds = await AuthService.getCartIds();
      if (cartIds.isEmpty) {
        items.clear();
        return;
      }

      final loadedItems = <Article>[];
      for (final idString in cartIds) {
        final id = int.tryParse(idString);
        if (id == null) {
          continue;
        }
        final product = await ApiService.fetchArticleDetail(id: id);
        loadedItems.add(product);
      }
      items.assignAll(loadedItems);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeProduct(int productId) async {
    final cartIds = await AuthService.getCartIds();
    cartIds.remove(productId.toString());
    await AuthService.setCartIds(cartIds);
    await loadCartItems();
  }

  Future<void> checkout() async {
    if (items.isEmpty || isCheckingOut.value) {
      return;
    }

    isCheckingOut.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));
      await AuthService.clearCart();
      items.clear();
      Get.snackbar(
        'Purchase complete',
        'This is a fake checkout. Your cart has been cleared.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isCheckingOut.value = false;
    }
  }

  double get totalPrice {
    double total = 0.0;
    for (final item in items) {
      total += item.priceValue;
    }
    return total;
  }

  int get itemCount => items.length;
}

class ProfileController extends GetxController {
  final ImagePicker _picker = ImagePicker();
  RxString fullName = 'Ilham Cesario Putra Wippri'.obs;
  RxString nim = '123230106'.obs;
  RxString username = ''.obs;
  RxString avatarPath = ''.obs;
  Rxn<File> avatarFile = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    username.value = await AuthService.getCurrentUsername();
    avatarPath.value = await AuthService.getProfileImagePath();

    if (avatarPath.value.isNotEmpty) {
      avatarFile.value = File(avatarPath.value);
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked != null) {
        avatarFile.value = File(picked.path);
        avatarPath.value = picked.path;
        await AuthService.setProfileImagePath(picked.path);
        Get.snackbar(
          'Success',
          source == ImageSource.camera
              ? 'Photo updated from camera.'
              : 'Photo updated from gallery.',
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update photo: $e',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }
}
