import 'package:alarm/alarm.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notif_alarm/alarmSetter.dart';
import 'package:notif_alarm/notif_services.dart';
import 'package:notif_alarm/utils.dart';
import 'firebase_options.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // final fcmToken = await FirebaseMessaging.instance.getToken();
  // print(fcmToken);
  //TODO: start here
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  // FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
  //TODO:end here

  await Alarm.init();
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestPermission();
  runApp(const MyApp());
}

void onDidReceiveNotificationResponse() {
  print('onDidReceiveNotificationResponse');
}

void onDidReceiveLocalNotification(
    int id, String title, String body, String payload) async {
  // display a dialog with the notification details, tap ok to go to another page
  print('onDidReceiveLocalNotification');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String dateTime = DateTime.now().add(const Duration(seconds: 20)).toString();
  NotificationService ns = NotificationService();
  SetAlarm alarmSetting = SetAlarm();
  String day = "Not Specified";
  String hour = "Not Specified";
  String month = "Not Specified";
  String minute = "Not Specified";

  Future<void> setupInteractedMessage() async {
    // at terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      ns.triggerLocalNotif('Terminated App message', 'Terminated');
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    print(message);
    print(message.data['time']);
    if (message.data.isNotEmpty) {
      TimeFormatter tf = TimeFormatter();

      int epoch = int.parse(message.data['time']);

      alarmSetting.setAlarm(epoch);
      Map<String, String> alarmTime = tf.formatDate(epoch);
      setState(() {
        day = alarmTime['day']!;
        month = alarmTime['month']!;
        hour = alarmTime['hour']!;
        minute = alarmTime['minute']!;
      });
    }
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Got the notiff')));
  }

  void handleForeGroundNotif() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // NotificationService ns = NotificationService();
      int epoch = int.parse(message.data['time']);
      TimeFormatter timeFormatter = TimeFormatter();
      SetAlarm setAlarm = SetAlarm();
      setAlarm.setAlarm(epoch);
      Map<String, String> alarmData = timeFormatter.formatDate(epoch);
      ns.triggerLocalNotif('New Alarm',
          'Alarm set for ${alarmData['day']}/${alarmData['month']} at ${alarmData['hour']}:${alarmData['minute']}');
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      setState(() {
        day = alarmData['day']!;
        month = alarmData['month']!;
        hour = alarmData['hour']!;
        minute = alarmData['minute']!;
      });
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setupInteractedMessage();
    handleForeGroundNotif();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Notif Alarm App'),
            backgroundColor: Colors.blue,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Day-Month'),
                Text('$day-$month'),
                const Text('hour-minute'),
                Text('$hour-$minute'),
                TextButton(
                    onPressed: () async {
                      final fcmToken = await FirebaseMessaging.instance.getToken();
                      print(fcmToken);
                    },
                    style: ButtonStyle(backgroundColor:
                        MaterialStateProperty.resolveWith((states) {
                      return Colors.blue;
                    })),
                    child: Text('sda')),
              ],
            ),
          )),
    );
  }
}
