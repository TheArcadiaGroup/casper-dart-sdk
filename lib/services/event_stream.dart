// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:oxidized/oxidized.dart';
import 'package:http/http.dart' as http;

enum StreamErrors {
  NotAnEvent,
  EarlyEndOfStream,
  MissingDataHeader,
  MissingDataHeaderAndId,
  MissingId
}

class DeployWatcher {}

typedef EventHandlerFn = void Function(dynamic result);

enum EventName {
  BlockAdded,
  BlockFinalized,
  FinalitySignature,
  Fault,
  DeployProcessed
}

extension EventNameExtension on EventName {
  String get value {
    switch (this) {
      case EventName.BlockAdded:
        return 'BlockAdded';
      case EventName.BlockFinalized:
        return 'BlockFinalized';
      case EventName.FinalitySignature:
        return 'FinalitySignature';
      case EventName.Fault:
        return 'Fault';
      case EventName.DeployProcessed:
        return 'DeployProcessed';
    }
  }
}

class EventSubscription {
  late EventName eventName;
  late EventHandlerFn eventHandlerFn;

  EventSubscription({
    required this.eventName,
    required this.eventHandlerFn,
  });
}

class EventParseResult {
  String? id;
  StreamErrors? err;
  dynamic body;

  EventParseResult({
    this.id,
    this.err,
    this.body,
  });
}

class EventStream {
  List<EventSubscription> subscribedTo = List.empty(growable: true);
  List<EventParseResult> pendingDeploysParts = List.empty(growable: true);
  String pendingDeployString = '';
  late http.StreamedResponse? stream;
  late String eventStreamUrl;

  EventStream(this.eventStreamUrl);

  Result<bool, String> subscribe(
      EventName eventName, EventHandlerFn eventHandlerFn) {
    if (subscribedTo.every((element) => element.eventName == eventName)) {
      return Err('Already subscribed to this event');
    }
    subscribedTo.add(EventSubscription(
      eventName: eventName,
      eventHandlerFn: eventHandlerFn,
    ));
    return Ok(true);
  }

  Result<bool, String> unsubscribe(EventName eventName) {
    if (subscribedTo.every((element) => element.eventName == eventName)) {
      return Err('Cannot find provided subscription');
    }

    subscribedTo = subscribedTo
        .where((element) => element.eventName != eventName)
        .toList();

    return Ok(true);
  }

  void runEventsLoop(EventParseResult result) {
    for (var element in subscribedTo) {
      if (result.body != null &&
          (result.body?.containsKey(element.eventName) ?? false)) {
        element.eventHandlerFn(result);
      }
    }
  }

  void onData(List<int> buf) {
    var result = esParseEvent(String.fromCharCodes(buf));
    if (result.err == null) {
      runEventsLoop(result);
    }
    if (result.err == StreamErrors.EarlyEndOfStream) {
      pendingDeployString = result.body;
    }
    if (result.err == StreamErrors.MissingDataHeaderAndId) {
      pendingDeployString += result.body;
    }
    if (result.err == StreamErrors.MissingDataHeader) {
      pendingDeployString += result.body;
      pendingDeployString += '\nid:${result.id}';

      var newResult = esParseEvent(pendingDeployString);
      if (newResult.err == null) {
        pendingDeployString = '';
      }
      runEventsLoop(newResult);
    }
  }

  void start([int eventId = 0]) async {
    var uri = Uri.parse('$eventStreamUrl?start_from=$eventId');
    var request = http.Request('GET', uri);

    request.send().then((res) {
      stream = res;
      res.stream.listen((value) {
        onData(value);
      });
    });
  }

  void stop() {
    stream = null;
  }
}

EventParseResult esParseEvent(String eventString) {
  if (eventString.startsWith('data')) {
    var splitted = eventString.split('\n');
    var id = splitted[1].isNotEmpty && splitted[1].startsWith('id:')
        ? splitted[1].substring(3)
        : null;
    try {
      var body = jsonDecode(splitted[0].substring(5));
      if (id != null) {
        // Note: This is case where there is proper object with JSON body and id in one chunk.
        return EventParseResult(id: id, body: body, err: null);
      } else {
        // Note: This is case where there is proper object with JSON body but without ID.
        return EventParseResult(
            id: id, body: body, err: StreamErrors.MissingId);
      }
    } catch (e) {
      // Note: This is case where there is invalid JSON because of early end of stream.
      return EventParseResult(
          id: id, body: splitted[0], err: StreamErrors.EarlyEndOfStream);
    }
  } else {
    var splitted = eventString.split('\n');
    var body = splitted[0];
    var id = splitted[1].isNotEmpty && splitted[1].startsWith('id:')
        ? splitted[1].substring(3)
        : null;

    if (splitted[0] == ':' && splitted[1] == '' && splitted[2] == '') {
      return EventParseResult(
          id: null, body: null, err: StreamErrors.NotAnEvent);
    }

    if (id != null) {
      return EventParseResult(
          id: id, body: body, err: StreamErrors.MissingDataHeader);
    } else {
      return EventParseResult(
          id: null, body: body, err: StreamErrors.MissingDataHeaderAndId);
    }
  }
}
