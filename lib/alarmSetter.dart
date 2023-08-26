import 'package:alarm/alarm.dart';

class SetAlarm {
  Future<void> setAlarm(int epoch) async {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
    final alarmSettings = AlarmSettings(
      id: 42,
      dateTime: dateTime,
      assetAudioPath:
          'assets/Alarm-Fast-High-Pitch-A1-www.fesliyanstudios.com.mp3',
      loopAudio: true,
      vibrate: true,
      volumeMax: true,
      fadeDuration: 3.0,
      notificationTitle: 'Alarm',
      notificationBody: 'Wake up, time to work',
      enableNotificationOnKill: true,
    );
    await Alarm.set(alarmSettings: alarmSettings);
  }
}
