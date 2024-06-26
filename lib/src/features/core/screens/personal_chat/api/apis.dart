import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:online_food_delivery_app/src/features/core/services/helper/helper_function.dart';

import '../models/chat_user.dart';
import '../models/message.dart';

class APIs {
  // for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  // for accessing cloud firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  // for accessing firebase storage
  static FirebaseStorage storage = FirebaseStorage.instance;

  // for storing self information
  static ChatUser me = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: "Hey, I'm using online_food_delivery_app",
      image: user.photoURL.toString(),
      createdAt: '',
      isOnline: false,
      lastActive: '',
      firstName: '',
      groups: [],
      lastName: '',
      level: '',
      phoneNo: user.phoneNumber.toString(),
      pushToken: '');

  // to return current user
  static User get user => auth.currentUser!;

  // for accessing firebase messaging (Push Notification)
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  // for getting firebase messaging token
  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();

//only do if there is an email signed in on the device

    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;
        log('Push Token: $t');
      }
    });

    // for handling foreground messages
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   log('Got a message whilst in the foreground!');
    //   log('Message data: ${message.data}');

    //   if (message.notification != null) {
    //     log('Message also contained a notification: ${message.notification}');
    //   }
    // });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAAOtGbVhg:APA91bH-CjlWh53d6s0rdLH-cCK-txjnvGzpmyab8FrnsQk-yRlzre6mBL45xgibjS7xm56oCdQpRxXZ1kmgIMDcjPjqSv0Z3rlkx08Gq3duYk1qWV3I6YQFuLbu0qxhIT6Kmu5tbHBM'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  // for checking if user exists or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  // for adding an chat user for our conversation
  static Future<bool> addChatUser(String email) async {
    final data = await firestore
        .collection('users')
        .where('email', isEqualTo: email.trim())
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  // for getting current user info
  static Future<void> getSelfInfo() async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessagingToken();

        //for setting user status to active
        APIs.updateActiveStatus(true);
        print('My Data: ${user.data()}');
        await CommunityGroupHelperFunctions.saveUserToPref(me);
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  // for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    String firstName = user.displayName.toString().split(" ")[0];
    String lastName = user.displayName.toString().split(" ")[1];

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using We Chat!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        firstName: firstName,
        lastName: lastName,
        groups: [],
        level: 'user',
        phoneNo: user.phoneNumber.toString(),
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  // for getting id's of known users from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getMyUsersId() {
    return firestore
        .collection('users')
        .doc(user.uid)
        .collection('my_users')
        .snapshots();
  }

  // for getting all users from firestore database
  // static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
  //     List<String> userIds) {
  //   log('\nUserIds: $userIds');

  //   return firestore
  //       .collection('users')
  //       .where('id',
  //           whereIn: userIds.isEmpty
  //               ? ['']
  //               : userIds) //because empty list throws an error
  //       // .where('id', isNotEqualTo: user.uid)
  //       .snapshots();
  // }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers(
      List<String> userIds) {
    return FirebaseFirestore.instance
        .collection('users')
        .where('id',
            whereIn: userIds.isEmpty
                ? ['']
                : userIds) //because empty list throws an error
        // .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  // for adding an user to my user when first message is send
  static Future<void> sendFirstMessage(
      ChatUser chatUser, String msg, Type type) async {
    await firestore
        .collection('users')
        .doc(chatUser.id)
        .collection('my_users')
        .doc(user.uid)
        .set({}).then((value) => sendMessage(chatUser, msg, type));
  }

  // for updating user information
  static Future<void> updateUserInfo() async {
    await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // update profile picture of user
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'image': me.image})
        .then((value) => () {
              log('Profile Picture Updated');
              Get.snackbar(
                "Success",
                "Profile Picture Updated",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
              );
            })
        .onError((error, stackTrace) => () {
              log('Profile Picture Update Failed');
              Get.snackbar(
                "Failed",
                "Profile Picture Update Failed",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
              );
            });
  }

  // update profile picture of user
  static Future<void> updateGroupProfilePicture(
      File file, String groupID) async {
    Get.snackbar(
      "Updating",
      "Changing Group Profile Picture",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
    );
    //getting image file extension
    final ext = file.path.split('.').last;
    log('Extension: $ext');

    //storage file ref with path
    final ref = storage.ref().child('group_profile_pictures/${user.uid}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('groups')
        .doc(groupID)
        .update({'groupIcon': me.image})
        .then((value) => () {
              log('Profile Picture Updated');
              Get.snackbar(
                "Success",
                "Profile Picture Updated",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
              );
            })
        .onError((error, stackTrace) => () {
              log('Profile Picture Update Failed');
              Get.snackbar(
                "Failed",
                "Profile Picture Update Failed",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
              );
            });
    Get.snackbar(
      "Success",
      "Profile Picture Updated",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
    );
    //Get.back();
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  ///************** Chat Screen Related APIs **************

  // chats (collection) --> conversation_id (doc) --> messages (collection) --> message (doc)

  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  // for getting all messages of a specific conversation from firestore database
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  // for sending message
  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    //message sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);

    final ref = firestore
        .collection('chats/${getConversationID(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  //update read status of message
  static Future<void> updateMessageReadStatus(Message message) async {
    firestore
        .collection('chats/${getConversationID(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  //send chat image
  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConversationID(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await storage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updatedMsg) async {
    await firestore
        .collection('chats/${getConversationID(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updatedMsg});
  }

  static Future<void> updateGroupPurpose(
      String groupPurpose, String groupId) async {
    await firestore
        .collection('groups')
        .doc(groupId)
        .update({'groupPurpose': groupPurpose}).then((value) => () {
              //show snackbar
              Get.snackbar(
                "Success",
                "Group Purpose Updated",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
              );
            });
  }

  static Future<void> updateGroupName(
      String groupName, String groupId, String oldgroupName) async {
    //print group id
    print("Group id for group name change : $groupId");
    await firestore
        .collection('groups')
        .doc(groupId)
        .update({'groupName': groupName}).then((value) => () {
              print("Group name updated");
            });

//update collection users
    await firestore
        .collection('users')
        .where('groups', arrayContains: "${groupId}_$oldgroupName")
        .get()
        .then((value) => value.docs.forEach((element) {
              firestore.collection('users').doc(element.id).update({
                'groups': FieldValue.arrayRemove(["${groupId}_$oldgroupName"])
              });
              firestore.collection('users').doc(element.id).update({
                'groups': FieldValue.arrayUnion(["${groupId}_$groupName"])
              });
            }));
    //show snackbar
    Get.snackbar(
      "Success",
      "Group Name Updated",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
    );
  }

  static removeMember(String groupId, data, String groupName) async {
    String userId = data.substring(0, data.indexOf("_"));
    print(" User Id = $userId");
    await firestore.collection('groups').doc(groupId).update({
      'members': FieldValue.arrayRemove([data])
    });
    await firestore.collection('users').doc(userId).update({
      'groups': FieldValue.arrayRemove(["${groupId}_$groupName"])
    }).then((value) => () {
          Get.snackbar(
            "Success",
            "Member Removed",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
          );
        });
  }

  static Future<void> deleteGroup(String groupId, String groupName) async {
    await firestore
        .collection('users')
        .where('groups', arrayContains: "${groupId}_$groupName")
        .get()
        .then(
          (value) => value.docs.forEach(
            (element) {
              print(" Element ID  ${element.id}");
              if (element.data().containsKey('groups')) {
                firestore.collection('users').doc(element.id).update({
                  'groups': FieldValue.arrayRemove(["${groupId}_$groupName"])
                });
              }
            },
          ),
        );

    await firestore.collection('groups').doc(groupId).delete();
    Get.snackbar(
      "Success",
      "Club Deleted",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
    );
    print("Done removing all users");

    //toast
  }
}
