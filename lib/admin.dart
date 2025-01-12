import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminScreen extends StatelessWidget {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Panel"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: groupNameController,
              decoration: InputDecoration(labelText: "Group Name"),
            ),
            TextField(
              controller: taskController,
              decoration: InputDecoration(labelText: "Task"),
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance.collection('tasks').add({
                  'task': taskController.text,
                  'deliveryDate': DateTime.now(),
                  'isCompleted': false,
                });
              },
              child: Text("Add Task"),
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return ListTile(
                        title: Text(doc['task']),
                        subtitle: Text(doc['deliveryDate'].toDate().toString()),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('tasks')
                                .doc(doc.id)
                                .delete();
                          },
                        ),
                      );
                    }).toList(),
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
