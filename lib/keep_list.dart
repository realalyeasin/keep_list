import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class KeepList extends StatefulWidget {
  const KeepList({Key? key}) : super(key: key);

  @override
  _KeepListState createState() => _KeepListState();
}

class _KeepListState extends State<KeepList> {
  final TextEditingController _itemController = TextEditingController();

  final CollectionReference _lists =
      FirebaseFirestore.instance.collection('lists');

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _itemController.text = documentSnapshot['item'];
    }
    await showModalBottomSheet(
      backgroundColor: const Color.fromRGBO(43, 8, 42, 1),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                top: 15,
                left: 25,
                right: 25,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _itemController,
                  decoration: const InputDecoration(labelText: 'Add item', hoverColor: Colors.white),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update', style: const TextStyle(backgroundColor: Color.fromRGBO(232, 237, 238, 1)),),
                  onPressed: () async {
                    final String? item = _itemController.text;
                    if (item != null) {
                      if (action == 'create') {
                        await _lists.add({'item': item});
                      }
                      if (action == 'update') {
                        await _lists
                            .doc(documentSnapshot!.id)
                            .update({'item': item});
                      }
                      _itemController.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _deleteItem(String itemId) async {
    await _lists.doc(itemId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully deleted an item')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(106, 210, 247, 1),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(21, 70, 85, 1),
        title: const Text('Keep List',
        style: TextStyle(
          letterSpacing: .5
        ),),
      ),
      body: StreamBuilder(
        stream: _lists.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                      streamSnapshot.data!.docs[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 16, left: 9, right: 9, bottom: 0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(43, 8, 42, 1),
                        borderRadius: BorderRadius.circular(5)
                      ),

                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            Positioned(
                              child: SizedBox(
                                height: 30,
                                child: Text(
                                  documentSnapshot['item'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 17,
                                  color: Color.fromRGBO(232, 237, 238, 1),
                                  letterSpacing: .5),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 295,
                              bottom: -8,
                              child: Row(
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        _createOrUpdate(documentSnapshot);
                                      },
                                      icon: const Icon(Icons.edit, color: Colors.white,)),
                                  IconButton(
                                      onPressed: () {
                                        _deleteItem(documentSnapshot.id);
                                      },
                                      icon: const Icon(Icons.delete, color: Color.fromRGBO(232, 237, 238, 1),)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createOrUpdate();
        },
        backgroundColor: const Color.fromRGBO(21, 70, 85, 1),
        child: const Icon(Icons.add, color: Colors.white,),
      ),
    );
  }
}
