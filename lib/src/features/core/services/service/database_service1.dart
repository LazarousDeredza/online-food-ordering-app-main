import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("instGroups");
  final _db = FirebaseFirestore.instance;

  // saving the userdata
  Future savingUserData(String fullName, String email) async {
    return await userCollection.doc(uid).set({
      "name": fullName,
      "email": email,
      "groups": [],
      "image": "",
      "id": uid,
    });
  }

  Future<QuerySnapshot> listOfGrps() {
    return groupCollection.orderBy('groupName').get();
  }

  // getting user data
  Future gettingUserData(String email) async {
    QuerySnapshot snapshot =
        await userCollection.where("email", isEqualTo: email).get();
    return snapshot;
  }

  // get user groups
  getUserGroups() async {
    return userCollection.doc(uid).snapshots();
  }

  // creating a group
  Future<bool> createGroup(
      String userName, String id, String groupName, String institution) async {
    //check if group with institution exists

    bool groupCreated = false;

    QuerySnapshot querySnapshot = await groupCollection
        .where("institution", isEqualTo: institution)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      // A group with the provided institution already exists
      groupCreated = false;
      return groupCreated;
    } else {
      DocumentReference groupDocumentReference = await groupCollection.add({
        "groupName": groupName,
        "groupIcon": "",
        "admin": "${id}_$userName",
        "members": [],
        "groupId": "",
        "institution": institution,
        "recentMessage": "",
        "recentMessageSender": "",
      });
      // update the members
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${id}_$userName"]),
        "groupId": groupDocumentReference.id,
      });

      DocumentReference userDocumentReference = userCollection.doc(uid);
      await userDocumentReference.update({
        "instGroups":
            FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
      });

      groupCreated = true;
    }

    return groupCreated;
  }

  // getting the chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  // get group members
  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // search
  // searchByName(String groupName) {
  //   return groupCollection.where("groupName", arrayContains: groupName).get();
  // }

  searchByName(String groupName) {
    String searchTerm = groupName.toLowerCase();
    return groupCollection
        .where('groupName', isGreaterThanOrEqualTo: searchTerm)
        .where('groupName', isLessThanOrEqualTo: '$searchTerm\uf8ff')
        .get();
  }

  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['instGroups'];
    if (groups.contains("${groupId}_$groupName")) {
      return true;
    } else {
      return false;
    }
  }

  // toggling the group join/exit
  Future toggleGroupExit(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['instGroups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "instGroups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    }
  }

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }
}
