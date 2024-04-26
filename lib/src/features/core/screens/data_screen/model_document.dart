import 'package:cloud_firestore/cloud_firestore.dart';

//create class comment model with the following fields : comment, likes, approved,date

class DocumentComment {
  final String? id;
  final String? comment;
  final int? numberOfLikes;
  final int? numberOfDislikes;

  final String? approved;
  final String? date;
  final String? docID;
  final String? userID;

  DocumentComment(
      {this.id,
      this.comment,
      this.numberOfLikes,
      this.numberOfDislikes,
      this.approved,
      this.date,
      this.docID,
      this.userID});

  //to json
  Map<String, dynamic> toJson() => {
        'id': id,
        'comment': comment,
        'numberOfLikes': numberOfLikes,
        'numberOfDislikes': numberOfDislikes,
        'approved': approved,
        'date': date,
        'docID': docID,
        'userID': userID,
      };

  //from json
  factory DocumentComment.fromJson(Map<String, dynamic> json) =>
      DocumentComment(
        id: json['id'],
        comment: json['comment'],
        numberOfLikes: json['numberOfLikes'],
        numberOfDislikes: json['numberOfDislikes'],
        approved: json['approved'],
        date: json['date'],
        docID: json['docID'],
        userID: json['userID'],
      );

  factory DocumentComment.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return DocumentComment(
      id: document.id,
      comment: data['comment'],
      numberOfLikes: data['numberOfLikes'],
      numberOfDislikes: data['numberOfDislikes'],
      approved: data['approved'],
      date: data['date'],
      docID: data['docID'],
      userID: data['userID'],
    );
  }
}

class LikeAndDislike {
  final String? id;
  final String? docID;
  final String? userID;
  final String? date;

  LikeAndDislike({this.id, this.docID, this.userID, this.date});

  //to json
  Map<String, dynamic> toJson() => {
        'id': id,
        'docID': docID,
        'userID': userID,
        'date': date,
      };

  //from json
  factory LikeAndDislike.fromJson(Map<String, dynamic> json) => LikeAndDislike(
        id: json['id'],
        docID: json['docID'],
        userID: json['userID'],
        date: json['date'],
      );

  factory LikeAndDislike.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return LikeAndDislike(
      id: document.id,
      docID: data['docID'],
      userID: data['userID'],
      date: data['date'],
    );
  }
}
