import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_food_delivery_app/src/features/core/screens/product/product_repo.dart';
import 'package:online_food_delivery_app/src/features/core/screens/product/products_list.dart';
import 'package:online_food_delivery_app/src/features/core/screens/product/model_product.dart';

class ProductController extends GetxController {
  static ProductController get instance => Get.find();

  final _peoductRepo = Get.put(ProductRespository());
  //get user email and pass to userRepository to fetch user details

//get all cases
  Future<List<Product>> getAllProducts() async {
    return _peoductRepo.getAllProducts();
  }

  //save case

  Future<void> saveProduct(Product productModel) async {
    //snackbar
    Get.snackbar(
      "Please wait",
      "Saving Product",
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(
        Icons.sync_rounded,
        color: Colors.green,
      ),
    );
    await _peoductRepo.saveProduct(productModel.toJson()).whenComplete(() {
      print("Product saved successfully ");

      Get.snackbar(
        "Success",
        "Product saved successfully ",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 10),
        icon: const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
        ),
      );
      Get.to(() => const ProductListScreen());
    }).catchError((onError) {
      Get.snackbar(
        "Error",
        "Product not saved",
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(
          Icons.error_outline,
          color: Colors.red,
        ),
      );
      return onError;
    });
  }

  // updateRecord(UserModel user) async {
  //   Get.snackbar(
  //     "Please wait",
  //     "Updating user details",
  //     snackPosition: SnackPosition.BOTTOM,
  //     icon: Icon(
  //       Icons.sync_rounded,
  //       color: Colors.green,
  //     ),
  //   );
  //   await _caseRepo.updateUserRecord(user);
  // }
}
