
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class de4 extends StatefulWidget {
  const de4({Key? key}) : super(key: key);

  @override
  State<de4> createState() => _de4State();
}

class _de4State extends State<de4> {
  // text fields' controllers
  final TextEditingController idController = TextEditingController();
  final TextEditingController maMonHocController = TextEditingController();
  final TextEditingController tenMonHocController = TextEditingController();
  final TextEditingController moTaController = TextEditingController();
  final CollectionReference _monhoc =
  FirebaseFirestore.instance.collection('monhoc');

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      idController.text = documentSnapshot['id'].toString();
      maMonHocController.text = documentSnapshot['maMonHoc'];
      tenMonHocController.text = documentSnapshot['tenMonHoc'].toString();
      moTaController.text = documentSnapshot['moTa'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                // prevent the soft keyboard from covering text fields
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Id',
                  ),
                ),
                TextField(
                  controller: maMonHocController,
                  decoration: const InputDecoration(labelText: 'Mã Môn Học'),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: tenMonHocController,
                  decoration: const InputDecoration(
                    labelText: 'Tên Môn Học',
                  ),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: moTaController,
                  decoration: const InputDecoration(
                    labelText: 'Mô Tả',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? id = idController.text;
                    final String? maMonHoc = maMonHocController.text;
                    final String? tenMonHoc = tenMonHocController.text;
                    final String? moTa = moTaController.text;
                    if (id != null &&
                        maMonHoc != null &&
                        tenMonHoc != null &&
                        moTa != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _monhoc.add({
                          "id": id,
                          "maMonHoc": maMonHoc,
                          "tenMonHoc": tenMonHoc,
                          "moTa": moTa
                        });
                      }

                      if (action == 'update') {
                        // Update the product
                        await _monhoc.doc(documentSnapshot!.id).update({
                          "id": id,
                          "maMonHoc": maMonHoc,
                          "tenMonHoc": tenMonHoc,
                          "moTa": moTa
                        });
                      }

                      // Clear the text fields
                      idController.text = '';
                      maMonHocController.text = '';
                      tenMonHocController.text = '';
                      moTaController.text = '';
                      // Hide the bottom sheet
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  // Deleteing a product by id
  Future<void> _deleteProduct(String classId) async {
    await _monhoc.doc(classId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have successfully deleted a class')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài Kiểm Tra Số 01 - Đề 04'),
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _monhoc.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                streamSnapshot.data!.docs[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['tenMonHoc'] , style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                    subtitle: Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text("Id: ")
                                ],
                              )  ,
                              Column(
                                children: [
                                  Text(documentSnapshot['id'].toString()),
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text("Mã mon học: ")
                                ],
                              )  ,
                              Column(
                                children: [
                                  Text(documentSnapshot['maMonHoc'].toString()),
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text("Mô tả: ")
                                ],
                              )  ,
                              Column(
                                children: [
                                  Text(documentSnapshot['moTa'].toString()),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          // Press this button to edit a single product
                          IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () =>
                                  _createOrUpdate(documentSnapshot)),
                          // This icon button is used to delete a single product
                          IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  _deleteProduct(documentSnapshot.id)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      // Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
