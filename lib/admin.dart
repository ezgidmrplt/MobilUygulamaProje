import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController groupNameController = TextEditingController();
  final List<TextEditingController> taskControllers = List.generate(
    3,
    (index) => TextEditingController(),
  );
  final TextEditingController announcementController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final DateFormat dateFormat = DateFormat('dd.MM.yyyy');

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "WorkAgenda Admin Panel",
            style: GoogleFonts.lobster(
              textStyle: TextStyle(fontSize: 24, color: Colors.white),
            ),
          ),
        ),
        backgroundColor: Colors.blue.shade900,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade900),
              child: Center(
                child: Text(
                  "Admin Menu",
                  style: GoogleFonts.lobster(
                    textStyle: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
              ),
            ),
            ListTile(
              title: Text(
                "Duyuru Ekle",
                style: GoogleFonts.lobster(
                  textStyle: TextStyle(color: Colors.blue.shade900),
                ),
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Text("Yeni Duyuru Ekle"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: announcementController,
                            decoration: InputDecoration(labelText: "Duyuru"),
                          ),
                          TextField(
                            controller: notesController,
                            decoration: InputDecoration(labelText: "Toplantı Notları"),
                          ),
                          Row(
                            children: [
                              Text("Tarih: ${dateFormat.format(selectedDate)}"),
                              IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: () => _selectDate(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            FirebaseFirestore.instance.collection('notes').add({
                              'duyurular': announcementController.text,
                              'tarih': dateFormat.format(selectedDate),
                              'toplantiNotlari': notesController.text,
                            });
                            announcementController.clear();
                            notesController.clear();
                            Navigator.of(context).pop();
                          },
                          child: Text("Ekle"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("İptal"),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('notes').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
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
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('notes')
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
      body: Container(
        color: Colors.blue.shade50,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: groupNameController,
              decoration: InputDecoration(
                labelText: "Grup İsmi",
                labelStyle: GoogleFonts.lobster(
                  textStyle: TextStyle(color: Colors.blue.shade900),
                ),
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade900),
                ),
              ),
            ),
            SizedBox(height: 10),
            for (int i = 0; i < taskControllers.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextField(
                  controller: taskControllers[i],
                  decoration: InputDecoration(
                    labelText: "Görev ${i + 1}",
                    labelStyle: GoogleFonts.lobster(
                      textStyle: TextStyle(color: Colors.blue.shade900),
                    ),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade900),
                    ),
                  ),
                ),
              ),
            Row(
              children: [
                Text(
                  "Teslim Tarihi: ${dateFormat.format(selectedDate)}",
                  style: GoogleFonts.lobster(
                    textStyle: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.blue.shade900),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(groupNameController.text)
                    .set({
                  'tasks': FieldValue.arrayUnion(taskControllers.map((e) => e.text).toList()),
                  'deliveryDate': dateFormat.format(selectedDate),
                  'isCompleted': false,
                }, SetOptions(merge: true));
              },
              child: Text(
                "Grup Görev Oluştur",
                style: GoogleFonts.lobster(
                  textStyle: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('tasks').snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return ListView(
                    children: snapshot.data!.docs.map((doc) {
                      List tasks = doc['tasks'];
                      String deliveryDate = doc['deliveryDate'];
                      return Card(
                        color: Colors.blue.shade100,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ExpansionTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Grup: ${doc.id}",
                                style: GoogleFonts.lobster(
                                  textStyle: TextStyle(
                                    color: Colors.blue.shade900,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('tasks')
                                      .doc(doc.id)
                                      .delete();
                                },
                              ),
                            ],
                          ),
                          children: [
                            ...tasks.map<Widget>((task) {
                              return ListTile(
                                title: Text(
                                  task,
                                  style: GoogleFonts.lobster(
                                    textStyle: TextStyle(color: Colors.blue.shade900),
                                  ),
                                ),
                                subtitle: Text(
                                  "Delivery Date: $deliveryDate",
                                  style: TextStyle(color: Colors.black54),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('tasks')
                                        .doc(doc.id)
                                        .update({
                                      'tasks': FieldValue.arrayRemove([task]),
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
          ],
        ),
      ),
    );
  }
}
