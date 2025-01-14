import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  DateTime selectedDate = DateTime.now(); // Teslim tarihi

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

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
            for (int i = 0; i < taskControllers.length; i++)
              TextField(
                controller: taskControllers[i],
                decoration: InputDecoration(labelText: "Task ${i + 1}"),
              ),
            Row(
              children: [
                Text("Delivery Date: ${selectedDate.toLocal()}".split(' ')[0]), // Teslim tarihi
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(groupNameController.text)
                    .set({
                  'tasks': FieldValue.arrayUnion(taskControllers.map((e) => e.text).toList()),
                  'deliveryDate': selectedDate, // Teslim tarihi
                  'isCompleted': false,
                }, SetOptions(merge: true));
              },
              child: Text("Add Tasks to Group"),
            ),
            Expanded(
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
                              trailing: IconButton(
                                icon: Icon(Icons.delete),
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
