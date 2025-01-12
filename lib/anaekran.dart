import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['task']),
                subtitle: Text(doc['deliveryDate'].toDate().toString()),
                trailing: Icon(
                  doc['isCompleted'] ? Icons.check_circle : Icons.circle_outlined,
                  color: doc['isCompleted'] ? Colors.green : Colors.red,
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
