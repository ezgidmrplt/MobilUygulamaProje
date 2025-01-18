import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class Anaekran extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  image: AssetImage('assets/logogibi.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
              ),
              child: Center(
                child: Text(
                  "Duyurular",
                  style: TextStyle(
                    color: Color(0xFF1A237E),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lobster',
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Duyurular",
                style: TextStyle(color: Color(0xFF1A237E), fontFamily: 'Lobster'),
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
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        child: Card(
                          color: Color(0xFFF5F5F5),
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(16),
                            title: Text(
                              "Duyuru: ${doc['duyurular']}",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A237E),
                                fontFamily: 'Lobster',
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 8),
                                Text(
                                  "Tarih: ${doc['tarih']}",
                                  style: TextStyle(color: Colors.black54, fontSize: 14, fontFamily: 'Lobster'),
                                ),
                                Text(
                                  "Toplantı Notları: ${doc['toplantiNotlari']}",
                                  style: TextStyle(color: Colors.black54, fontSize: 14, fontFamily: 'Lobster'),
                                ),
                              ],
                            ),
                          ),
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
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/anasayfa3.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Builder(
              builder: (BuildContext context) {
                return IconButton(
                  icon: Icon(Icons.menu, color: Colors.blueAccent),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(top: 20),
                  child: Text(
                    "WorkAgenda",
                    style: GoogleFonts.lobster(
                      fontSize: 46,
                      color: Color(0xFF1A237E)                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          List tasks = List.from(doc['tasks']);
                          String deliveryDate = doc['deliveryDate'];

                          return tasks.isEmpty
                              ? FutureBuilder(
                                  future: FirebaseFirestore.instance.collection('tasks').doc(doc.id).delete(),
                                  builder: (context, snapshot) {
                                    return SizedBox.shrink();
                                  },
                                )
                              : Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                  child: Card(
                                    color: Color(0xFFF5F5F5),
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ExpansionTile(
                                      title: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Grup: ${doc.id}",
                                            style: TextStyle(
                                              fontFamily: 'Lobster',
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1A237E),
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            "Teslim Tarihi: $deliveryDate",
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14,
                                              fontFamily: 'Lobster',
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
                                                fontFamily: 'Lobster',
                                              ),
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(Icons.check, color: Colors.blue),
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
        ],
      ),
    );
  }
}
