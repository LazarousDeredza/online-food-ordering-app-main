import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_food_delivery_app/src/features/core/screens/product/model_product.dart';
import 'package:online_food_delivery_app/src/features/core/screens/product/view_image.dart';
import 'package:online_food_delivery_app/src/repository/authentication_repository/authentication_repository.dart';

class ViewProductScreen extends StatefulWidget {
  final String productID;

  //user id from firebase currently logged in user

  const ViewProductScreen({super.key, required this.productID});

  @override
  _ViewProductScreenState createState() => _ViewProductScreenState();
}

class _ViewProductScreenState extends State<ViewProductScreen> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _productFuture;

  late String? userId;
  int quantity = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _productFuture = FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productID)
        .get();

    //initiate the user id from firebase
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  final _commentController = TextEditingController();
  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Product'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data available'));
          }

          final productData = snapshot.data!.data();
          final productImages = productData!['productImages'];

          List<String>? castedProductImageUrls;
          if (productImages is List<dynamic>) {
            castedProductImageUrls = productImages.cast<String>().toList();
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (castedProductImageUrls != null &&
                      castedProductImageUrls.isNotEmpty)
                    SizedBox(
                      height: 300,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: castedProductImageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MyImageWidget(
                                          imageUrl:
                                              castedProductImageUrls![index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Image.network(
                                    castedProductImageUrls![index],
                                    width: 225,
                                    height: 300,
                                    fit: BoxFit.fill,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) {
                                        return child;
                                      } else {
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  // Display the case properties
                  const SizedBox(height: 16.0),
                  Container(
                    color: Colors.grey[300],
                    width: double.infinity,
                    padding: const EdgeInsets.all(15.0),
                    child: Center(
                      child: RichText(
                        text: TextSpan(
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.black,
                              ),
                          children: [
                            const TextSpan(
                              text: 'Product Name   :   ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                            TextSpan(
                              text: '${productData['productName']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

//add to cart button

// Add to cart button
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Add logic to add the product to the cart

                        //show quantity dialoag

                        Cart cart = Cart(
                            dateAdded: productData['dateAdded'],
                            productCategory: productData['productCategory'],
                            productDetails: productData['productDetails'],
                            productImages: castedProductImageUrls,
                            productName: productData['productName'],
                            productPrice: productData['productPrice'],
                            id: AuthenticationRepository
                                .instance.firebaseUser.value!.uid,
                            quantity: 1);
                        popUpDialog(context, cart);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_cart),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Add to Cart',
                              style: TextStyle(fontSize: 18.0),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Center(
                      child: Text(
                        'Product Details',
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              decoration: TextDecoration.underline,
                            ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: RichText(
                      text: TextSpan(
                        style: Theme.of(context).textTheme.headlineSmall,
                        children: [
                          const TextSpan(
                            text: 'Description   :   ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: '${productData['productDetails']}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      'Date Added   :     ${productData['dateAdded']}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      'Product Category    :     ${productData['productCategory']}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      'Product Price    :   \$ ${productData['productPrice']}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 5.0, bottom: 15.0),
                    child: Center(
                      child: Text(
                        "Comments",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ),
                  //if case is open put a text field to add comments and a button to submit in a row

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Add a Comment',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2.0),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2.0),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(2.0),
                              borderSide: const BorderSide(
                                color: Colors.grey,
                                width: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      ElevatedButton(
                        onPressed: isSaving
                            ? () {
                                print("is saving");
                              }
                            : submitComment,
                        //submit comment to firebase

                        child: const Text('Submit'),
                      ),
                    ],
                  ),

                  //show a list of comments from firebase where case id is equal to the case id of the case being viewed and approved is equal to yes
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('comments')
                        .where('productID', isEqualTo: widget.productID)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData) {
                        return const Center(
                            child: Text('No Comments available'));
                      }

                      final comments = snapshot.data!.docs;

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Column(children: [
                              ListTile(
                                leading:
                                    //user profile icon
                                    const CircleAvatar(
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15.0, right: 10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(comments[index]['comment']),
                                      ),
                                      const SizedBox(height: 5.0),
                                      Row(
                                        children: [
                                          //like icon
                                          GestureDetector(
                                            onTap: () async {
                                              //update the likes field in firebase

                                              LikeAndDislike likeAndDilike =
                                                  LikeAndDislike(
                                                      productID:
                                                          widget.productID,
                                                      userID: userId,
                                                      date: DateTime.now()
                                                          .toString());

                                              //check if the user has already liked the comment
                                              await FirebaseFirestore.instance
                                                  .collection('comments')
                                                  .doc(comments[index].id)
                                                  .collection('likes')
                                                  .where('userID',
                                                      isEqualTo: userId)
                                                  .get()
                                                  .then((value) async => {
                                                        if (value.docs.isEmpty)
                                                          {
                                                            //check if i had disliked the comment before and remove it ,and deduct the number of dislikes by 1
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'comments')
                                                                .doc(comments[
                                                                        index]
                                                                    .id)
                                                                .collection(
                                                                    'dislikes')
                                                                .where('userID',
                                                                    isEqualTo:
                                                                        userId)
                                                                .get()
                                                                .then(
                                                                    (value) async =>
                                                                        {
                                                                          if (value
                                                                              .docs
                                                                              .isNotEmpty)
                                                                            {
                                                                              //remove the user from the dislikes collection
                                                                              await FirebaseFirestore.instance.collection('comments').doc(comments[index].id).collection('dislikes').doc(value.docs.first.id).delete().then((value) => {
                                                                                    //update the dislikes field in the comments collection
                                                                                    FirebaseFirestore.instance.collection('comments').doc(comments[index].id).update({
                                                                                      'numberOfDislikes': comments[index]['numberOfDislikes'] - 1
                                                                                    })
                                                                                  })
                                                                            }
                                                                        }),

                                                            //add the user to the likes collection
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'comments')
                                                                .doc(comments[
                                                                        index]
                                                                    .id)
                                                                .collection(
                                                                    'likes')
                                                                .add(likeAndDilike
                                                                    .toJson())
                                                                .then(
                                                                    (value) async =>
                                                                        {
                                                                          //update the likes field in the comments collection
                                                                          await FirebaseFirestore.instance.collection('comments').doc(comments[index].id).update({
                                                                            'numberOfLikes':
                                                                                comments[index]['numberOfLikes'] + 1
                                                                          }).then((value) =>
                                                                              {
                                                                                //toast message
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Text('Comment liked successfully'),
                                                                                  ),
                                                                                ),
                                                                              })
                                                                        })
                                                          }
                                                        else
                                                          {
                                                            //toast message
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'You have already liked this comment'),
                                                              ),
                                                            ),
                                                          }
                                                      });
                                            },
                                            child: const Icon(
                                              Icons.thumb_up,
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          const SizedBox(width: 5.0),
                                          Padding(
                                              padding:
                                                  const EdgeInsets.all(6.0),
                                              child: Text(
                                                  '${comments[index]['numberOfLikes']}')),
                                          const SizedBox(width: 40.0),
                                          //dislike icon
                                          GestureDetector(
                                            onTap: () async {
                                              //update the likes field in firebase

                                              LikeAndDislike likeAndDilike =
                                                  LikeAndDislike(
                                                      productID:
                                                          widget.productID,
                                                      userID: userId,
                                                      date: DateTime.now()
                                                          .toString());

                                              //check if the user has already disliked the comment
                                              await FirebaseFirestore.instance
                                                  .collection('comments')
                                                  .doc(comments[index].id)
                                                  .collection('dislikes')
                                                  .where('userID',
                                                      isEqualTo: userId)
                                                  .get()
                                                  .then((value) async => {
                                                        if (value.docs.isEmpty)
                                                          {
                                                            //check if i had liked the comment before and remove it ,and deduct the number of likes by 1
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'comments')
                                                                .doc(comments[
                                                                        index]
                                                                    .id)
                                                                .collection(
                                                                    'likes')
                                                                .where('userID',
                                                                    isEqualTo:
                                                                        userId)
                                                                .get()
                                                                .then(
                                                                    (value) async =>
                                                                        {
                                                                          if (value
                                                                              .docs
                                                                              .isNotEmpty)
                                                                            {
                                                                              //remove the user from the likes collection
                                                                              await FirebaseFirestore.instance.collection('comments').doc(comments[index].id).collection('likes').doc(value.docs.first.id).delete().then((value) async => {
                                                                                    //update the likes field in the comments collection
                                                                                    await FirebaseFirestore.instance.collection('comments').doc(comments[index].id).update({
                                                                                      'numberOfLikes': comments[index]['numberOfLikes'] - 1
                                                                                    })
                                                                                  })
                                                                            }
                                                                        }),

                                                            //add the user to the dislikes collection
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'comments')
                                                                .doc(comments[
                                                                        index]
                                                                    .id)
                                                                .collection(
                                                                    'dislikes')
                                                                .add(likeAndDilike
                                                                    .toJson())
                                                                .then(
                                                                    (value) async =>
                                                                        {
                                                                          //update the dislikes field in the comments collection
                                                                          await FirebaseFirestore.instance.collection('comments').doc(comments[index].id).update({
                                                                            'numberOfDislikes':
                                                                                comments[index]['numberOfDislikes'] + 1
                                                                          }).then((value) =>
                                                                              {
                                                                                //toast message
                                                                                ScaffoldMessenger.of(context).showSnackBar(
                                                                                  const SnackBar(
                                                                                    content: Text('Comment disliked successfully'),
                                                                                  ),
                                                                                ),
                                                                              })
                                                                        })
                                                          }
                                                        else
                                                          {
                                                            //toast message
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'You have already disliked this comment'),
                                                              ),
                                                            ),
                                                          }
                                                      });
                                            },
                                            child: const Icon(
                                              Icons.thumb_down,
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                          const SizedBox(width: 5.0),
                                          Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Text(
                                              '${comments[index]['numberOfDislikes']}',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(
                                padding:
                                    EdgeInsets.only(left: 20.0, right: 20.0),
                                child: Divider(
                                  thickness: 2.0,
                                ),
                              ),
                            ]),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  popUpDialog(BuildContext context, Cart cart) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialog(
              title: Text(
                "How much quantity do you want ?",
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
                        ? Center(
                            child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor),
                          )
                        : TextField(
                            onChanged: (val) {
                              setState(() {
                                quantity = int.parse(val);
                              });
                            },
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontSize: 16,
                                  fontStyle: FontStyle.normal,
                                ),
                            maxLines: 1,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                                hintText: 'Quantity',
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(20)),
                                errorBorder: OutlineInputBorder(
                                    borderSide:
                                        const BorderSide(color: Colors.red),
                                    borderRadius: BorderRadius.circular(20)),
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(20))),
                          ),
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

                    Cart newCart = Cart(
                      dateAdded: cart.dateAdded,
                      productCategory: cart.productCategory,
                      productDetails: cart.productDetails,
                      productName: cart.productName,
                      productImages: cart.productImages,
                      productPrice: cart.productPrice,
                      id: cart.id,
                      quantity: quantity,
                    );

                    try {
                      final CollectionReference cartCollection =
                          FirebaseFirestore.instance.collection("Cart");

                      await cartCollection.add(newCart.toJson()).then((value) {
                        setState(() {
                          _isLoading = false;
                        });
                      });

                      // Success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Product saved to Your Cart Sucessfully')),
                      );
                    } catch (e) {
                      // Error message
                      print(e.toString());
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to save cart')),
                      );
                    }

                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Add",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              ],
            );
          }));
        });
  }

  void submitComment() async {
    //only save if the comment is not empty
    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment cannot be empty'),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    Comment comment = Comment(
        comment: _commentController.text,
        productID: widget.productID,
        userID: userId,
        date: DateTime.now().toString(),
        numberOfDislikes: 0,
        numberOfLikes: 0,
        approved: "No");

    await FirebaseFirestore.instance
        .collection('comments')
        .add(comment.toJson())
        .then((value) => {
              //clear the text field
              _commentController.clear(),
              //toast message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comment Added Successfully'),
                ),
              ),

              setState(() {
                isSaving = false;
              }),

              //show a list of comments

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewProductScreen(
                    productID: widget.productID,
                  ),
                ),
              )
            });
  }
}
