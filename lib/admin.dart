import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AdminEkrani extends StatefulWidget {
  @override
  _AdminPaneliState createState() => _AdminPaneliState();
}

class _AdminPaneliState extends State<AdminEkrani> {
  final TextEditingController grupIsmiKontrol = TextEditingController();
  final List<TextEditingController> gorevKontrolleri = List.generate(
    3,
    (index) => TextEditingController(),
  );
  final TextEditingController duyuruKontrol = TextEditingController();
  final TextEditingController notlarKontrol = TextEditingController();
  DateTime secilenTarih = DateTime.now();
  final DateFormat tarihFormat = DateFormat('dd.MM.yyyy');

  Future<void> _tarihSec(BuildContext context) async {
    final DateTime? secilen = await showDatePicker(
      context: context,
      initialDate: secilenTarih,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (secilen != null && secilen != secilenTarih) {
      setState(() {
        secilenTarih = secilen;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "Admin Yönetici Paneli",
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
                  "Yönetici Menüsü",
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
                      title: Text(
                        "Yeni Duyuru Ekle",
                        style: GoogleFonts.lobster(),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: duyuruKontrol,
                            decoration: InputDecoration(
                              labelText: "Duyuru",
                              labelStyle: GoogleFonts.lobster(),
                            ),
                          ),
                          TextField(
                            controller: notlarKontrol,
                            decoration: InputDecoration(
                              labelText: "Toplantı Notları",
                              labelStyle: GoogleFonts.lobster(),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Tarih: ${tarihFormat.format(secilenTarih)}",
                                style: GoogleFonts.lobster(),
                              ),
                              IconButton(
                                icon: Icon(Icons.calendar_today),
                                onPressed: () => _tarihSec(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            FirebaseFirestore.instance.collection('notes').add({
                              'duyurular': duyuruKontrol.text,
                              'tarih': tarihFormat.format(secilenTarih),
                              'toplantiNotlari': notlarKontrol.text,
                            });
                            duyuruKontrol.clear();
                            notlarKontrol.clear();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Ekle",
                            style: GoogleFonts.lobster(),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "İptal",
                            style: GoogleFonts.lobster(),
                          ),
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
                        title: Text(
                          "Duyuru: ${doc['duyurular']}",
                          style: GoogleFonts.lobster(),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tarih: ${doc['tarih']}",
                              style: GoogleFonts.lobster(),
                            ),
                            Text(
                              "Toplantı Notları: ${doc['toplantiNotlari']}",
                              style: GoogleFonts.lobster(),
                            ),
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
            CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage('assets/admin.png'),
              backgroundColor: Colors.blueAccent,
            ),
            SizedBox(height: 20),
            TextField(
              controller: grupIsmiKontrol,
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
            for (int i = 0; i < gorevKontrolleri.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextField(
                  controller: gorevKontrolleri[i],
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
                  "Teslim Tarihi: ${tarihFormat.format(secilenTarih)}",
                  style: GoogleFonts.lobster(
                    textStyle: TextStyle(color: Colors.blue.shade900),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.blue.shade900),
                  onPressed: () => _tarihSec(context),
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
                FirebaseFirestore.instance.collection('tasks').doc(grupIsmiKontrol.text).set({
                  'tasks': FieldValue.arrayUnion(gorevKontrolleri.map((e) => e.text).toList()),
                  'deliveryDate': tarihFormat.format(secilenTarih),
                  'completed': false,
                }, SetOptions(merge: true));
                grupIsmiKontrol.clear();
                gorevKontrolleri.forEach((controller) => controller.clear());
                setState(() {});
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
                      List tasks = List.from(doc['tasks']);
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
                            ...tasks.asMap().entries.map<Widget>((entry) {
                              int index = entry.key;
                              String task = entry.value;
                              return ListTile(
                                title: Text(
                                  task,
                                  style: GoogleFonts.lobster(
                                    textStyle: TextStyle(color: Colors.blue.shade900),
                                  ),
                                ),
                                subtitle: Text(
                                  "Teslim Tarihi: $deliveryDate",
                                  style: GoogleFonts.lobster(
                                    textStyle: TextStyle(color: Colors.black54),
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
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
          ],
        ),
      ),
    );
  }
}
