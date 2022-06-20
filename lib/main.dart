import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:objectbox_flutter/helper/object_box.dart';
import 'package:objectbox_flutter/model/user.dart';

late ObjectBox objectBox;

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBox.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ObjectBox',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorSchemeSeed: Colors.cyan,
          textTheme: const TextTheme(
            bodyText2: TextStyle(fontSize: 20),
            subtitle1: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        home: const Homepage(),
      );
}

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  late Stream<List<User>> streamUsers;

  @override
  void initState() {
    super.initState();

    streamUsers = objectBox.getUsers();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('ObjectBox'),
          centerTitle: true,
        ),
        body: StreamBuilder<List<User>>(
          stream: streamUsers,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final users = snapshot.data!;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];

                  return ListTile(
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => objectBox.deleteUser(user.id),
                    ),
                    onTap: () {
                      user.name = Faker().person.firstName();
                      user.email = Faker().internet.email();

                      objectBox.insertUser(user);
                    },
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            final user = User(
              name: Faker().person.firstName(),
              email: Faker().internet.email(),
            );

            objectBox.insertUser(user);
          },
        ),
      );
}
