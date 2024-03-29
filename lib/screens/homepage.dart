import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progetto/models/db.dart';
import 'package:progetto/provider/homeprovider.dart';
import 'package:progetto/methods/theme.dart';
import 'package:progetto/screens/account.dart';
import 'package:progetto/screens/analysis.dart';
import 'package:progetto/screens/contents.dart';
import 'package:progetto/screens/graphs_page.dart';
import 'package:progetto/screens/infoPage.dart';
import 'package:progetto/screens/profile.dart';
import 'package:progetto/screens/splash.dart';
import 'package:progetto/services/impact.dart';
import 'package:progetto/utils/shared_preferences.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  static const routename = 'Home Page';
  static const route = '/home/';
  final String title;
  final int initialIndex;

  const HomePage({Key? key, required this.title, this.initialIndex = 0})
      : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  String appBarTitle = 'MET';

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex; 
  }

 

  Widget _selectPage({
    required int index,
  }) {
    switch (index) {
      case 0:
        return GraphPage();
      case 1:
        return const PressurePage();
      case 2:
      return ProfilePage();
        
      case 3:
        return const Contents();
      default:
        return GraphPage();
    }
  }

  String _selectTitle({
    required int index,
  }) {
    switch (index) {
      case 0:
        return 'MET';
      case 1:
        return 'Pressure';
      case 2:
        return 'Profile';
      case 3: 
        return 'Contents';
      default:
        return 'MET';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pref = Provider.of<Preferences>(context);
    return ChangeNotifierProvider<HomeProvider>(
        create: (context) => HomeProvider(
            Provider.of<ImpactService>(context, listen: false),
            Provider.of<AppDatabase>(context, listen: false),
            Provider.of<Preferences>(context, listen: false)),
        lazy: false,
        builder: (context, child) => Scaffold(
            backgroundColor: const Color(0xFFE4DFD4),
            drawer: Drawer(
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: 150,
                    child: UserAccountsDrawerHeader(
                      accountName: Center(
                          child: Text(
                        'Hello ${pref.nickname ?? ''}',
                        style: FitnessAppTheme.subtitle,
                      )),
                      accountEmail: null,
                      decoration: const BoxDecoration(
                       
                        color: FitnessAppTheme.cream,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Wrap(
                      runSpacing: 16,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text(
                            'Information',
                            style: FitnessAppTheme.body1,
                          ),
                          onTap: () {
                           
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => InfoPage(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.account_circle),
                          title: const Text(
                            'My account',
                            style: FitnessAppTheme.body1,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => AccountPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(color: FitnessAppTheme.grey),
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text(
                            'Logout',
                            style: FitnessAppTheme.body1,
                          ),
                          onTap: () async {
                            
                            bool reset = await pref
                                .logOut(); // questo comando elimina solo usename e password dalle shared preferences
                            if (reset) {
                              Navigator.of(context)
                                  .pushReplacement(MaterialPageRoute(
                                builder: (context) => const Splash(),
                              ));
                            }
                          },
                        )
                      ],
                    ),
                  ),
                ],
              )),
            ),
            appBar: AppBar(
              title: Text(_selectTitle(index: _selectedIndex)),
              titleTextStyle: FitnessAppTheme.headline2,
              iconTheme:
                  const IconThemeData(color: FitnessAppTheme.nearlyBlack),
              elevation: 0,
              backgroundColor: FitnessAppTheme.background,
              actions: const [
                Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(
                      MdiIcons.accountCircle,
                      size: 40,
                      color: FitnessAppTheme.background,
                    )),
              ],
            ),
            body: _selectPage(index: _selectedIndex),
            bottomNavigationBar: Container(
              color: FitnessAppTheme.background,
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15.0, vertical: 12),
                  child: GNav(
                    backgroundColor: FitnessAppTheme.background,
                    color: FitnessAppTheme.deactivatedText,
                    activeColor: FitnessAppTheme.nearlyBlue,
                    tabBackgroundColor: FitnessAppTheme.dismissibleBackground,
                    gap: 8,
                    selectedIndex: _selectedIndex,
                    onTabChange: (index) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    padding: const EdgeInsets.all(16),
                    tabs: const [
                      GButton(
                        icon: Icons.home,
                        text: 'MET',
                        textStyle: FitnessAppTheme.button,
                      ),
                      GButton(
                        icon: Icons.auto_graph_outlined,
                        text: 'Pressure',
                        textStyle: FitnessAppTheme.button,
                      ),
                       GButton(
                        icon: Icons.account_circle,
                        text: 'Profile',
                        textStyle: FitnessAppTheme.button,
                      ),
                      GButton(
                        icon: Icons.description_outlined,
                        text: 'Contents',
                        textStyle: FitnessAppTheme.button,
                      ),
                     
                    ],
                  )),
            )));
  }
}
