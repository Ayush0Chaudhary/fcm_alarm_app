

class TimeFormatter {
  Map<String, String> formatDate(int epochTime) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(epochTime * 1000);
    String month = dateTime.month.toString().padLeft(2, '0');
    String day = dateTime.day.toString().padLeft(2, '0');
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');

    Map<String, String> formattedDateTime = {
      "month": month,
      "day" : day,
      "hour": hour,
      "minute": minute
    };
    return formattedDateTime;
  }
}