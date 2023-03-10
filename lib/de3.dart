import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktra/de4.dart';

class de3 extends StatefulWidget {
  const de3({Key? key}) : super(key: key);

  @override
  State<de3> createState() => _de3State();
}

class _de3State extends State<de3> {
  // text fields' controllers
  final TextEditingController maLopHocController = TextEditingController();
  final TextEditingController tenLopController = TextEditingController();
  final TextEditingController soLuongSinhVienController = TextEditingController();
  final TextEditingController maGiangVienController = TextEditingController();
  final CollectionReference _classes =
  FirebaseFirestore.instance.collection('class');
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      maLopHocController.text = documentSnapshot['maLopHoc'].toString();
      tenLopController.text = documentSnapshot['tenLop'];
      soLuongSinhVienController.text =
          documentSnapshot['soLuongSinhVien'].toString();
      maGiangVienController.text = documentSnapshot['maGiangVien'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: maLopHocController,
                  decoration: const InputDecoration(
                    labelText: 'Mã Lớp Học',
                  ),
                ),
                TextField(
                  controller: tenLopController,
                  decoration: const InputDecoration(labelText: 'Tên Lớp Học'),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: soLuongSinhVienController,
                  decoration: const InputDecoration(
                    labelText: 'Số Lượng Sinh Viên',
                  ),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: maGiangVienController,
                  decoration: const InputDecoration(
                    labelText: 'Mã Giảng Viên',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? maLopHoc = maLopHocController.text;
                    final String? tenLop = tenLopController.text;
                    final String? soLuongSinhVien =
                        soLuongSinhVienController.text;
                    final String? maGiangVien = maGiangVienController.text;
                    if (maLopHoc != null &&
                        tenLop != null &&
                        soLuongSinhVien != null &&
                        maGiangVien != null) {
                      if (action == 'create') {
                        // Persist a new product to Firestore
                        await _classes.add({
                          "maLopHoc": maLopHoc,
                          "tenLop": tenLop,
                          "soLuongSinhVien": soLuongSinhVien,
                          "maGiangVien": maGiangVien
                        });
                      }
                      if (action == 'update') {
                        // Update the product
                        await _classes.doc(documentSnapshot!.id).update({
                          "maLopHoc": maLopHoc,
                          "tenLop": tenLop,
                          "soLuongSinhVien": soLuongSinhVien,
                          "maGiangVien": maGiangVien
                        });
                      }
                      maLopHocController.text = '';
                      tenLopController.text = '';
                      soLuongSinhVienController.text = '';
                      maGiangVienController.text = '';
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

  // Xóa lớp học theo ID
  Future<void> _deleteProduct(String classId) async {
    await _classes.doc(classId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have successfully deleted a class')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => )), icon: Icon(Icons.arrow_back, color: Colors.black,)),
        title: const Text('Bài Kiểm Tra Số 01 - Đề 03'),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> de4()));
          }, icon: Icon(Icons.arrow_forward))
        ],
      ),
      body: StreamBuilder(
        stream: _classes.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      documentSnapshot['tenLop'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [Text("Số Lượng Sinh Viên: ")],
                              ),
                              Column(
                                children: [
                                  Text(documentSnapshot['soLuongSinhVien']
                                      .toString()),
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                children: [Text("Mã Giảng Viên: ")],
                              ),
                              Column(
                                children: [
                                  Text(documentSnapshot['maGiangVien']
                                      .toString()),
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                children: [Text("Mã Lớp học: ")],
                              ),
                              Column(
                                children: [
                                  Text(documentSnapshot['maLopHoc'].toString()),
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
