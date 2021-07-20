import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';

import 'model/difficulty.dart';
import 'model/event_type.dart';
import 'model/feeling.dart';
import 'model/music_type.dart';

//String enumToString(Object o) => o.toString().split('.').last;
//
//T? enumFromString<T>(String key, List<T> values) =>
//    values.firstWhereOrNull((v) => key == enumToString(v!));

enum DayTime {
  morning,
  afternoon,
  night,
}

extension TimeOfDayExtension on TimeOfDay {
  DayTime dayTime() {
    if (hour > 7 && hour < 12) {
      return DayTime.morning;
    } else if (hour >= 12 && hour < 19) {
      return DayTime.afternoon;
    }
    return DayTime.night;
  }
}

class Events {
  Events(
    this.events,
  );

  LinkedHashMap<DateTime, List<Event>> events;

  factory Events.fromJson(Map<String, dynamic> json) {
//    print('factory json: ${json['events']}');
    return Events(
      LinkedHashMap.from(
        Map.from(json['events']).map(
          (k, v) {
            return MapEntry<DateTime, List<Event>>(
              DateTime.parse(k),
              List<Event>.from(
                v.map(
                  (x) => Event.fromJson(x),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

//  toEncodable() {}

  Map<String, dynamic> toJson() {
    final result = {
      'events': LinkedHashMap.from(
        Map.from(events).map(
          (k, v) {
//              print(k);
//              print((k as DateTime).toIso8601String());
            final mapEntry = MapEntry<String, dynamic>(
              k.toString(),
              List<dynamic>.from(
                v.map(
                  (x) => x.toJson(),
                ),
              ),
            );
//            print('done');
            return mapEntry;
          },
        ),
      ),
    };
//    print('done done');
//    print(result);
    return result;
  }
}

//class Events {
//  Events();
//
//  var events = LinkedHashMap<DateTime, List<Event>>(
//    equals: isSameDay,
//    hashCode: getHashCode,
//  );
//
//  toJson() {
//    Map<String, dynamic> toJson() => {
////      'events': events.map((v) => v.toJson()).toList(),
////      'events': List<dynamic>.from(events.map((x) => x.toJson())),;
//          'events': [],
//        };
//  }
//
//  static final fakeEvents = '''
//    {
//	"events": {
//		"2021-07-19 20:39:24.237591": [{
//				"title": "test",
//				"eventType": "fun",
//				"difficulty": "easy",
//				"feeling": "like",
//				"dateTime": "2021-07-19 20:39:24.237591"
//			},
//			{
//				"title": "test2",
//				"eventType": "fun",
//				"difficulty": "easy",
//				"feeling": "like",
//				"dateTime": "2021-07-19 20:39:24.237591"
//			}
//		],
//		"2021-07-20 00:28:02.178080": [{
//				"title": "test",
//				"eventType": "fun",
//				"difficulty": "easy",
//				"feeling": "like",
//				"dateTime": "2021-07-20 00:28:02.178080"
//			},
//			{
//				"title": "test2",
//				"eventType": "fun",
//				"difficulty": "easy",
//				"feeling": "like",
//				"dateTime": "2021-07-20 00:28:02.178080"
//			}
//		]
//	}
//}
//  ''';
//
//  factory Events.fromJson(Map<String, dynamic> json) {
//    final decoded = jsonDecode(fakeEvents);
//    print(decoded);
////    print(decoded['events']);
//    return Events();
////    final receivedDateTime = DateTime.parse(json['dateTime']);
////    return Event(
////      json['title'],
////      eventType: EnumToString.fromString(EventType.values, json['eventType']),
////      difficulty:
////          EnumToString.fromString(Difficulty.values, json['difficulty']),
////      feeling: EnumToString.fromString(Feeling.values, json['feeling']),
////      time: TimeOfDay.fromDateTime(receivedDateTime),
////      dateTime: receivedDateTime,
////    );
//  }
//}

/// Example event class.
class Event {
  String title;
  EventType? eventType;
  Difficulty? difficulty;
  Feeling? feeling;
  TimeOfDay? time;
  DateTime? dateTime;

  Event(
    this.title, {
    this.eventType,
    this.difficulty,
    this.feeling,
    this.time,
    this.dateTime,
  });

  @override
  String toString() => title;

  factory Event.fromJson(Map<String, dynamic> json) {
    final receivedDateTime = DateTime.parse(json['dateTime']);
    return Event(
      json['title'],
      eventType: EnumToString.fromString(EventType.values, json['eventType']),
      difficulty:
          EnumToString.fromString(Difficulty.values, json['difficulty']),
      feeling: EnumToString.fromString(Feeling.values, json['feeling']),
      time: TimeOfDay.fromDateTime(receivedDateTime),
      dateTime: receivedDateTime,
    );
  }

  Map<String, dynamic> toJson() {
    final result = {
      'title': title,
      'eventType': EnumToString.convertToString(eventType),
      'difficulty': EnumToString.convertToString(difficulty),
      'feeling': EnumToString.convertToString(feeling),
      'dateTime': dateTime!.toIso8601String(),
    };
//    print(result);
    return result;
  }

  MusicType get musicType {
    if (eventType == EventType.fun) {
      return MusicType.happy;
    } else if (eventType == EventType.chore) {
      if (difficulty == Difficulty.hard) {
        return MusicType.sad;
      } else if (difficulty == Difficulty.easy) {
        return MusicType.relax;
      } else {
        return MusicType.energetic;
      }
    } else if (eventType == EventType.work || eventType == EventType.study) {
      if (difficulty == Difficulty.easy) {
        return MusicType.happy;
      } else if (difficulty == Difficulty.normal) {
        if (feeling == Feeling.like) {
          return MusicType.happy;
        } else if (feeling == Feeling.hate) {
          return MusicType.sad;
        }
        if (time!.dayTime() == DayTime.night) {
          return MusicType.relax;
        }
        return MusicType.energetic;
      } else {
        if (feeling == Feeling.like) {
          return MusicType.happy;
        }
        return MusicType.sad;
      }
    }
    return MusicType.happy;
  }
}

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
