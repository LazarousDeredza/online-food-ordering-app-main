import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DatabaseServicetest {
  final String? uid;
  DatabaseServicetest({this.uid});

  // reference for our collections
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");
  final CollectionReference groupToBeApprovedCollection =
      FirebaseFirestore.instance.collection("groupstoBeApproved");

  final _db = FirebaseFirestore.instance;

  TextEditingController introducingController = TextEditingController();
  TextEditingController reasonController = TextEditingController();

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
  Future createGroup(String userName, String id, String groupName,
      String groupPurpose, String targetAudience, bool isAdmin) async {
    if (isAdmin) {
      DocumentReference groupDocumentReference = await groupCollection.add({
        "groupName": groupName,
        "groupIcon": "",
        "admin": "${id}_$userName",
        "createdBy": userName,
        "members": [],
        "unapprovedmembers": [],
        "groupPurpose": groupPurpose,
        "dateCreated": DateTime.now().toString(),
        "targetAudience": targetAudience,
        "approvalStatus": "approved",
        "approvedBy": userName,
        "groupId": "",
        "recentMessage": "",
        "recentMessageSender": "",
      });
      // update the members
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${id}_$userName"]),
        "groupId": groupDocumentReference.id,
      });

      DocumentReference userDocumentReference = userCollection.doc(uid);
      return await userDocumentReference.update({
        "groups":
            FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
      }).then((value) => {
            Get.snackbar("Sucess", "Club created successfully",
                snackPosition: SnackPosition.BOTTOM)
          });
    } else {
      DocumentReference groupDocumentReference =
          await groupToBeApprovedCollection.add({
        "groupName": groupName,
        "groupIcon": "",
        "admin": "${id}_$userName",
        "createdBy": userName,
        "dateCreated": DateTime.now().toString(),
        "members": [],
        "unapprovedmembers": [],
        "approvalStatus": "pending",
        "approvedBy": "",
        "groupPurpose": groupPurpose,
        "targetAudience": targetAudience,
        "groupId": "",
        "recentMessage": "",
        "recentMessageSender": "",
      });
      // update the members
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${id}_$userName"]),
        "groupId": groupDocumentReference.id,
      }).then((value) => {
            Get.snackbar(
                "Sucess",
                duration: const Duration(seconds: 7),
                "Club submited for approval to admins, Once approved it will be created and visible to all users",
                snackPosition: SnackPosition.BOTTOM)
          });
    }
  }

  Future<void> approveClub(String docID, String approvedBy) async {
    QuerySnapshot snapshot = await groupToBeApprovedCollection
        .where("groupId", isEqualTo: docID)
        .get();

    DocumentSnapshot documentSnapshot = snapshot.docs[0];

    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": documentSnapshot['groupName'],
      "groupIcon": "",
      "admin": documentSnapshot['admin'],
      "createdBy": documentSnapshot['createdBy'],
      "members": [],
      "unapprovedmembers": [],
      "groupPurpose": documentSnapshot['groupPurpose'],
      "dateCreated": DateTime.now().toString(),
      "targetAudience": documentSnapshot['targetAudience'],
      "approvalStatus": "approved",
      "approvedBy": approvedBy,
      "groupId": "",
      "recentMessage": "",
      "recentMessageSender": "",
    });
    // update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion([documentSnapshot['admin']]),
      "groupId": groupDocumentReference.id,
    });

//String admin id from documentSnapshot['admin']
    String adminId = documentSnapshot['admin'].split("_")[0];

    DocumentReference userDocumentReference = userCollection.doc(adminId);
    await userDocumentReference.update({
      "groups": FieldValue.arrayUnion(
          ["${groupDocumentReference.id}_${documentSnapshot['groupName']}"])
    });

    //delete the club from pending
    await groupToBeApprovedCollection.doc(docID).delete();
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

  Future<QuerySnapshot> listOfGrps() {
    return groupCollection.orderBy('groupName').get();
  }

  // function -> bool
  Future<bool> isUserJoined(
      String groupName, String groupId, String userName) async {
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await userDocumentReference.get();

    List<dynamic> groups = await documentSnapshot['groups'];
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
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    }
  }

  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // Get group doc
    DocumentSnapshot groupDoc = await groupDocumentReference.get();
    List<dynamic> unapproved = groupDoc['unapprovedmembers'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      Get.snackbar("Join Failed", "You are already in this club",
          snackPosition: SnackPosition.BOTTOM);
    } else {
//TODO: work o approval

//check if String uid doesnt already exist in "unapprovedmembers": [] on groupDocumentReference

      if (unapproved.any((element) {
        if (element is String) {
          final firstString = element.split('_').first;
          return firstString == uid;
        }
        return false;
      })) {
        // Already pending alert
        Get.snackbar(
          "Notice",
          "You already requested to join this Club !\nPlease be patient for approval from the club admin",
          backgroundColor: Colors.yellow,
          snackPosition: SnackPosition.BOTTOM,
          colorText: Colors.black,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.warning),
        );
      } else {
//put a pop up dialog prompting user to introduce themselves and why they want to join the club

// //show a pop up dialog
//         Get.defaultDialog(
//           title: "Introduce yourself",
//           content: SingleChildScrollView(
//             physics: const BouncingScrollPhysics(),
//             scrollDirection: Axis.vertical,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text("Please introduce yourself"),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: introducingController,
//                   maxLines: 3,
//                   maxLength: 50,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Introduce yourself',
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: reasonController,
//                   maxLength: 60,
//                   maxLines: 4,
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     labelText: 'Why do you want to join this club',
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Get.back();
//               },
//               child: Text("Cancel"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 if (introducingController.text.isEmpty ||
//                     reasonController.text.isEmpty) {
//                   Get.snackbar("Warning",
//                       "Fill in all details for your request to be sent",
//                       backgroundColor: Colors.yellow,
//                       snackPosition: SnackPosition.TOP,
//                       colorText: Colors.black,
//                       duration: Duration(seconds: 4),
//                       icon: Icon(Icons.warning));
//                 } else {
//                   Get.back();
//                   // Add to unapproved list
//                   await groupCollection.doc(groupId).update({
//                     'unapprovedmembers': FieldValue.arrayUnion([
//                       uid! +
//                           "_" +
//                           userName +
//                           "_" +
//                           introducingController.text +
//                           "_" +
//                           reasonController.text
//                     ])
//                   });

//                   Get.snackbar(
//                     "Success",
//                     "Your requested to join this Club has been Sucessfully sent to the admin !\nOnce accepted you will be joined automatically",
//                     backgroundColor: Colors.green,
//                     colorText: Colors.black,
//                     snackPosition: SnackPosition.BOTTOM,
//                     duration: Duration(seconds: 5),
//                     icon: Icon(Icons.check),
//                   );
//                 }
//               },
//               child: Text("Send"),
//             ),
//           ],
//         );

        Get.defaultDialog(
          title: "Introduce yourself",
          content: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: introducingController,
                  maxLines: 2,
                  maxLength: 60,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Introduce yourself',
                  ),
                ),
                TextField(
                  controller: reasonController,
                  maxLength: 80,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Why do you want to join this club',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (introducingController.text.isEmpty ||
                    reasonController.text.isEmpty) {
                  Get.snackbar(
                    "Warning",
                    "Fill in all details for your request to be sent",
                    backgroundColor: Colors.yellow,
                    snackPosition: SnackPosition.TOP,
                    colorText: Colors.black,
                    duration: const Duration(seconds: 4),
                    icon: const Icon(Icons.warning),
                  );
                } else {
                  Get.back();
                  // Add to unapproved list
                  await groupCollection.doc(groupId).update({
                    'unapprovedmembers': FieldValue.arrayUnion([
                      "${uid!}_${userName}_${introducingController.text}_${reasonController.text}"
                    ])
                  });

                  Get.snackbar(
                    "Success",
                    "Your request to join this Club has been successfully sent to the admin! Once accepted, you will be joined automatically.",
                    backgroundColor: Colors.green,
                    colorText: Colors.black,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 5),
                    icon: const Icon(Icons.check),
                  );
                }
              },
              child: const Text("Send"),
            ),
          ],
        );
      }

      // Get.snackbar("Successfully joined $groupName", "",
      //     backgroundColor: Colors.green[100],
      //     snackPosition: SnackPosition.BOTTOM);

      // await userDocumentReference.update({
      //   "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      // });
      // await groupDocumentReference.update({
      //   "members": FieldValue.arrayUnion(["${uid}_$userName"])
      // });

      // Future.delayed(const Duration(seconds: 2), () {
      //   Get.to(
      //     () => ChatPagetest(
      //       groupId: groupId,
      //       groupName: groupName,
      //       userName: userName,
      //     ),
      //   );
      // });
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

  Future<void> removeUnApprovedMember(
      String groupId, data, String groupName) async {
    //delete from firestore groupCollection.groupId  on unapprovedmembers which matches data

    // Get reference to group doc
    DocumentReference docRef = groupCollection.doc(groupId);

    // Remove from array
    await docRef.update({
      "unapprovedmembers": FieldValue.arrayRemove([data])
    }).then((value) {
      Get.snackbar("Success", "Request Deleted Successfully",
          icon: const Icon(
            Icons.delete,
            color: Colors.red,
          ));
    });
  }

  Future<void> addGroupMemberFromUnApprovedList(
      String groupId, data, String groupName) async {
    String userID = data.substring(0, data.indexOf("_"));
    // Get reference to group doc
    DocumentReference docRef = groupCollection.doc(groupId);

    DocumentReference userRef = userCollection.doc(userID);

    await userRef.update({
      "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
    });

    String username = data.split("_")[1];

    // Remove from array
    await docRef.update({
      "unapprovedmembers": FieldValue.arrayRemove([data])
    }).then((value) {
      // Add to members array
      docRef.update({
        "members": FieldValue.arrayUnion(["${userID}_${username.trim()}"])
      }).then((value) {
        Get.snackbar("Success", "Request Approved Successfully",
            icon: const Icon(
              Icons.check,
              color: Colors.green,
            ));
      });
    });
  }
}
