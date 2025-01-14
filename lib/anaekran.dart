import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return CircularProgressIndicator();
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                List tasks = doc['tasks'];
                Timestamp deliveryDate = doc['deliveryDate'];
                DateTime date = deliveryDate.toDate();
                return ExpansionTile(
                  title: Text("Group: ${doc.id}"),
                  children: [
                    ...tasks.map<Widget>((task) {
                      return ListTile(
                        title: Text(task),
                        subtitle: Text("Delivery Date: ${date.toLocal()}"), // Teslim tarihi
                      );
                    }).toList(),
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
