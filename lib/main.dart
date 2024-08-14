import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String yourLoc = "Lokasi Saat Ini Belum ditentukan";
  bool showDialog = false;
  final double latitudePin = -6.170535;
  final double longitudePin = 106.813383;
  final double jarakMaks = 50.0;
  Future<void> getCurrentLocation() async {
    //nilai ijin true or flase
    bool valuePermission = false;
    //izin akses lokasi 
    while (!valuePermission) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        //Jika Izin Ditolak Selamanya
        if (permission == LocationPermission.deniedForever) {
          AwesomeDialog(
          context: context,
          animType: AnimType.scale,
            dialogType: DialogType.error,
            body: Center(child: Text(
                    "Aplikasi ini membutuhkan ijin akses lokasi !",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),),
            title: 'Pengaturan Ijin',
            desc:   'Terimakasih',
            btnOkOnPress: () {},
            )..show();
            return ;
        }
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        valuePermission = true;
      }else{
        AwesomeDialog(
          context: context,
          animType: AnimType.scale,
            dialogType: DialogType.error,
            body: Center(child: Text(
                    "Aplikasi Ini Membutuhkan Ijin Akses Lokasi",
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),),
            title: 'Gagal',
            desc:   'Terimakasih',
            btnOkOnPress: () {},
            )..show();
            permission = await Geolocator.requestPermission();
      }
    }

    //ambil lokasi saat absen 
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    double distanceInMeters = Geolocator.distanceBetween(
      position.latitude, position.longitude, latitudePin, longitudePin);

    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    Placemark placemark = placemarks[0];
    double distanceInKm = (distanceInMeters/1000);
    String distanceKmString = distanceInKm.toStringAsFixed(2);
    String address = "${placemark.name}, ${placemark.street}, ${placemark.locality}, ${placemark.country},\n Jarak Anda dari titik ${distanceKmString} KM";


    setState(() {
      yourLoc = "Posisi Anda Saat Ini :\n ${address}"; 
      if (distanceInMeters <= jarakMaks) {
        AwesomeDialog(
          context: context,
          animType: AnimType.scale,
            dialogType: DialogType.success,
            body: Center(child: Text(
                    'Absen Berhasil',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),),
            title: 'Sukses',
            desc:   'Terimakasih',
            btnOkOnPress: () {},
            )..show();
      } else {
       AwesomeDialog(
          context: context,
          animType: AnimType.scale,
            dialogType: DialogType.error,
            body: Center(child: Text(
                    yourLoc,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),),
            title: 'Gagal',
            desc:   'Terimakasih',
            btnOkOnPress: () {},
            )..show();
      }  
    });
  }
  
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
           children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: (){
                    getCurrentLocation();
                  },
                   child: Text("Ambil Absen",
                   style:TextStyle(
                    fontSize: w*0.05,
                    
                   )
                   ),
                  ),
              ],
            ),
             
          ],
        ),
      ),
     );
  }
}
