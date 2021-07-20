import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:full_audio/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import 'model/difficulty.dart';
import 'model/event_type.dart';
import 'model/feeling.dart';
import 'model/music_type.dart';

class TableEvent extends StatefulWidget {
  @override
  _TableEventState createState() => _TableEventState();
}

class _TableEventState extends State<TableEvent> {
  //todo find a classy solution instead of linkedhashmap
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  static final today =
      DateTime.parse(DateTime.now().toIso8601String().substring(0, 10) + '');
  static final todayZ = DateTime.parse(today.toIso8601String() + 'Z');

  DateTime _focusedDay = todayZ;
  DateTime? _selectedDay = todayZ;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;
  final _eventNameController = TextEditingController();
  late SharedPreferences prefs;
  Event newEvent = Event('', time: TimeOfDay.fromDateTime(DateTime.now()));
  TimeOfDay selectedEventTime = TimeOfDay.fromDateTime(DateTime.now());
  int? currentIndex;

  Events? eventsClass;

  LinkedHashMap<DateTime, List<Event>> get events =>
      eventsClass?.events ?? LinkedHashMap();

  final audios = <Audio>[
    Audio(
      'assets/audios/happy_clappy_ukulele.mp3',
    ),
    Audio(
      'assets/audios/sad-dissociation.mp3',
    ),
    Audio(
      'assets/audios/relax-ForestWalk-320bit.mp3',
    ),
    Audio(
      'assets/audios/motivate-Wavecont-Inspire-2-Full-Lenght.mp3',
    ),
  ];

  AssetsAudioPlayer get _assetsAudioPlayer => AssetsAudioPlayer.withId('music');
  final List<StreamSubscription> _subscriptions = [];
  late StreamSubscription isPlaying;
  late StreamSubscription<Playing?> playing;

  static final fakeEvents = '''
    {
	"events": {
		"2021-07-19 00:00:00.000Z": [{
				"title": "test",
				"eventType": "fun",
				"difficulty": "easy",
				"feeling": "like",
				"dateTime": "2021-07-19 20:39:24.237591"
			},
			{
				"title": "test2",
				"eventType": "fun",
				"difficulty": "easy",
				"feeling": "like",
				"dateTime": "2021-07-19 20:39:24.237591"
			}
		],
		"2021-07-20 00:00:00.000Z": [{
				"title": "test",
				"eventType": "fun",
				"difficulty": "easy",
				"feeling": "like",
				"dateTime": "2021-07-20 00:28:02.178080"
			},
			{
				"title": "test2",
				"eventType": "fun",
				"difficulty": "easy",
				"feeling": "like",
				"dateTime": "2021-07-20 00:28:02.178080"
			}
		]
	}
}
  ''';

  Future<Null> getSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('events')) {
      final String? eventsString = prefs.getString('events');
      final decodedEvents = jsonDecode(eventsString!);
      setState(() {
        eventsClass = Events.fromJson(decodedEvents);
      });
      setState(() {
        final today = DateTime.parse(
            DateTime.now().toIso8601String().substring(0, 10) + '');
        final todayZ = DateTime.parse(today.toIso8601String() + 'Z');
        _selectedEvents.value = _getEventsForDay(todayZ);
      });
    } else {
      eventsClass = Events(LinkedHashMap());
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _subscriptions.add(_assetsAudioPlayer.playlistAudioFinished.listen((data) {
      print('playlistAudioFinished : $data');
    }));
    _subscriptions.add(_assetsAudioPlayer.audioSessionId.listen((sessionId) {
      print('audioSessionId : $sessionId');
    }));
    isPlaying = _assetsAudioPlayer.isPlaying.listen((isPlaying) {
      print('isPlaying : $isPlaying');
    });
    playing = _assetsAudioPlayer.current.listen((playing) {
      print('playing : $playing');
    });
    openPlayer();
    getSharedPrefs();
  }

  void openPlayer() async {
    await _assetsAudioPlayer.open(
      Playlist(audios: audios, startIndex: 0),
//      showNotification: true,
      autoStart: false,
    );
  }

  @override
  void dispose() {
    _assetsAudioPlayer.dispose();
    _selectedEvents.dispose();
    isPlaying.cancel();
    playing.cancel();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
//    print('events: $events');
//    print('day: $day');
    final dayEvents = events[day] ?? [];
//    print('dayEvents: $dayEvents');
    return dayEvents..sort((a, b) => a.dateTime!.compareTo(b.dateTime!));
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

//  Audio find(List<Audio> source, String fromPath) {
//    return source.firstWhere((element) => element.path == fromPath);
//  }

  @override
  Widget build(BuildContext context) {
    Events.fromJson(jsonDecode(fakeEvents));
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Calendar'),
          actions: [
            IconButton(
              onPressed: _clearHistory,
              icon: Icon(Icons.delete),
            ),
          ],
        ),
        body: Column(
          children: [
            TableCalendar<Event>(
              firstDay: kFirstDay,
              lastDay: kLastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              rangeStartDay: _rangeStart,
              rangeEndDay: _rangeEnd,
              calendarFormat: _calendarFormat,
              rangeSelectionMode: _rangeSelectionMode,
              eventLoader: _getEventsForDay,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
              ),
              onDaySelected: _onDaySelected,
              availableCalendarFormats: const {
                CalendarFormat.month: 'Month',
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: ValueListenableBuilder<List<Event>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) {
                      final event = value[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: ListTile(
                          onTap: () {
                            playByMood(event.musicType);
                          },
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${event.title}: '
                                  '('
                                  '${event.eventType!.toShortString()}, '
                                  '${event.difficulty!.toShortString()}, ${event.feeling!.toShortString()}'
                                  ')'),
                              SizedBox(
                                height: 4,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      '${event.musicType.toString().split('.').last}'),
                                  Text(event.dateTime!
                                      .toIso8601String()
                                      .substring(11, 16)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: _showAddDialog,
        ),
      ),
    );
  }

  void playByMood(MusicType musicType) {
    switch (musicType) {
      case MusicType.happy:
        controlMusic(0);
        break;
      case MusicType.sad:
        controlMusic(1);
        break;
      case MusicType.relax:
        controlMusic(2);
        break;
      case MusicType.energetic:
        controlMusic(3);
        break;
    }
    _assetsAudioPlayer.playOrPause();
  }

  _showAddDialog() async {
    await showDialog(
        context: context,
        builder: (innerContext) => AlertDialog(
              title: Text('Add Event'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _eventNameController,
                      decoration: InputDecoration(
                        hintText: 'Event name',
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    StatefulBuilder(builder:
                        (BuildContext context, StateSetter innerSetState) {
                      return Row(
                        children: [
                          Text('Time: '),
                          TextButton(
                            onPressed: () async {
                              final result = (await showTimePicker(
                                context: context,
                                initialTime: selectedEventTime,
                              ))!;
                              innerSetState(() {
                                selectedEventTime = result;
                              });
                              setState(() {
                                newEvent.time = result;
                              });
                            },
                            child: Text(
                              '${selectedEventTime.hour}:${selectedEventTime.minute.toString().padLeft(2, '0')}',
                            ),
                          ),
                        ],
                      );
                    }),
                    SizedBox(
                      height: 16,
                    ),
                    Text('Type'),
                    StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return Row(
                        children: EventType.values.map((e) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: ChoiceChip(
                              label: Text(e.toShortString()),
                              selected: newEvent.eventType == e,
                              onSelected: (bool selected) {
                                if (selected) {
                                  setState(() {
                                    newEvent.eventType = e;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    SizedBox(
                      height: 16,
                    ),
                    Text('Difficulty'),
                    StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return Row(
                        children: Difficulty.values.map((e) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: ChoiceChip(
                              label: Text(e.toShortString()),
                              selected: newEvent.difficulty == e,
                              onSelected: (bool selected) {
                                if (selected) {
                                  setState(() {
                                    newEvent.difficulty = e;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    SizedBox(
                      height: 16,
                    ),
                    Text('Mood'),
                    StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                      return Row(
                        children: Feeling.values.map((e) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: ChoiceChip(
                              label: Text(e.toShortString()),
                              selected: newEvent.feeling == e,
                              onSelected: (bool selected) {
                                if (selected) {
                                  setState(() {
                                    newEvent.feeling = e;
                                  });
                                }
                              },
                            ),
                          );
                        }).toList(),
                      );
                    }),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Add',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    if (checkErrors()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You need to enter all information'),
                        ),
                      );
                      return;
                    } else {
                      newEvent.title = _eventNameController.text;
                      final myEvent = Event(
                        newEvent.title,
                        difficulty: newEvent.difficulty,
                        eventType: newEvent.eventType,
                        feeling: newEvent.feeling,
                        time: newEvent.time,
                        dateTime: DateTime(
                          _selectedDay!.year,
                          _selectedDay!.month,
                          _selectedDay!.day,
                          newEvent.time!.hour,
                          newEvent.time!.minute,
                        ),
                      );

                      setState(() {
                        if (events[_selectedDay] != null) {
                          events[_selectedDay]!.add(
                            myEvent,
                          );
                        } else {
                          setState(() {
                            events[_selectedDay!] = [myEvent];
                          });
                        }
                        final eventsJson = eventsClass!.toJson();
                        final encodedEvents = jsonEncode(eventsJson);
                        prefs.setString('events', encodedEvents);
                        clearDialog();
                        _selectedEvents.value = _getEventsForDay(_selectedDay!);
                        Navigator.pop(innerContext);
                      });
                    }
                  },
                )
              ],
            ));
  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit the App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Future<bool> _clearHistory() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to clear history'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('No'),
              ),
              TextButton(
                onPressed: () {
                  prefs.clear();
                  setState(() {
                    eventsClass = Events(LinkedHashMap());
                    _selectedEvents.value = _getEventsForDay(_selectedDay!);
                  });
                  Navigator.of(context).pop();
                },
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  void clearDialog() {
    _eventNameController.clear();
    selectedEventTime = TimeOfDay.fromDateTime(DateTime.now());
    newEvent = Event(
      '',
      time: TimeOfDay.fromDateTime(DateTime.now()),
      dateTime: DateTime.now(),
    );
  }

  bool checkErrors() {
    if (_eventNameController.text.isEmpty) return true;
    if (newEvent.feeling == null) return true;
    if (newEvent.eventType == null) return true;
    if (newEvent.difficulty == null) return true;
    return false;
  }

  void controlMusic(int tempIndex) {
    if (currentIndex == null) {
      _assetsAudioPlayer.playlistPlayAtIndex(tempIndex);
    } else if (tempIndex == currentIndex) {
      _assetsAudioPlayer.playOrPause();
    } else {
      _assetsAudioPlayer.pause();
      _assetsAudioPlayer.playlistPlayAtIndex(tempIndex);
    }
    currentIndex = tempIndex;
  }
}
