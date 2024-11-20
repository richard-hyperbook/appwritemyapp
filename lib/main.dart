import 'package:flutter/material.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'database.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Client client = Client()
      .setEndpoint("https://cloud.appwrite.io/v1")
      .setProject("hyperbook410364");
  Account account = Account(client);

  runApp(MaterialApp(
    home: MyApp(account: account),
  ));
}
class MyApp extends StatefulWidget {
  final Account account;

  MyApp({required this.account});

  @override
  MyAppState createState() {
    return MyAppState();
  }
}
class MyAppState extends State<MyApp> {
  models.User? loggedInUser;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  Future<void> login(String email, String password) async {
    await widget.account.createEmailPasswordSession(email: email, password: password);
    final user = await widget.account.get();
    print('(L20)${user.status}');
    setState(() {
      loggedInUser = user;
    });
  }

  Future<void> register(String email, String password, String name) async {
    await widget.account.create(
        userId: ID.unique(), email: email, password: password, name: name);
    await login(email, password);
  }

  Future<void> logout() async {
    await widget.account.deleteSession(sessionId: 'current');
    print('(L21)${loggedInUser!.status}^${loggedInUser!.password}');
    setState(() {
      loggedInUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ElevatedButton(
            onPressed: (){Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DatabasePage()));},
            child: Text('Database')),
            Text(loggedInUser != null
                ? 'Logged in as ${loggedInUser!.name}'
                : 'Not logged in'),
            SizedBox(height: 16.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    login(emailController.text, passwordController.text);
                  },
                  child: Text('Login'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    register(emailController.text, passwordController.text,
                        nameController.text);
                  },
                  child: Text('Register'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    logout();
                  },
                  child: Text('Logout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
