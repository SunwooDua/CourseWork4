import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(PlanApp());
}

class TravelPlan {
  String title;
  String description;
  DateTime date;
  bool isCompleted;

  TravelPlan({
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });
}

class PlanApp extends StatelessWidget {
  const PlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PlanManagerScreen(),
    );
  }
}

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({super.key});

  @override
  State<PlanManagerScreen> createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  DateTime today = DateTime.now();
  List<TravelPlan> travelPlan = [];
  TextEditingController _eventController = TextEditingController();
  TextEditingController _descController = TextEditingController();

  void _onDaySelected(DateTime day, DateTime focusedDay) {
    setState(() {
      today = day;
    });
  }

  void addPlan(String title, String description, DateTime date) {
    if (_eventController.text.isNotEmpty && _descController.text.isNotEmpty) {
      setState(() {
        travelPlan.add(
          TravelPlan(title: title, description: description, date: date),
        );
      });
      _eventController.clear();
      _descController.clear();
    }
  }

  void deletePlan(int index) {
    setState(() {
      travelPlan.removeAt(index);
    });
  }

  void markAsCompleted(int index) {
    setState(() {
      travelPlan[index].isCompleted = true;
    });
  }

  void markAsPending(int index) {
    setState(() {
      travelPlan[index].isCompleted = false;
    });
  }

  void editPlan(int index) {
    _eventController.text = travelPlan[index].title;
    _descController.text = travelPlan[index].description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _eventController,
                decoration: InputDecoration(labelText: 'Event Name'),
              ),
              TextField(
                controller: _descController,
                decoration: InputDecoration(labelText: 'Event Description'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  travelPlan[index].title = _eventController.text;
                  travelPlan[index].description = _descController.text;
                });
                _eventController.clear();
                _descController.clear();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plan Manager'), backgroundColor: Colors.blue),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                scrollable: true,
                title: Text('Add Plan'),
                content: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      TextField(
                        controller: _eventController,
                        decoration: InputDecoration(labelText: 'Event Name'),
                      ),
                      TextField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: 'Event Description',
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      addPlan(
                        _eventController.text,
                        _descController.text,
                        today,
                      );
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text('Submit Event'),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: today,
            firstDay: DateTime.utc(2025, 3, 6),
            lastDay: DateTime.utc(2030, 12, 31),
            availableGestures: AvailableGestures.all,
            selectedDayPredicate: (day) => isSameDay(day, today),
            onDaySelected: _onDaySelected, // mark selected day
          ),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final TravelPlan plan = travelPlan.removeAt(oldIndex);
                  travelPlan.insert(newIndex, plan);
                });
              },
              children: List.generate(travelPlan.length, (index) {
                final plan = travelPlan[index];
                Color planColor =
                    plan.isCompleted ? Colors.green : Colors.white;

                return Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      markAsCompleted(index);
                    } else if (direction == DismissDirection.endToStart) {
                      markAsPending(index);
                    }
                  },
                  child: GestureDetector(
                    onDoubleTap: () => deletePlan(index),
                    onLongPress: () => editPlan(index),
                    child: Card(
                      color: planColor,
                      child: ListTile(
                        title: Text(plan.title),
                        subtitle: Text(plan.description),
                        trailing: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              plan.date.toString().split(
                                ' ',
                              )[0], // Display the date in YYYY-MM-DD format
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Icon(
                              plan.isCompleted
                                  ? Icons.check_circle
                                  : Icons.pending,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
