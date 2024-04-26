import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedbackListScreen extends StatefulWidget {
  const FeedbackListScreen({super.key});

  @override
  State<FeedbackListScreen> createState() => _FeedbackListScreenState();
}

class _FeedbackListScreenState extends State<FeedbackListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedbacks'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('feedback')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final feedback = snapshot.data!.docs[index];

              return Card(
                child: ListTile(
                  title: Text(feedback['feedback']),
                  subtitle: Text(
                      'Submitted on ${feedback['timestamp'].toDate().toString()}'),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      await showDeleteDialog(feedback.id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

// New method
  Future _deleteFeedback(String id) async {
    await FirebaseFirestore.instance.collection('feedback').doc(id).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback deleted')),
    );

    // Refresh UI
    setState(() {});
  }

  Future showDeleteDialog(String id) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this feedback?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _deleteFeedback(id);
                  },
                  child: const Text('Delete'))
            ],
          );
        });
  }
}
