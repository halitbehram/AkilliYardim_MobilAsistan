// todo_list_page.dart
import 'package:flutter/material.dart';
import 'package:todo_app1/FirebaseService.dart';
import 'add_task_page.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class TodoListPage extends StatefulWidget {
  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Map<String, dynamic>> tasks = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _getSavedTasks();
    _initializeNotifications();
    _requestNotificationPermission();
    // _startLocationTracking();
  }

  Future<void> _requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    // İzin isteme
    await Permission.notification.request();
  }
}

  Future<void> _getSavedTasks() async {

    final firestoreService = FirestoreService();
    String? email = await firestoreService.getUserEmail();

    final remoteTasks = await firestoreService.fetchAllDocuments(email!) as List<Map<String, dynamic>>;

    setState(() {
      tasks = remoteTasks;
    });
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _addTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddTaskPage(
          onTaskAdded: (task) async {
            final firestoreService = FirestoreService();
            setState(() {
              tasks.add(task);
            });
            String? email = await firestoreService.getUserEmail();
            await firestoreService.saveData(email!, task);
            await showNotification(task);
          },
        ),
      ),
    );
  }

  // void _startLocationTracking() async {
  //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     await Geolocator.openLocationSettings();
  //   }

  //   LocationPermission permission = await Geolocator.requestPermission();
  //   if (permission == LocationPermission.denied ||
  //       permission == LocationPermission.deniedForever) {
  //     return;
  //   }

  //   Geolocator.getPositionStream(
  //     locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
  //   ).listen((Position position) {
  //     for (var task in tasks) {
  //       if (task['latitude'] != null && task['longitude'] != null) {
  //         double distance = Geolocator.distanceBetween(
  //           position.latitude,
  //           position.longitude,
  //           task['latitude'],
  //           task['longitude'],
  //         );

  //         if (distance <= task['radius']) {
  //           _showNotification(
  //               task['title'], "Yakınındasınız: ${task['title']} konumu!");
  //         }
  //       }
  //     }
  //   });
  // }

  // Future<void> _showNotification(String title, String message) async {
  //   const AndroidNotificationDetails androidNotificationDetails =
  //       AndroidNotificationDetails(
  //     'location_channel',
  //     'Location Notifications',
  //     importance: Importance.high,
  //     priority: Priority.high,
  //   );

  //   const NotificationDetails notificationDetails =
  //       NotificationDetails(android: androidNotificationDetails);

  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     title,
  //     message,
  //     notificationDetails,
  //   );
  // }

  Future<void> showNotification(Map<String, dynamic> task) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // Kanal ID'si
      'your_channel_name', // Kanal adı
      channelDescription: 'your_channel_description', // Kanal açıklaması
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0, // ID
      'Hatırlatma', // Başlık
      task['title'], // İçerik
      platformChannelSpecifics,
    );
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Akıllı Yardım Mobil Asistan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
      ),
      body: tasks.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.notifications_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Kendine Hatırlatma Tanımla!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.deepPurple),
                    title: Text(
                      tasks[index]['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Konum: ${tasks[index]['address']} (Çap: ${(tasks[index]['radius'] / 1000).toStringAsFixed(1)} km)',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTask(index),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Hatırlatıcı Ekle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
    );
  }
}