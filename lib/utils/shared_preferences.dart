import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  // singleton design pattern
  Future<void> init() async {
    _pref = await SharedPreferences.getInstance();
  }

  late SharedPreferences _pref;

  Future<bool> resetSettings() async {
     return _pref.clear();
   
  }

  Future<bool> logOut() async{
     _pref.remove('username');
     _pref.remove('password');
     return true;
  }

  //helper method to manage default values of preferences without the need to call the specific getType method of SharedPreferences
  dynamic _getFromDisk(String key, {dynamic defaultVal}) {
    var value = _pref.get(key);
    if (value == null) {
      _saveToDisk(key, defaultVal);
      return defaultVal;
    } else if (value is List) {
      var val = _pref.getStringList(key);
      return val;
    }
    return value;
  }

  // helper method to call the correct setType method of SharedPreferences
  void _saveToDisk<T>(String key, T content) {
    if (content is String) {
      _pref.setString(key, content);
    }
    if (content is bool) {
      _pref.setBool(key, content);
    }
    if (content is int) {
      _pref.setInt(key, content);
    }
    if (content is double) {
      _pref.setDouble(key, content);
    }
    if (content is List<String>) {
      _pref.setStringList(key, content);
    }
    if (content == null) {
      _pref.remove(key);
    }
  }



  String? get impactRefreshToken => _getFromDisk('impactRT');
  set impactRefreshToken(String? newImpactRefreshToken) =>
      _saveToDisk("impactRT", newImpactRefreshToken);

  String? get impactAccessToken => _getFromDisk('impactAccessToken');
  set impactAccessToken(String? newImpactAccessToken) =>
      _saveToDisk("impactAccessToken", newImpactAccessToken);

  String? get username => _getFromDisk('username');
  set username(String? newusername) => _saveToDisk("username", newusername);

  String? get password => _getFromDisk('password');
  set password(String? newpassword) => _saveToDisk("password", newpassword);

 String? get impactUsername => _getFromDisk('impactUsername');
  set impactUsername(String? newImpactUsername) =>
      _saveToDisk("impactUsername", newImpactUsername);

//per salvare i campi peso e altezza della pagina profile
 int? get weight => _getFromDisk('weight');
  set weight(int? newweight) => _saveToDisk("weight", newweight);

 int? get height=> _getFromDisk('height');
  set height(int? newheight) => _saveToDisk("height", newheight);

  int? get age => _getFromDisk('age');
  set age(int? newage) => _saveToDisk("age", newage);

  String? get nickname=> _getFromDisk('nickname');
  set nickname(String? newnickname) => _saveToDisk("nickname", newnickname);

  String? get email=> _getFromDisk('email');
  set email(String? newemail) => _saveToDisk("email", newemail);
}