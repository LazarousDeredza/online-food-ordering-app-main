import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:online_food_delivery_app/src/features/core/screens/data_screen/model_document.dart';

class DocumentCommentsScreen extends StatefulWidget {
  final String id;

  const DocumentCommentsScreen({super.key, required this.id});

  @override
  State<DocumentCommentsScreen> createState() => _DocumentCommentsScreenState();
}

class _DocumentCommentsScreenState extends State<DocumentCommentsScreen> {
  final _commentController = TextEditingController();

  late String? userId;

  @override
  void initState() {
    super.initState();

    //initiate the user id from firebase
    userId = FirebaseAuth.instance.currentUser!.uid;
  }

  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      //fetch firebase doc id comments
      body: Container(
        child: Column(
          children: [
//add a text field to add comments and a button to submit
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: 'Add a comment',
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
            ),
            //show a list of comments from firebase where case id is equal to the case id of the case being viewed and approved is equal to yes
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('document_comments')
                  .where('docID', isEqualTo: widget.id)
                  .where('approved', isEqualTo: 'Yes')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text('No Comments available'));
                }

                final comments = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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
                            padding: const EdgeInsets.only(left: 15.0, right: 10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(comments[index]['comment']),
                                ),
                                const SizedBox(height: 5.0),
                                Row(
                                  children: [
                                    //like icon
                                    GestureDetector(
                                      onTap: () {
                                        //update the likes field in firebase

                                        LikeAndDislike likeAndDilike =
                                            LikeAndDislike(
                                                docID: widget.id,
                                                userID: userId,
                                                date:
                                                    DateTime.now().toString());

                                        //check if the user has already liked the comment
                                        FirebaseFirestore.instance
                                            .collection('document_comments')
                                            .doc(comments[index].id)
                                            .collection('likes')
                                            .where('userID', isEqualTo: userId)
                                            .get()
                                            .then((value) => {
                                                  if (value.docs.isEmpty)
                                                    {
                                                      //check if i had disliked the comment before and remove it ,and deduct the number of dislikes by 1
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'document_comments')
                                                          .doc(comments[index]
                                                              .id)
                                                          .collection(
                                                              'dislikes')
                                                          .where('userID',
                                                              isEqualTo: userId)
                                                          .get()
                                                          .then((value) => {
                                                                if (value.docs
                                                                    .isNotEmpty)
                                                                  {
                                                                    //remove the user from the dislikes collection
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'document_comments')
                                                                        .doc(comments[index]
                                                                            .id)
                                                                        .collection(
                                                                            'dislikes')
                                                                        .doc(value
                                                                            .docs
                                                                            .first
                                                                            .id)
                                                                        .delete()
                                                                        .then((value) =>
                                                                            {
                                                                              //update the dislikes field in the comments collection
                                                                              FirebaseFirestore.instance.collection('document_comments').doc(comments[index].id).update({
                                                                                'numberOfDislikes': comments[index]['numberOfDislikes'] - 1
                                                                              })
                                                                            })
                                                                  }
                                                              }),

                                                      //add the user to the likes collection
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'document_comments')
                                                          .doc(comments[index]
                                                              .id)
                                                          .collection('likes')
                                                          .add(likeAndDilike
                                                              .toJson())
                                                          .then((value) => {
                                                                //update the likes field in the comments collection
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'document_comments')
                                                                    .doc(comments[
                                                                            index]
                                                                        .id)
                                                                    .update({
                                                                  'numberOfLikes':
                                                                      comments[index]
                                                                              [
                                                                              'numberOfLikes'] +
                                                                          1
                                                                }).then(
                                                                        (value) =>
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
                                                      ScaffoldMessenger.of(
                                                              context)
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
                                        padding: const EdgeInsets.all(6.0),
                                        child: Text(
                                            '${comments[index]['numberOfLikes']}')),
                                    const SizedBox(width: 40.0),
                                    //dislike icon
                                    GestureDetector(
                                      onTap: () {
                                        //update the likes field in firebase

                                        LikeAndDislike likeAndDilike =
                                            LikeAndDislike(
                                                id: widget.id,
                                                userID: userId,
                                                date:
                                                    DateTime.now().toString());

                                        //check if the user has already disliked the comment
                                        FirebaseFirestore.instance
                                            .collection('document_comments')
                                            .doc(comments[index].id)
                                            .collection('dislikes')
                                            .where('userID', isEqualTo: userId)
                                            .get()
                                            .then((value) => {
                                                  if (value.docs.isEmpty)
                                                    {
                                                      //check if i had liked the comment before and remove it ,and deduct the number of likes by 1
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'document_comments')
                                                          .doc(comments[index]
                                                              .id)
                                                          .collection('likes')
                                                          .where('userID',
                                                              isEqualTo: userId)
                                                          .get()
                                                          .then((value) => {
                                                                if (value.docs
                                                                    .isNotEmpty)
                                                                  {
                                                                    //remove the user from the likes collection
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'document_comments')
                                                                        .doc(comments[index]
                                                                            .id)
                                                                        .collection(
                                                                            'likes')
                                                                        .doc(value
                                                                            .docs
                                                                            .first
                                                                            .id)
                                                                        .delete()
                                                                        .then((value) =>
                                                                            {
                                                                              //update the likes field in the comments collection
                                                                              FirebaseFirestore.instance.collection('document_comments').doc(comments[index].id).update({
                                                                                'numberOfLikes': comments[index]['numberOfLikes'] - 1
                                                                              })
                                                                            })
                                                                  }
                                                              }),

                                                      //add the user to the dislikes collection
                                                      FirebaseFirestore.instance
                                                          .collection(
                                                              'document_comments')
                                                          .doc(comments[index]
                                                              .id)
                                                          .collection(
                                                              'dislikes')
                                                          .add(likeAndDilike
                                                              .toJson())
                                                          .then((value) => {
                                                                //update the dislikes field in the comments collection
                                                                FirebaseFirestore
                                                                    .instance
                                                                    .collection(
                                                                        'document_comments')
                                                                    .doc(comments[
                                                                            index]
                                                                        .id)
                                                                    .update({
                                                                  'numberOfDislikes':
                                                                      comments[index]
                                                                              [
                                                                              'numberOfDislikes'] +
                                                                          1
                                                                }).then(
                                                                        (value) =>
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
                                                      ScaffoldMessenger.of(
                                                              context)
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
                          padding: EdgeInsets.only(left: 20.0, right: 20.0),
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
  }

  void submitComment() {
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

    DocumentComment comment = DocumentComment(
        comment: _commentController.text,
        docID: widget.id,
        userID: userId,
        date: DateTime.now().toString(),
        numberOfDislikes: 0,
        numberOfLikes: 0,
        approved: "No");

    FirebaseFirestore.instance
        .collection('document_comments')
        .add(comment.toJson())
        .then((value) => {
              //clear the text field
              _commentController.clear(),
              //toast message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comment added successfully'),
                ),
              ),

              setState(() {
                isSaving = false;
              }),

              //show a list of comments

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DocumentCommentsScreen(
                    id: widget.id,
                  ),
                ),
              )
            });
  }
}
