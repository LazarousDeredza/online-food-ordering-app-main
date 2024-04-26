//4012001037141112 : Payment Testing account
//123 : CVV
//Any : Expiry Date
//URL : https://dashboard.razorpay.com/app/payments
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:online_food_delivery_app/src/features/authentication/models/user_model.dart';
import 'package:online_food_delivery_app/src/features/core/screens/product/model_product.dart';
import 'package:online_food_delivery_app/src/repository/authentication_repository/authentication_repository.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartHome extends StatefulWidget {
  const CartHome({super.key});

  @override
  _CartHomeState createState() => _CartHomeState();
}

class _CartHomeState extends State<CartHome> {
  final TextEditingController _searchController = TextEditingController();

  String id = "";
  String searchQuery = "";
  bool _isLoading = false;
  double totalAmount = 0.0;

  bool hasData = false;

  final List<String>? productName = [];
  final List<String>? productPrice = [];
  final List<String>? productImages = [];
  final List<String>? quantity = [];

  //firebase user

  // Get the current user
  User? currentUser = FirebaseAuth.instance.currentUser;

  UserModel _userModel = const UserModel(
    id: "",
    name: "",
    firstName: "",
    lastName: "",
    email: "",
    phoneNo: "",
    password: "",
    instGroups: [],
    about: "",
    isOnline: false,
    lastActive: "",
    pushToken: "",
  );

  MyOrder _order = MyOrder(
      orderID: "0001",
      totalAmount: "0.0",
      paid: true,
      dateAdded: "Today",
      productName: [],
      productCategory: [],
      productDetails: [],
      productImages: [],
      quantity: [],
      productPrice: []);

  @override
  void initState() {
    super.initState();

    // Get the current user's data
    FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        _userModel = UserModel.fromSnapshot(value);

        print(_userModel.toString());
      });
    });

    FirebaseFirestore.instance
        .collection('Cart')
        .where('id',
            isEqualTo:
                AuthenticationRepository.instance.firebaseUser.value!.uid)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      double newTotal = 0.0;
      for (var element in snapshot.docs) {
        double price = double.parse(element['productPrice']);
        int quantity = element['quantity'];

        double subtotal = price * quantity;
        newTotal += subtotal;
      }
      setState(() {
        totalAmount = double.parse(newTotal.toStringAsFixed(2));

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
            .collection('Cart')
            .where('id',
                isEqualTo:
                    AuthenticationRepository.instance.firebaseUser.value!.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            // Retrieve cart list from Firebase
            final filteredProducts = snapshot.data!.docs.where((x) {
              final productId = x.id.toLowerCase() +
                  x['productName'].toLowerCase() +
                  x['productCategory'].toLowerCase() +
                  x['dateAdded'].toLowerCase() +
                  x['productDetails'].toLowerCase() +
                  x['productPrice'].toLowerCase();

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

                      final pImages = x['productImages'];

                      List<String>? productImages;
                      if (pImages is List<dynamic>) {
                        productImages = pImages.cast<String>().toList();
                      }

                      productName!.add(x['productName']);
                      productPrice!.add(x['productPrice']);
                      productImages!.add(x['productImages'][0]);
                      quantity!.add(x['quantity'].toString());

                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              backgroundImage: NetworkImage(productImages[0]),
                            ),
                            title: Text(
                              cartItem['productName'],
                              textAlign: TextAlign.center,
                            ),
                            subtitle: Column(
                              children: [
                                Text('Price: \$ ${cartItem['productPrice']}'),
                                Text("Quantity  :  x${cartItem['quantity']}")
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                popUpDialog(context, x.id);
                              },
                            ),
                          ),
                          const Divider(
                            height: 2.0,
                          )
                        ],
                      );
                    },
                  ),
                ),
                //textView Total amount

                Center(
                  child: Text(
                    "Total :  \$ $totalAmount",
                    style: const TextStyle(fontSize: 26.0),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                // Checkout button
                hasData
                    ? ElevatedButton(
                        onPressed: () {
                          String date = DateTime.now().toString();
                          String orderID = generateOrderID();
                          // Perform checkout logic here
                          MyOrder order = MyOrder(
                            id: AuthenticationRepository
                                .instance.firebaseUser.value!.uid,
                            dateAdded: date,
                            orderID: orderID,
                            paid: true,
                            productCategory: [],
                            productDetails: [],
                            productImages: productImages,
                            productName: productName,
                            productPrice: productPrice,
                            quantity: quantity,
                            totalAmount: totalAmount.toString(),
                          );
                          setState(() {
                            _order = order;
                          });

                          print(order.toString());

                          print(".................");

                          print(_userModel.name);
                          print((totalAmount * 100).toInt());
                          String orders = order.productName!.join(' ');
                          print(" $orders");
                          print(_userModel.phoneNo);
                          print(_userModel.email);
                          print(".................");

                          Razorpay razorpay = Razorpay();
                          var options = {
                            'key': 'rzp_test_7wgJ3Fl2rDfjid',
                            'amount': (totalAmount * 100).toInt(),
                            'name': 'Foodie Delight Order',
                            'currency': 'USD',
                            'description':
                                "${_userModel.name}'s Payment for order #$orderID",
                            'retry': {
                              'enabled': true,
                              'max_count': 1,
                            },
                            'send_sms_hash': true,
                            'prefill': {
                              'contact': _userModel.phoneNo,
                              'email': _userModel.email,
                            },
                            'external': {
                              'wallets': ['paytm']
                            }
                          };
                          razorpay.on(Razorpay.EVENT_PAYMENT_ERROR,
                              handlePaymentErrorResponse);
                          razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,
                              handlePaymentSuccessResponse);
                          razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET,
                              handleExternalWalletSelected);
                          razorpay.open(options);
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text(
                                'Checkout',
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

  String generateOrderID() {
    String orderID = "";
    Random random = Random();

    for (int i = 0; i < 6; i++) {
      int randomNumber =
          random.nextInt(10); // Generate a random number between 0 and 9
      orderID += randomNumber
          .toString(); // Append the random number to the orderID string
    }

    return orderID;
  }

  void handlePaymentErrorResponse(PaymentFailureResponse response) {
    /*
    * PaymentFailureResponse contains three values:
    * 1. Error Code
    * 2. Error Description
    * 3. Metadata
    * */
    showAlertDialog(context, "Payment Failed",
        "Code: ${response.code}\nDescription: ${response.message}");
  }

  Future<void> handlePaymentSuccessResponse(
      PaymentSuccessResponse response) async {
    /*
    * Payment Success Response contains three values:
    * 1. Order ID
    * 2. Payment ID
    * 3. Signature
    * */
    //save  _order to firebase orders

    await FirebaseFirestore.instance
        .collection('Orders')
        .doc(_order.orderID)
        .set(_order.toJson())
        .then((value) {
      print("Order added to firebase");
    });

    //delete cart
    await FirebaseFirestore.instance
        .collection('Cart')
        .where('id',
            isEqualTo:
                AuthenticationRepository.instance.firebaseUser.value!.uid)
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
    showAlertDialog(
        context, "Payment Successful", "Payment ID: ${response.paymentId}");
  }

  void handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(
        context, "External Wallet Selected", "${response.walletName}");
  }

  void showAlertDialog(BuildContext context, String title, String message) {
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
