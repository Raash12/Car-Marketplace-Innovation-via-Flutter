import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackReportPage extends StatefulWidget {
  const FeedbackReportPage({super.key});

  @override
  State<FeedbackReportPage> createState() => _FeedbackReportPageState();
}

class _FeedbackReportPageState extends State<FeedbackReportPage> {
  final CollectionReference feedbackCollection =
      FirebaseFirestore.instance.collection('feedback');

  Future<void> markAsRead(String docId) async {
    await feedbackCollection.doc(docId).update({'isRead': true});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Feedback'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: feedbackCollection.orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load feedback.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No feedback found.'));
          }

          return ListView.separated(
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data()! as Map<String, dynamic>;
              final isRead = data['isRead'] ?? false;
              final message = data['message'] ?? '';
              final name = data['name'] ?? 'Anonymous';
              final timestamp = data['createdAt'] as Timestamp?;
              final date = timestamp?.toDate() ?? DateTime.now();

              return ListTile(
                title: Text(
                  message,
                  style: TextStyle(
                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                    color: isRead ? Colors.grey : Colors.black,
                  ),
                ),
                subtitle: Text('$name - ${date.toLocal()}'.split('.')[0]),
                trailing: isRead
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.mark_email_read, color: Colors.green),
                        tooltip: 'Mark as Read',
                        onPressed: () => markAsRead(doc.id),
                      ),
                onTap: () {
                  if (!isRead) {
                    markAsRead(doc.id);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
