import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:collection';
import 'database.dart';

class DatabaseUpdatePage extends StatefulWidget {
  final String documentId;
  final String? title;
  const DatabaseUpdatePage({super.key, required this.documentId, this.title});

  @override
  State<DatabaseUpdatePage> createState() => _DatabaseUpdatePageState();
}

class _DatabaseUpdatePageState extends State<DatabaseUpdatePage> {
  final TextEditingController _titleController = TextEditingController();

  void _updateItem(String title, documentId) async {
    try {
      // setState(() async {
      await databases.updateDocument(
        databaseId: database,
        collectionId: itemsCollection,
        documentId: documentId,
        data: {'title': title},
      );
      // });
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    _titleController.text = widget.title!;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Update Item'),
        ),
        body: Column(
          children: [
            TextField(
              controller: _titleController,
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () {
                // update item
                setState(() {
                  final title = _titleController.text;
                  int x = 1;
                  if (title.isNotEmpty) {
                    _titleController.clear();
                    print('(L3)${widget.documentId}');
                    _updateItem(title, widget.documentId);
                  }
                });

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => DatabasePage()));
              },

              //Navigator.of(context).pop();
            ),
          ],
        ));
  }
}
