import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:collection';
import 'datbaseupdatepage.dart';

final TextEditingController _titleController = TextEditingController();
RealtimeSubscription? subscription;
late  Client? client = null;
final database = 'hyperbookdb410364'; // your database id
final itemsCollection = '673ce4c3001cd0ad6841'; // your collection id
late final Databases databases;
late List<Map<String, dynamic>> items = [];

class DatabasePage extends StatelessWidget {
  const DatabasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlAppwrite Realtime Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const DbPage(),
    );
  }
}

class DbPage extends StatefulWidget {
  const DbPage({super.key});

  @override
  State<DbPage> createState() => _DbPageState();
}

class _DbPageState extends State<DbPage> {
  @override
  initState() {
    super.initState();
    if (client == null) {
      client = Client().setProject('hyperbook410364'); // your project id
      databases = Databases(client!);
    }
    loadItems();
    subscribe();
  }

  loadItems() async {
    try {
      final res = await databases.listDocuments(
        databaseId: database,
        collectionId: itemsCollection,
      );
      setState(() {
        items =
            List<Map<String, dynamic>>.from(res.documents.map((e) => e.data));
      });
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }

  void subscribe() {
    final realtime = Realtime(client!);

    subscription = realtime.subscribe([
      'documents' // subscribe to all documents in every database and collection
    ]);

    // listen to changes
    subscription!.stream.listen((data) {
      // data will consist of `events` and a `payload`
      final event = data.events.first;
      print('(L1)');
      print(data);

      if (data.payload.isNotEmpty) {
        if (event.endsWith('.create')) {
          var item = data.payload;
          items.add(item);
          setState(() {});
        } else if (event.endsWith('.delete')) {
          var item = data.payload;
          items.removeWhere((it) => it['\$id'] == item['\$id']);
          setState(() {});
        } else if (event.endsWith('.update')) {
          setState(() {
            print('(L5)${data.payload['title']}');
          });
        }
      }
    });
  }

  @override
  dispose() {
    subscription?.close();
    super.dispose();
  }

  adUpdate(item, index) {
    print('(L2)');
    setState(() {
      showDialog(
          context: context,
          builder: (context) {
            String contentText = "Content of Dialog";
            return AlertDialog(
                title: const Text('Edit item'),
                content:
                    //  StatefulBuilder(builder: (context, setState) { return
                    Column(
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
                            print('(L3)${item}');
                            _updateItem(title, item['\$id']);
                            items[index]['title'] = title;
                          }
                        });
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ));
          });
    });
  }

  int index = 0;
  @override
  Widget build(BuildContext context) {
    index = 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlAppwrite Realtime Demo'),
      ),
      body: ListView(children: [
        ...items.map((item) {
          print('(L6)${index}');
          print(item);
          index++;
          return ListTile(
            key: UniqueKey(),
            selectedTileColor: Colors.amber,
            hoverColor: Colors.lime,
            tileColor: Colors.lightBlue,
            title: Text(
              item['title'],
              key: UniqueKey(),
            ),
            onTap: () {
              //  adUpdate(item, index - 1);
              print('(L8)');
              print(item['\$id']);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          DatabaseUpdatePage(documentId: item['\$id'], title:  item['title'])));
            },
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await databases.deleteDocument(
                  databaseId: database,
                  collectionId: itemsCollection,
                  documentId: item['\$id'],
                );
              },
            ),
          );
        }),
      ]),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // dialog to add new item
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add new item'),
              content: TextField(
                controller: _titleController,
              ),
              actions: [
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    // add new item
                    final title = _titleController.text;
                    if (title.isNotEmpty) {
                      _titleController.clear();
                      _addItem(title);
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _addItem(String title) async {
    try {
      await databases.createDocument(
        databaseId: database,
        collectionId: itemsCollection,
        documentId: ID.unique(),
        data: {'title': title},
      );
    } on AppwriteException catch (e) {
      print(e.message);
    }
  }

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
}
