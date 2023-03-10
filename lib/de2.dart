import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ktra/de3.dart';


class de2 extends StatefulWidget {
  const de2({Key? key}) : super(key: key);

  @override
  State<de2> createState() => _de2State();
}

class _de2State extends State<de2> {
  // text fields' controllers
  final TextEditingController maGiangVienController = TextEditingController();
  final TextEditingController hoTenController = TextEditingController();
  final TextEditingController diaChiController = TextEditingController();
  final TextEditingController sdtController = TextEditingController();
  final CollectionReference _giangVien =
  FirebaseFirestore.instance.collection('giangVien');

  // This function is triggered when the floatting button or one of the edit buttons is pressed
  // Adding a giangVien if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      maGiangVienController.text = documentSnapshot['maGiangVien'].toString();
      hoTenController.text = documentSnapshot['hoTen'];
      diaChiController.text = documentSnapshot['diaChi'].toString();
      sdtController.text = documentSnapshot['sdt'].toString();
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
                  controller: maGiangVienController,
                  decoration: const InputDecoration(
                    labelText: 'Mã Giảng Viên',
                  ),
                ),
                TextField(
                  controller: hoTenController,
                  decoration: const InputDecoration(labelText: 'Họ Tên'),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: diaChiController,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ',
                  ),
                ),
                TextField(
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  controller: sdtController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    final String? maGiangVien = maGiangVienController.text;
                    final String? hoTen = hoTenController.text;
                    final String? diaChi = diaChiController.text;
                    final String? sdt = sdtController.text;
                    if (maGiangVien != null && hoTen != null && diaChi != null && sdt != null) {
                      if (action == 'create') {
                        // Persist a new giangVien to Firestore
                        await _giangVien.add({"maGiangVien": maGiangVien, "hoTen": hoTen, "diaChi": diaChi, "sdt": sdt});
                      }

                      if (action == 'update') {
                        // Update the giangVien
                        await _giangVien
                            .doc(documentSnapshot!.id)
                            .update({"maGiangVien": maGiangVien, "hoTen": hoTen, "diaChi": diaChi, "sdt": sdt});
                      }

                      // Clear the text fields
                      maGiangVienController.text = '';
                      hoTenController.text = '';
                      diaChiController.text = '';
                      sdtController.text = '';
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

  // Deleteing a giangvien by id
  Future<void> _deleteProduct(String giangVienId) async {
    await _giangVien.doc(giangVienId).delete();

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a class')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => de1())), icon: Icon(Icons.arrow_back, color: Colors.black,)),
        title: const Text('Bài Kiểm Tra Số 01 - Đề 02'),
        actions: [
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> de3()));
          }, icon: Icon(Icons.arrow_forward))
        ],
      ),
      // Using StreamBuilder to display all products from Firestore in real-time
      body: StreamBuilder(
        stream: _giangVien.snapshots(),
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
                    title: Text(documentSnapshot['hoTen'] , style: TextStyle(
                        fontWeight: FontWeight.bold
                    ),),
                    subtitle: Expanded(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text("Mã giảng viên: ")
                                ],
                              )  ,
                              Column(
                                children: [
                                  Text(documentSnapshot['maGiangVien'].toString()),
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text("Địa chỉ: ")
                                ],
                              )  ,
                              Column(
                                children: [
                                  Text(documentSnapshot['diaChi'].toString()),
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  Text("Số điện thoại: ")
                                ],
                              )  ,
                              Column(
                                children: [
                                  Text(documentSnapshot['sdt'].toString()),
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
