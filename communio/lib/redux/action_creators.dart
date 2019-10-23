import 'dart:async';
import 'package:communio/model/person_found.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:logger/logger.dart';
import 'package:redux_thunk/redux_thunk.dart';
import '../model/app_state.dart';
import 'actions.dart';
import 'package:redux/redux.dart';

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
          final Map<BluetoothDevice, PersonFound> bluetoothDevices =
              store.state.content['bluetooth_devices'];
          final device = scanResult.device;
          if (!bluetoothDevices.containsKey(device)) {
            final PersonFound person =
                await PersonFound.fromNetwork("$personQueryUrl/$device");
            store.dispatch(FoundPersonAction(device, person));
          }
        });
        store.dispatch(ActivateScanning());
      }
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
    Logger().w('Connect to person!');
  };
}



