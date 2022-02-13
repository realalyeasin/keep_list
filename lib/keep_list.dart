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
                  decoration: const InputDecoration(labelText: 'Add item'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
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
      appBar: AppBar(
        title: const Text('Keep List'),
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
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: Colors.green,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Text(documentSnapshot['item']),
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      _createOrUpdate(documentSnapshot);
                                    },
                                    icon: const Icon(Icons.edit)),
                                IconButton(
                                    onPressed: () {
                                      _deleteItem(documentSnapshot.id);
                                    },
                                    icon: const Icon(Icons.delete)),
                              ],
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
        child: const Icon(Icons.add),
      ),
    );
  }
}
