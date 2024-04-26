import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:online_food_delivery_app/src/constants/image_strings.dart';
import 'package:online_food_delivery_app/src/features/core/services/helper/helper_function.dart';

import '../helper/my_date_util.dart';
import '../../../../../../main.dart';
import '../models/chat_user.dart';

//view profile screen -- to view profile of user
class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;

  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  ChatUser? myData;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    ChatUser? userData = await CommunityGroupHelperFunctions.getUserFromPref();
    setState(() {
      myData = userData!;
    });
    print("MY DATA RETRIEVED: $myData");
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          //app bar
          appBar: AppBar(title: Text(widget.user.name)),
          floatingActionButton: //user about
              Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Joined On: ',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              ),
              Text(
                MyDateUtil.getLastMessageTime(
                    context: context,
                    time: widget.user.createdAt,
                    showYear: true),
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          //body
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // for adding some space
                  SizedBox(width: mq.width, height: mq.height * .03),

                  //user profile picture
                  widget.user.image.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .1),
                          child: CachedNetworkImage(
                            width: mq.height * .2,
                            height: mq.height * .2,
                            fit: BoxFit.cover,
                            imageUrl: widget.user.image,
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                                    child: Icon(CupertinoIcons.person)),
                          ),
                        )
                      : SizedBox(
                          height: mq.height * .2,
                          width: mq.height * .2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(mq.height * .1),
                            child: CircleAvatar(
                              child: Icon(
                                CupertinoIcons.person,
                                size: mq.width * .40,
                                weight: mq.width * .1,
                              ),
                            ),
                          ),
                        ),

                  // for adding some space
                  SizedBox(height: mq.height * .03),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            MyDateUtil.getLastActiveTime(
                              context: context,
                              lastActive: widget.user.lastActive,
                            ),
                            style: const TextStyle(
                                color: Colors.green, fontSize: 15)),
                      ],
                    ),
                  ),
                  SizedBox(height: mq.height * .03),
                  // user email label
                  Text(
                    widget.user.email,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                  ),

                  // for adding some space
                  SizedBox(height: mq.height * .03),
                  GestureDetector(
                    onTap: () {
                      print(widget.user.toJson());
                    },
                    child: const Text(
                      'About: ',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                          fontSize: 15),
                    ),
                  ),
                  //user about

                  SizedBox(
                    width:
                        double.infinity, // Adjust the width as per your layout
                    child: Text(
                      widget.user.about,
                      maxLines:
                          3, // Adjust the number of lines as per your requirement
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 15,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),

                  SizedBox(height: mq.height * .01),
                  //phone number
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Phone : ',
                        style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w900,
                            fontSize: 15),
                      ),
                      Text(
                        widget.user.phoneNo,
                        style: const TextStyle(
                            color: Colors.black54, fontSize: 15),
                      ),
                    ],
                  ),
                  SizedBox(height: mq.height * .03),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Clubs in Common',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      if (myData != null)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: myData!.groups.map((group) {
                              final groupParts = group.split('_');
                              if (groupParts.length >= 2) {
                                final groupText = groupParts[1];
                                if (widget.user.groups.contains(group)) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      left: 5,
                                      right: 5,
                                      bottom: 20,
                                      top: 30,
                                    ),
                                    child: SizedBox(
                                      width: 120,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Column(
                                          children: [
                                            const CircleAvatar(
                                              backgroundColor:
                                                  Colors.transparent,
                                              backgroundImage: AssetImage(
                                                tGroupImage,
                                              ),
                                            ),
                                            SizedBox(height: mq.height * .01),
                                            Text(groupText),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              }
                              return const SizedBox.shrink();
                            }).toList(),
                          ),
                        ),
                      if (myData == null || myData!.groups.isEmpty)
                        Container(
                          child: const Padding(
                              padding: EdgeInsets.all(40),
                              child: Text("0 Clubs")),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
