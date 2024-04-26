import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_food_delivery_app/src/repository/authentication_repository/authentication_repository.dart';

class MyOrders extends StatefulWidget {
  const MyOrders({super.key});

  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  final TextEditingController _searchController = TextEditingController();

  String id = "";
  String searchQuery = "";
  bool _isLoading = false;

  bool hasData = false;

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('Orders')
        .where('id',
            isEqualTo:
                AuthenticationRepository.instance.firebaseUser.value!.uid)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      setState(() {
        //set hasData if there is data
        hasData = snapshot.docs.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search here...',
            hintStyle: const TextStyle(
              color: Colors.white,
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search,
              color: Colors.white,
            ),
            //clear icon
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          onChanged: (value) {
            setState(() {
              id = value;
              searchQuery = value;
            });
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('Orders')
            .where('id',
                isEqualTo:
                    AuthenticationRepository.instance.firebaseUser.value!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            // Retrieve cart list from Firebase
            final filteredProducts = snapshot.data!.docs.where((x) {
              final productId = x.id.toLowerCase() +
                  x['productName'].toString().toLowerCase() +
                  x['productCategory'].toString().toLowerCase() +
                  x['dateAdded'].toString().toLowerCase() +
                  x['orderID'].toString().toLowerCase() +
                  x['productDetails'].toString().toLowerCase() +
                  x['productPrice'].toString().toLowerCase();

              final searchQuery = _searchController.text.toLowerCase();
              return productId.contains(searchQuery);
            }).toList();

            return Column(
              children: [
                //Display cart list
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final cartItem = filteredProducts[index];

                      QueryDocumentSnapshot x = filteredProducts[index];

                      //list of image urls

                      // final pImages = x['productImages'];
                      // List<String>? productImages;
                      // if (pImages is List<dynamic>) {
                      //   productImages = pImages.cast<String>().toList();
                      // }

                      final pNames = x['productName'];
                      List<String>? productNames;
                      if (pNames is List<dynamic>) {
                        productNames = pNames.cast<String>().toList();
                      }

                      final pQuantity = x['quantity'];
                      List<String>? productQuantities;
                      if (pQuantity is List<dynamic>) {
                        productQuantities = pQuantity.cast<String>().toList();
                      }

                      final pPrice = x['productPrice'];
                      List<String>? productPrices;
                      if (pPrice is List<dynamic>) {
                        productPrices = pPrice.cast<String>().toList();
                      }

                      print("Product names length = ${productNames!.length}");
                      print(
                          "Product quantity length = ${productQuantities!.length}");
                      print("Product prices length = ${productPrices!.length}");

                      String productNamesString = "";
                      String productQuantitiesString = "";
                      String productPricesString = "";

                      for (var i = 0; i < productNames.length - 1; i++) {
                        productNamesString += productNames[i] + "\n";
                        productQuantitiesString += productQuantities[i] + "\n";
                        productPricesString += "\$ " + productPrices[i] + "\n";
                      }

                      return Column(
                        children: [
                          Center(
                              child: Text(
                            "Order # ${x['orderID']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          )),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Text(
                                  "Product Name  \n$productNamesString",
                                  style: const TextStyle(fontSize: 20.0),
                                ),
                                const SizedBox(
                                  width: 20.0,
                                ),
                                Text(
                                  "Quantity  \n$productQuantitiesString",
                                  style: const TextStyle(fontSize: 20.0),
                                ),
                                const SizedBox(
                                  width: 20.0,
                                ),
                                Text(
                                  "Price  \n$productPricesString",
                                  style: const TextStyle(fontSize: 20.0),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            height: 2.0,
                            color: Colors.black,
                            thickness: .2,
                          ),
                          Row(
                            children: [
                              Text(
                                "Total :  \$  ${cartItem['totalAmount']}",
                                style: const TextStyle(fontSize: 26.0),
                              ),
                              const SizedBox(
                                width: 20.0,
                              ),
                              Text(
                                "Paid : ${cartItem['paid']}",
                                style: const TextStyle(fontSize: 26.0),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 2.0,
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                //textView Total amount

                const SizedBox(
                  height: 10.0,
                ),
                // Checkout button
                hasData
                    ? ElevatedButton(
                        onPressed: () {
                          // Perform clear order logic here

                          popUpClearDialog(
                              context,
                              AuthenticationRepository
                                  .instance.firebaseUser.value!.uid);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.clear_all),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'Clear History',
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  popUpDialog(BuildContext context, String docID) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: Text(
                "Warning",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              content: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isLoading == true
                        ? Column(
                            children: [
                              Center(
                                child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor),
                              ),
                              const Text("Deleting .....")
                            ],
                          )
                        : const Text(
                            "Are you Sure you want to remove this product from your cart ?"),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "CANCEL",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                //space
                const SizedBox(
                  width: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });

                    print(docID);
                    try {
                      final CollectionReference cartCollection =
                          FirebaseFirestore.instance.collection("Cart");

                      //delete the product from cart
                      await cartCollection.doc(docID).delete().then((value) {
                        setState(() {
                          _isLoading = false;
                        });
                      });

                      // Success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Product Deleted from Cart Sucessfully')),
                      );
                    } catch (e) {
                      // Error message
                      print(e.toString());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Failed to delete product from cart')),
                      );
                    }

                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Continue",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              ],
            );
          }));
        });
  }

  popUpClearDialog(BuildContext context, String id) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: Text(
                "Warning",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              content: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _isLoading == true
                        ? Column(
                            children: [
                              Center(
                                child: CircularProgressIndicator(
                                    color: Theme.of(context).primaryColor),
                              ),
                              const Text("Clearing .....")
                            ],
                          )
                        : const Text(
                            "Are you Sure you want to clear history ?"),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "CANCEL",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),
                //space
                const SizedBox(
                  width: 15,
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });

                    print(id);
                    try {
                      final CollectionReference cartCollection =
                          FirebaseFirestore.instance.collection("Orders");

                      //delete the orders firebase where orderid = id

                      await cartCollection
                          .where('id', isEqualTo: id)
                          .get()
                          .then((value) {
                        value.docs.forEach((element) {
                          element.reference.delete();
                        });
                      });

                      setState(() {
                        _isLoading = false;
                      });

                      // Success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'History Cleared Sucessfully Sucessfully')),
                      );
                    } catch (e) {
                      // Error message
                      print(e.toString());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Failed to Clear history')),
                      );
                    }

                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Continue",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              ],
            );
          }));
        });
  }
}
