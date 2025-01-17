import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "WorkAgenda Home",
            style: TextStyle(
              fontFamily: 'Lobster',
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Color(0xFF1A237E),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                List tasks = List.from(doc['tasks']);
                Timestamp deliveryDate = doc['deliveryDate'];
                DateTime date = deliveryDate.toDate();

                return tasks.isEmpty
                    ? FutureBuilder(
                        future: FirebaseFirestore.instance.collection('tasks').doc(doc.id).delete(),
                        builder: (context, snapshot) {
                          return SizedBox.shrink(); // Grup boşsa görünmez hale getir
                        },
                      )
                    : Card(
                        color: Color(0xFFE3F2FD),
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ExpansionTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Grup: ${doc.id}",
                                style: TextStyle(
                                  fontFamily: 'Lobster',
                                  fontSize: 20,
                                  color: Color(0xFF1A237E),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                "Delivery Date: ${date.toLocal().toString().split(' ')[0]}",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          children: [
                            ...tasks.asMap().entries.map<Widget>((entry) {
                              int index = entry.key;
                              String task = entry.value;
                              return ListTile(
                                title: Text(
                                  task,
                                  style: TextStyle(
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.check, color: Colors.green),
                                  onPressed: () {
                                    tasks.removeAt(index);
                                    FirebaseFirestore.instance.collection('tasks').doc(doc.id).update({
                                      'tasks': tasks,
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
