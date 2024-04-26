import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:online_food_delivery_app/main.dart';
import 'package:online_food_delivery_app/src/constants/image_strings.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final searchController = TextEditingController();
  String searchQuery = "";
  String? docId = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: buildSearchBar(),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where("level", isEqualTo: "user")
            .where("id", isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: Text("No users found"));

          final users = getFilteredUsers(snapshot);

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              return buildUserTile(users[index]);
            },
          );
        },
      ),
    );
  }

  Widget buildSearchBar() {
    return TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      decoration: InputDecoration(
        hintText: "Search...",
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            searchController.clear();
            onSearchChanged('');
          },
        ),
      ),
    );
  }

  List<DocumentSnapshot> getFilteredUsers(AsyncSnapshot snapshot) {
    return snapshot.data!.docs.where((user) => matchSearchTerm(user)).toList();
  }

  bool matchSearchTerm(DocumentSnapshot user) {
    return user['name'].toLowerCase().contains(searchQuery) ||
        user['email'].toLowerCase().contains(searchQuery) ||
        user['phone'].toLowerCase().contains(searchQuery) ||
        user['firstName'].toLowerCase().contains(searchQuery) ||
        user['lastName'].toLowerCase().contains(searchQuery);
  }

  onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  Widget buildUserTile(DocumentSnapshot user) {
    return ListTile(
      // title: Text(user['name']),
      // subtitle: Text(user['email']),

      shape: ShapeBorder.lerp(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          10),
      leading: user['image'] != null && user['image'].toString().isNotEmpty
          ?
          //image from server
          SizedBox(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .1),
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  imageUrl: user['image'].toString(),
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
            )
          :
          //local image
          SizedBox(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .1),
                child:
                    const Image(image: AssetImage(tProfileImage), fit: BoxFit.cover),
              ),
            ),
      title: Text.rich(
        TextSpan(
          text: user['firstName'] + " " + user["lastName"],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            user["email"],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user["phone"] != "null" ? user["phone"] : "",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        icon: const Icon(
          LineAwesomeIcons.edit,
          color: Colors.blue,
        ),
        onPressed: () {
          _showoptionchoosedialog(context);

          docId = user["id"];

          print(
            "${"Email = " + user["email"]}\n Doc Id = $docId",
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showoptionchoosedialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose Option',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);

                        //show a confirm dialog first

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Delete User'),
                              content: const Text(
                                  'Are you sure you want to delete this user ?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    //update the approved field in firebase
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(docId.toString())
                                        .delete()
                                        .then((value) => {
                                              //toast message
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Account deleted successfully'),
                                                ),
                                              ),
                                              //show a list of comments

                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const UsersScreen(),
                                                ),
                                              )
                                            });
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Padding(
                          padding: EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Text('Delete User')),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // logout action
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Make Admin'),
                              content: const Text(
                                  'Are you sure you want to make this user an admin ?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    //update the approved field in firebase
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(docId.toString())
                                        .update({
                                      "level": "admin",
                                    }).then((value) => {
                                              //toast message
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'User made admin successfully'),
                                                ),
                                              ),
                                              //show a list of comments

                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const UsersScreen(),
                                                ),
                                              )
                                            });
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const Padding(
                          padding: EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Text('Make Admin')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
