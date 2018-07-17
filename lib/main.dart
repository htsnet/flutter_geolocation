import 'package:flutter/material.dart';
import 'package:geolocation/geolocation.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Geolocation',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Geolocation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _latitude;
  String _longitude;
  String _info = "Waiting your command...";
  bool _gotGeo;

  void _showLocation() {
    print("flag $_gotGeo");
    if (_gotGeo == true) {
        print("geo ok");
      _info = "Lat.: $_latitude   Log.: $_longitude";
    } else {
      print("geo fail");
      _info = "Geolocation fail";
    }
    print(_info);
    setState(() {
      _info;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'This is your actual geolocation:',
            ),
            Text('$_info'),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
      tooltip: 'Get geolocation',
        onPressed: ()
          {
            _latitude = "waiting...";
            _longitude = "waiting...";
            _gotGeo = false;
            _showLocation();
            _newLocation();
        },
        child: new Icon(Icons.location_on),
      ),
    );
  }

  void _newLocation() async {
    final GeolocationResult result =
    await Geolocation.requestLocationPermission(const LocationPermission(
      android: LocationPermissionAndroid.fine,
      ios: LocationPermissionIOS.always,
    ));

    if (result.isSuccessful) {
      print("ok");
      // location permission is granted (or was already granted before making the request)
    } else {
      print("err");
      // location permission is not granted
      // user might have denied, but it's also possible that location service is not enabled, restricted, and user never saw the permission request dialog
    }

    Geolocation
        .currentLocation(accuracy: LocationAccuracy.best)
        .listen((result) async {
      if (result.isSuccessful) {
        // location request successful, location is guaranteed to not be null
        _gotGeo = true;
        print(result.location.latitude.toString());
        print(result.location.longitude.toString());
        _latitude = result.location.latitude.toString();
        _longitude = result.location.longitude.toString();
        _showLocation();
        // don´t forget <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" /> in manifest
//        setState(() {
//          _latitude = result.location.latitude.toString();
//          _longitude = result.location.longitude.toString();
//        });
      } else {
        switch (result.error.type) {
          case GeolocationResultErrorType.runtime:
          // runtime error, check result.error.message
            break;
          case GeolocationResultErrorType.locationNotFound:
          // location request did not return any result
            break;
          case GeolocationResultErrorType.serviceDisabled:
          // location services disabled on device
          // might be that GPS is turned off, or parental control (android)
            break;
          case GeolocationResultErrorType.permissionDenied:
          // user denied location permission request
          // rejection is final on iOS, and can be on Android
          // user will need to manually allow the app from the settings
            break;
          case GeolocationResultErrorType.playServicesUnavailable:
          // android only
          // result.error.additionalInfo contains more details on the play services error
            switch (
            result.error.additionalInfo as GeolocationAndroidPlayServices) {
            // do something, like showing a dialog inviting the user to install/update play services
              case GeolocationAndroidPlayServices.missing:
              case GeolocationAndroidPlayServices.updating:
              case GeolocationAndroidPlayServices.versionUpdateRequired:
              case GeolocationAndroidPlayServices.disabled:
              case GeolocationAndroidPlayServices.invalid:
            }
            break;
        }
      }
    });
  }
}
