import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';
import 'package:progetto/models/entities/entities.dart';
import 'package:progetto/services/server_string.dart';
import 'package:progetto/utils/shared_preferences.dart';
import '../models/db.dart';

class ImpactService {
  ImpactService(this.prefs) {
    updateBearer();
  }
  Preferences prefs;

  final Dio _dio = Dio(BaseOptions(baseUrl: ServerStrings.backendBaseUrl));

  String? retrieveSavedToken(bool refresh) {
    if (refresh) {
      return prefs.impactRefreshToken;
    } else {
      return prefs.impactAccessToken;
    }
  }

  bool checkSavedToken({bool refresh = false}) {
    String? token = retrieveSavedToken(refresh);
    //Check if there is a token
    if (token == null) {
      return false;
    }
    try {
      return ImpactService.checkToken(token);
    } catch (_) {
      return false;
    }
  }

  // this method is static because we might want to check the token outside the class itself
  static bool checkToken(String token) {
    //Check if the token is expired
    if (JwtDecoder.isExpired(token)) {
      return false;
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

    //Check the iss claim
    if (decodedToken['iss'] == null) {
      return false;
    } else {
      if (decodedToken['iss'] != ServerStrings.issClaim) {
        return false;
      } //else
    } //if-else

    //Check that the user is a patient
    if (decodedToken['role'] == null) {
      return false;
    } else {
      if (decodedToken['role'] != ServerStrings.patientRoleIdentifier) {
        return false;
      } //else
    } //if-else

    return true;
  } //checkToken

  // make the call to get the tokens
  Future<bool> getTokens(String username, String password) async {
    try {
      Response response = await _dio.post(
          '${ServerStrings.authServerUrl}token/',
          data: {'username': username, 'password': password},
          options: Options(
              contentType: 'application/json',
              followRedirects: false,
              validateStatus: (status) => true,
              headers: {"Accept": "application/json"}));

      if (ImpactService.checkToken(response.data['access']) &&
          ImpactService.checkToken(response.data['refresh'])) {
        prefs.impactRefreshToken = response.data['refresh'];
        prefs.impactAccessToken = response.data['access'];
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> refreshTokens() async {
    String? refToken = await retrieveSavedToken(true);
    try {
      Response response = await _dio.post(
          '${ServerStrings.authServerUrl}refresh/',
          data: {'refresh': refToken},
          options: Options(
              contentType: 'application/json',
              followRedirects: false,
              validateStatus: (status) => true,
              headers: {"Accept": "application/json"}));

      if (ImpactService.checkToken(response.data['access']) &&
          ImpactService.checkToken(response.data['refresh'])) {
        prefs.impactRefreshToken = response.data['refresh'];
        prefs.impactAccessToken = response.data['access'];
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> updateBearer() async {
    if (!await checkSavedToken()) {
      await refreshTokens();
    }
    String? token = await prefs.impactAccessToken;
    if (token != null) {
      _dio.options.headers = {'Authorization': 'Bearer $token'};
    }
  }

  String userImpact= 'Jpefaq6m58';

  Future<List<Ex>> getDataFromDay(DateTime startTime) async {
    await updateBearer();

    if (DateTime.now()
            .subtract(const Duration(days: 1))
            .difference(startTime)
            .inDays >
        7) {
      startTime = DateTime.now().subtract(const Duration(days: 7));
    }
    Response r;
    if (DateFormat('y-M-d').format(startTime) ==
        DateFormat('y-M-d')
            .format(DateTime.now().subtract(const Duration(days: 1)))) {
      r = await _dio.get(
          'data/v1/exercise/patients/$userImpact/day/${DateFormat('y-M-d').format(startTime)}/');

      if (r.data == null) {
        List<Ex> ex = [];

        return ex;
      } else {
        dynamic responseData = r.data['data'];

        if (responseData is List ) {
          List<dynamic> data = r.data['data'];
          List<Ex> ex = [];
          for (var daydata in data) {
            String day = daydata['date'];
            for (var dataday in daydata['data']) {
              var calories = dataday['calories']; //è in Kcal
              var duration = dataday['duration'] /
                  60000; //è in millisecondi la converto in minuti
              duration = double.parse(duration.toStringAsFixed(4));
              String activityName = dataday['activityName'];
              String hour = dataday['time'];
              String datetime = '${day}T$hour';
              DateTime timestamp = _truncateSeconds(DateTime.parse(datetime));
              Ex exnew = Ex(null, activityName, calories, duration, timestamp);
              if (!ex.any((e) => e.dateTime.isAtSameMomentAs(exnew.dateTime))) {
                ex.add(exnew);
              }
              print('Calories: $calories');
              print('Duration: $duration');
              print('Activity Name: $activityName');
              print('timestamp: $timestamp');
            }
          }

          var exlist = ex.toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return exlist;
        } else if (responseData is Map<String, dynamic>) {
          Map<String, dynamic> data = r.data['data'];
          List<Ex> ex = [];
          String day = data['date'];

          for (var value in data['data']) {
            var calories = value['calories']; //è in Kcal
            var duration = value['duration'] /
                60000; //è in millisecondi la converto in minuti
            duration = double.parse(duration.toStringAsFixed(4));
            String activityName = value['activityName'];
            String hour = value['time'];
            String datetime = '${day}T$hour';
            DateTime timestamp = _truncateSeconds(DateTime.parse(datetime));
            Ex exnew = Ex(null, activityName, calories, duration, timestamp);
            if (!ex.any((e) => e.dateTime.isAtSameMomentAs(exnew.dateTime))) {
              ex.add(exnew);
            }
            print('Calories: $calories');
            print('Duration: $duration');
            print('Activity Name: $activityName');
            print('timestamp: $timestamp');
          }

          var exlist = ex.toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
          return exlist;
        }
      }
    } else {
      r = await _dio.get(
          'data/v1/exercise/patients/$userImpact/daterange/start_date/${DateFormat('y-M-d').format(startTime)}/end_date/${DateFormat('y-M-d').format(DateTime.now().subtract(const Duration(days: 1)))}/');
      
      List<dynamic> data = r.data[
          'data']; 
      List<Ex> ex = [];
      for (var daydata in data) {
        String day = daydata['date'];
        for (var dataday in daydata['data']) {
          //qui entro nel secondo data
          var calories = dataday['calories']; //è in Kcal
          var duration = dataday['duration'] /
              60000; //è in millisecondi la converto in minuti
          duration = double.parse(duration.toStringAsFixed(4));
          String activityName = dataday['activityName'];
          String hour = dataday['time'];
          String datetime = '${day}T$hour';
          DateTime timestamp = _truncateSeconds(DateTime.parse(datetime));
          Ex exnew = Ex(null, activityName, calories, duration, timestamp);
          if (!ex.any((e) => e.dateTime.isAtSameMomentAs(exnew.dateTime))) {
            ex.add(exnew);
          }
          print('Calories: $calories');
          print('Duration: $duration');
          print('Activity Name: $activityName');
          print('timestamp: $timestamp');
        }
      }

      var exlist = ex.toList()
        ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return exlist;
    }
  throw Exception('Errore');
  }

  DateTime _truncateSeconds(DateTime input) {
    return DateTime(
        input.year, input.month, input.day, input.hour, input.minute);
  }
}


