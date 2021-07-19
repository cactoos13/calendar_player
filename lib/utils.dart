import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'difficulty.dart';
import 'event_type.dart';
import 'feeling.dart';
import 'music_type.dart';

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

/// Example events.
///
/// Using a [LinkedHashMap] is highly recommended if you decide to use a map.
final kEvents = LinkedHashMap<DateTime, List<Event>>(
  equals: isSameDay,
  hashCode: getHashCode,
)..addAll(_kEventSource);

final _kEventSource = Map.fromIterable(List.generate(50, (index) => index),
    key: (item) => DateTime.utc(kFirstDay.year, kFirstDay.month, item * 5),
    value: (item) => List.generate(
        item % 4 + 1, (index) => Event('Event $item | ${index + 1}')))
  ..addAll({
    kToday: [
      Event('Today\'s Event 1'),
      Event('Today\'s Event 2'),
    ],
  });

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);
