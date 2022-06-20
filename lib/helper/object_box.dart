import 'dart:io';

import '../model/user.dart';
import '../objectbox.g.dart';

class ObjectBox {
  late final Store _store;
  late final Box<User> _userBox;

  ObjectBox._init(this._store) {
    _userBox = Box<User>(_store);
  }

  static Future<ObjectBox> init() async {
    final store = await openStore();

    if (Sync.isAvailable()) {
      /// Or use the ip address of your server
      //final ipSyncServer = '123.456.789.012';
      final ipSyncServer = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';
      final syncClient = Sync.client(
        store,
        'ws://$ipSyncServer:9999',
        SyncCredentials.none(),
      );
      syncClient.connectionEvents.listen(print);
      syncClient.start();
    }

    return ObjectBox._init(store);
  }

  User? getUser(int id) => _userBox.get(id);

  Stream<List<User>> getUsers() => _userBox
      .query()
      .watch(triggerImmediately: true)
      .map((query) => query.find());

  int insertUser(User user) => _userBox.put(user);

  bool deleteUser(int id) => _userBox.remove(id);
}
