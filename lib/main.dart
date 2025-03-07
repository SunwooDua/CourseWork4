import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(PlanApp());
}

class TravlePlan {
  String title;
  String description;
  DateTime date;
  bool isCompleted;

  TravlePlan({
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
  List<TravlePlan> travlePlan = [];
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
        travlePlan.add(
          TravlePlan(title: title, description: description, date: date),
        );
      });
      _eventController.clear();
      _descController.clear();
    }
  }

  void deletePlan(int index) {
    setState(() {
      travlePlan.removeAt(index);
    });
  }

  void editPlan(int index) {
    _eventController.text = travlePlan[index].title;
    _descController.text = travlePlan[index].description;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          // same from below
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
                //instead of calling add plan we edit them (overwrite)
                setState(() {
                  travlePlan[index].title = _eventController.text;
                  travlePlan[index].description = _descController.text;
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
            child: ListView.builder(
              itemCount: travlePlan.length,
              itemBuilder: (context, index) {
                final plan = travlePlan[index];
                return GestureDetector(
                  onDoubleTap: () => deletePlan(index),
                  onLongPress: () => editPlan(index),
                  child: ListTile(
                    title: Text(plan.title),
                    subtitle: Text(plan.description),
                    trailing: Icon(Icons.check_box),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
