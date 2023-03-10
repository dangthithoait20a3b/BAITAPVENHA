import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktra/de2.dart';


class de1 extends StatefulWidget {
  const de1({Key? key}) : super(key: key);

  @override
  State<de1> createState() => _de1State();
}

class _de1State extends State<de1> {
  // text fields' controllers
  final TextEditingController maSinhVienController = TextEditingController();
  final TextEditingController ngaySinhController = TextEditingController();
  final TextEditingController gioiTinhController = TextEditingController();
  final TextEditingController queQuanController = TextEditingController();
  final CollectionReference _sinhVien =
  FirebaseFirestore.instance.collection('sinhVien');

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a sinhVien if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      maSinhVienController.text = documentSnapshot['maSinhVien'].toString();
      ngaySinhController.text = documentSnapshot['ngaySinh'];
      gioiTinhController.text = documentSnapshot['gioiTinh'].toString();
      queQuanController.text = documentSnapshot['queQuan'].toString();
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
                  controller: maSinhVienController,
                  decoration: const InputDecoration(
                    labelText: 'Mã Sinh Viên',
                  ),
                ),
                TextField(
                  controller: ngaySinhController,
                  decoration: const InputDecoration(labelText: 'Ngày Sinh'),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: gioiTinhController,
                  decoration: const InputDecoration(
                    labelText: 'Giới Tính',
                  ),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: queQuanController,
                  decoration: const InputDecoration(
                    labelText: 'Quê quán',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? maSinhVien = maSinhVienController.text;
                    final String? ngaySinh = ngaySinhController.text;
                    final String? gioiTinh = gioiTinhController.text;
                    final String? queQuan = queQuanController.text;
                    if (maSinhVien != null && ngaySinh != null && gioiTinh != null && queQuan != null) {
                      if (action == 'create') {
                        // Persist a new giangVien to Firestore
                        await _sinhVien.add({"maSinhVien": maSinhVien, "ngaySinh": ngaySinh, "gioiTinh": gioiTinh, "queQuan": queQuan});
                      }

                      if (action == 'update') {
                        // Update the giangVien
                        await _sinhVien
                            .doc(documentSnapshot!.id)
                            .update({"maSinhVien": maSinhVien, "ngaySinh": ngaySinh, "gioiTinh": gioiTinh, "queQuan": queQuan});
                      }

                      // Clear the text fields
                      maSinhVienController.text = '';
                      ngaySinhController.text = '';
                      gioiTinhController.text = '';
                      queQuanController.text = '';
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

  // Deleteing a sinhvien by id
  Future<void> _deleteProduct(String sinhVienId) async {
    await _sinhVien.doc(sinhVienId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a class')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => de1())), icon: Icon(Icons.arrow_back, color: Colors.black,)),
        title: const Text('Bài Kiểm Tra Số 01 - Đề 01'),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> de2()));
          }, icon: Icon(Icons.arrow_forward))
        ],
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _sinhVien.snapshots(),
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
                    title: Text(documentSnapshot['maSinhVien'] , style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                    subtitle: Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text("Ngày sinh: ")
                                ],
                              )  ,
                              Column(
                                children: [
                                  Text(documentSnapshot['ngaySinh'].toString()),
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text("Giới tính: ")
                                ],
                              )  ,
                              Column(
                                children: [
                                  Text(documentSnapshot['gioiTinh'].toString()),
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text("Quê quán: ")
                                ],
                              )  ,
                              Column(
                                children: [
                                  Text(documentSnapshot['queQuan'].toString()),
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
