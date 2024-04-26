import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:online_food_delivery_app/main.dart';
import 'package:online_food_delivery_app/src/features/core/screens/personal_chat/api/apis.dart';
import 'package:online_food_delivery_app/src/constants/image_strings.dart';
import 'package:online_food_delivery_app/src/features/authentication/models/user_model.dart';
import 'package:online_food_delivery_app/src/features/core/controllers/profile_controller.dart';
import 'package:online_food_delivery_app/src/features/core/screens/personal_chat/models/chat_user.dart';
import 'package:online_food_delivery_app/src/features/core/screens/personal_chat/screens/chat_screen.dart';
import 'package:online_food_delivery_app/src/repository/authentication_repository/authentication_repository.dart';

class ChatUsersScreen extends StatefulWidget {
  const ChatUsersScreen({super.key});

  @override
  _ChatUsersScreenState createState() => _ChatUsersScreenState();
}

class _ChatUsersScreenState extends State<ChatUsersScreen> {
  final controller = Get.put(ProfileController());
  bool isAdmin = false;
  List<UserModel> allUsers = [];
  List<UserModel> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    loadUsers();

    FirebaseFirestore.instance
        .collection("users")
        .doc(AuthenticationRepository.instance.firebaseUser.value!.uid)
        .get()
        .then((value) {
      if (value.data()!["level"] == "admin") {
        setState(() {
          isAdmin = true;
        });
      } else {
        setState(() {
          isAdmin = false;
        });
      }
    });
  }

  Future<void> loadUsers() async {
    List<UserModel> users = await controller.getAllAdmins();
    setState(() {
      allUsers = users;
      filteredUsers = users;
    });
  }

  void filterUsers(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredUsers =
            List.from(allUsers); // If search query is empty, show all users
      });
    } else {
      final lowerCaseQuery = query.toLowerCase();
      setState(() {
        filteredUsers = allUsers.where((user) {
          return user.firstName.toLowerCase().contains(lowerCaseQuery) ||
              user.lastName.toLowerCase().contains(lowerCaseQuery) ||
              user.email.toLowerCase().contains(lowerCaseQuery) ||
              user.name.toLowerCase().contains(lowerCaseQuery) ||
              user.phoneNo.toLowerCase().contains(lowerCaseQuery);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchBar(
              onChanged: (query) => filterUsers(query),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  UserModel userData = filteredUsers[index];
                  return Column(
                    children: [
                      ListTile(
                        shape: ShapeBorder.lerp(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            10),
                        leading: userData.image != null &&
                                userData.image.toString().isNotEmpty
                            ?
                            //image from server
                            GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => ProfileImagePopup(
                                      imageUrl: userData.image.toString(),
                                    ),
                                  );
                                },
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(mq.height * .1),
                                    child: CachedNetworkImage(
                                      fit: BoxFit.cover,
                                      imageUrl: userData.image.toString(),
                                      errorWidget: (context, url, error) =>
                                          const CircleAvatar(
                                              child:
                                                  Icon(CupertinoIcons.person)),
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(
                                width: 50,
                                height: 50,
                                child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(mq.height * .1),
                                  child: const Image(
                                      image: AssetImage(tProfileImage),
                                      fit: BoxFit.cover),
                                ),
                              ),
                        title: GestureDetector(
                          onTap: (() async {
                            await APIs.addChatUser(userData.email)
                                .then((value) {
                              print("Opening Conver");
                              ChatUser user = ChatUser(
                                email: userData.email,
                                firstName: userData.firstName,
                                lastName: userData.lastName,
                                phoneNo: userData.phoneNo,
                                image: userData.image ?? '',
                                about: userData.about,
                                createdAt: userData.createdAt ?? '',
                                groups: userData.groups ?? [],
                                id: userData.id ?? '',
                                isOnline: userData.isOnline,
                                lastActive: userData.lastActive,
                                level: userData.level ?? '',
                                name: userData.name,
                                pushToken: userData.pushToken,
                              );

                              Get.to(
                                () => ChatScreen(
                                  user: user,
                                ),
                              );
                            });
                            print(
                              userData.email,
                            );
                          }),
                          child: Text.rich(
                            TextSpan(
                              text:
                                  "${userData.firstName} ${userData.lastName}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        subtitle: GestureDetector(
                          onTap: (() async {
                            await APIs.addChatUser(userData.email)
                                .then((value) {
                              print("Opening Conver");
                              ChatUser user = ChatUser(
                                email: userData.email,
                                firstName: userData.firstName,
                                lastName: userData.lastName,
                                phoneNo: userData.phoneNo,
                                image: userData.image ?? '',
                                about: userData.about,
                                createdAt: userData.createdAt ?? '',
                                groups: userData.groups ?? [],
                                id: userData.id ?? '',
                                isOnline: userData.isOnline,
                                lastActive: userData.lastActive,
                                level: userData.level ?? '',
                                name: userData.name,
                                pushToken: userData.pushToken,
                              );

                              Get.to(
                                () => ChatScreen(
                                  user: user,
                                ),
                              );
                            });
                            print(
                              userData.email,
                            );
                          }),
                          child: isAdmin
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userData.email,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      userData.phoneNo != "null"
                                          ? userData.phoneNo
                                          : "",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Container(),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.message_rounded,
                            color: Colors.blue,
                          ),
                          onPressed: () async {
                            await APIs.addChatUser(userData.email)
                                .then((value) {
                              print("Opening Conver");
                              ChatUser user = ChatUser(
                                email: userData.email,
                                firstName: userData.firstName,
                                lastName: userData.lastName,
                                phoneNo: userData.phoneNo,
                                image: userData.image ?? '',
                                about: userData.about,
                                createdAt: userData.createdAt ?? '',
                                groups: userData.groups ?? [],
                                id: userData.id ?? '',
                                isOnline: userData.isOnline,
                                lastActive: userData.lastActive,
                                level: userData.level ?? '',
                                name: userData.name,
                                pushToken: userData.pushToken,
                              );

                              Get.to(
                                () => ChatScreen(
                                  user: user,
                                ),
                              );
                            });
                            print(
                              userData.email,
                            );
                          },
                        ),
                      ),
                      const Divider(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBar extends StatefulWidget {
  final Function(String) onChanged;

  const SearchBar({super.key, required this.onChanged});

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: widget.onChanged,
      maxLines: 1,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 16,
          ),
      decoration: InputDecoration(
        labelText: 'Search User',
        prefixIcon: const Icon(Icons.search),
        //rounded border
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
        ),

        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    widget.onChanged('');
                  });
                },
              )
            : null,
      ),
    );
  }
}

class ProfileImagePopup extends StatelessWidget {
  final String imageUrl;

  const ProfileImagePopup({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: CachedNetworkImage(
      imageUrl: imageUrl,
    ));
  }
}
