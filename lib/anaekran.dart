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
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF1A237E)),
              child: Center(
                child: Text(
                  "Admin Menu",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Duyurular",
                style: TextStyle(color: Color(0xFF1A237E)),
              ),
              onTap: () {},
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('notes').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      return ListTile(
                        title: Text("Duyuru: ${doc['duyurular']}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Tarih: ${doc['tarih']}"),
                            Text("Toplantı Notları: ${doc['toplantiNotlari']}"),
                          ],
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                List tasks = List.from(doc['tasks']);
                String deliveryDate = doc['deliveryDate']; // Tarih string olarak alınır

                return tasks.isEmpty
                    ? FutureBuilder(
                        future: FirebaseFirestore.instance.collection('tasks').doc(doc.id).delete(),
                        builder: (context, snapshot) {
                          return SizedBox.shrink(); // Grup boşsa görünmez hale gelir
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
                                "Teslim Tarihi: $deliveryDate", // String tarih burada gösterilir
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
