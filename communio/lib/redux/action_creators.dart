import 'dart:async';
import 'package:communio/model/known_person.dart';
import 'package:communio/model/person_found.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:redux_thunk/redux_thunk.dart';
import '../model/app_state.dart';
import 'actions.dart';
import 'package:redux/redux.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

ThunkAction<AppState> incrementCounter() {
  return (Store<AppState> store) async {
    final Future<int> futurIncrementCounter = Future.delayed(
        Duration(seconds: 2), () => store.state.content['counter'] + 1);
    final int incrementCounter = await futurIncrementCounter;
    store.dispatch(IncrementCounterAction(incrementCounter));
  };
}

ThunkAction<AppState> scanForDevices() {
  return (Store<AppState> store) async {
    if (!store.state.content['scanning_on']) {
      final bluetooth = FlutterBlue.instance;
      Logger().i('Starting to scan for devices...');
      final personQueryUrl = store.state.content['person_query_url'];
      final isAvailable = await bluetooth.isAvailable;
      if (isAvailable) {
        bluetooth
            .scan(scanMode: ScanMode.balanced, timeout: Duration(minutes: 30))
            .listen((scanResult) async {
          final Map<String, PersonFound> bluetoothDevices =
              store.state.content['bluetooth_devices'];
          final device = scanResult.device;
          final uuid = device.id.id;
          if (!bluetoothDevices.containsKey(uuid)) {
            final PersonFound person =
                await PersonFound.fromNetwork("$personQueryUrl/$uuid");
            store.dispatch(FoundPersonAction(uuid, person));
          }
        });
        store.dispatch(ActivateScanning());
      }
    }
  };
}

ThunkAction<AppState> queryFriendsList() {
  final friendQueryUrl = DotEnv().env['API_URL']+'users';
  return (Store<AppState> store) async {
    final Set<KnownPerson> friends = new Set<KnownPerson>();
    final response = await http.get(friendQueryUrl);
    if (response.statusCode == 200) {
      final Iterable friendsJson = json.decode(utf8.decode(response.bodyBytes));
      friendsJson.forEach((friendJson) {
        final KnownPerson friend = KnownPerson.fromJson(friendJson);
        friends.add(friend);
      });
      store.dispatch(QueriedFriendsAction(friends));
    }
  };
}

ThunkAction<AppState> addNewFilter(String filter) {
  return (Store<AppState> store) {
    final Set<String> filters = store.state.content['current_filters'];
    if (!filters.contains(filter)) {
      filters.add(filter);
      store.dispatch(NewFiltersAction(filters));
    }
  };
}

ThunkAction<AppState> removeFilter(String filter) {
  return (Store<AppState> store) async {
    final Set<String> filters = store.state.content['current_filters'];
    if (filters.contains(filter)) {
      filters.remove(filter);
      store.dispatch(NewFiltersAction(filters));
    }
  };
}

ThunkAction<AppState> startBroadcastingBeacon() {
  return (Store<AppState> store) async {
    Logger().w('Beacon mode not yet implemented!');
  };
}

ThunkAction<AppState> connectToPerson(PersonFound person) {
  return (Store<AppState> store) async {
    Logger().w('Connect to person not yet implemented!');
  };
}


ThunkAction<AppState> selectNewDevice(String device){

  //TO-DO Add request to server
  return (Store<AppState> store) {
    store.dispatch(SelectActiveDevice(device));
  };
}

ThunkAction<AppState> selectOwnDevice(){
  //TO-DO Add request to server
  return (Store<AppState> store) async {
    final platform = MethodChannel('pt.up.fe.communio');
    final String device = await platform.invokeMethod('getLocalBluetoothName');
    store.dispatch(SelectActiveDevice(device));
  };
}
