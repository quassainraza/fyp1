import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';

import 'package:geocoding/geocoding.dart';
import 'package:google_place/google_place.dart';
import 'package:provider/provider.dart';
import '../global/global.dart';
import '/geometry.dart';
import '/location.dart';
import '/place.dart';
import '/blocs/app_blocs.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import '/geolocation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:requests/requests.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';


const kGoogleApiKey = "AIzaSyArtrJGGyuWasmlZ1rcmovSoCkl7zJWgIE";
Set<Polyline> polylines = Set<Polyline>();
List<LatLng> polylinecordinates = [];
PolylinePoints polylinePoints = PolylinePoints();

Marker testmarker=Marker(markerId: MarkerId('fastMarker'));
Place? mylocation;
double? gpslat,gpslong;



class Map extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => appbloc(),
      child: MaterialApp(
        title: 'Flutter Google Maps Demo',
        home: MapSample(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

final homeScaffoldKey = GlobalKey<ScaffoldState>();
final searchScaffoldKey = GlobalKey<ScaffoldState>();

class MapSampleState extends State<MapSample> {
  var msgController = TextEditingController();
  var sourceController = TextEditingController();

  double rad=600 ;

  @override
  void dispose() {
    msgController.dispose();
    sourceController.dispose();
    super.dispose();
  }

  late GoogleMapController newgoogleMapController;
  late final GoogleMapController controller;
 final Completer<GoogleMapController> _controller = Completer();



 LocationPermission? locationPermission;

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  //camera position at start

  blackThemeGoogleMap()
  {
    newgoogleMapController!.setMapStyle('''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#242f3e"
                          }
                        ]
                      },
                      {
                        "featureType": "administrative.locality",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#263c3f"
                          }
                        ]
                      },
                      {
                        "featureType": "poi.park",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#6b9a76"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#38414e"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#212a37"
                          }
                        ]
                      },
                      {
                        "featureType": "road",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#9ca5b3"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#746855"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "geometry.stroke",
                        "stylers": [
                          {
                            "color": "#1f2835"
                          }
                        ]
                      },
                      {
                        "featureType": "road.highway",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#f3d19c"
                          }
                        ]
                      },
                      {
                        "featureType": "transit",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#2f3948"
                          }
                        ]
                      },
                      {
                        "featureType": "transit.station",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#d59563"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.fill",
                        "stylers": [
                          {
                            "color": "#515c6d"
                          }
                        ]
                      },
                      {
                        "featureType": "water",
                        "elementType": "labels.text.stroke",
                        "stylers": [
                          {
                            "color": "#17263c"
                          }
                        ]
                      }
                    ]
                ''');
  }

  allowPermissionforlocation() async {
    locationPermission  = await Geolocator.requestPermission();
    if(locationPermission == LocationPermission.denied){
      locationPermission  = await Geolocator.requestPermission();
    }


  }

  UserisonlineNow() async {

    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high

    );

    userCurrentPosition =pos;

     Geofire.initialize("ActiveUsers");
    Geofire.setLocation(currentfirebaseuser!.uid, userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    DatabaseReference ref = FirebaseDatabase.instance.ref()
        .child("Users")
        .child(currentfirebaseuser!.uid)
        .child("Status");
    ref.set("Online");
    ref.onValue.listen((event) { });
  }
  UpdateUserLocationinRealtime(){

    streamSubscription = Geolocator.getPositionStream()
        .listen((Position position)
    {
      userCurrentPosition = position;
      if(isUserActive ==true){
        Geofire.setLocation(currentfirebaseuser!.uid, userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      }
      LatLng latLng = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

      controller!.animateCamera(CameraUpdate.newLatLng(latLng));
    });

  }

  UserisOfflineNow(){
    Geofire.removeLocation(currentfirebaseuser!.uid);
    DatabaseReference? ref = FirebaseDatabase.instance.ref()
        .child("Users")
        .child(currentfirebaseuser!.uid)
        .child("Status");
    ref.onDisconnect();
    ref.remove();
    ref = null;
    Future.delayed(const Duration(milliseconds: 2000),(){
      SystemChannels.platform.invokeMethod("SystemNavigator.pop");
    });

  }

  var address;
  static String latitude =
      ""; //to declare any variable just statically declare here
  //and use in downward init function and initilize it there simple
  static String longitude = "";
  static Set<Circle> mycircles = Set.from([Circle(circleId: CircleId('1'))]);
  static Marker _kGooglePlexMarker = Marker(markerId: MarkerId('GooglePlex'));
  static Marker _fastMarker = Marker(markerId: MarkerId('fastMarker'));
  //made static because giving initilzer error
  late StreamSubscription locationSubscription;
  late StreamSubscription boundsSubscription;
  final _locationController = TextEditingController();
  Position? userCurrentPosition;
  static String mysource = "";
  String statustext="Now Offline";
  Color statusbuttoncolor= Colors.grey;
  bool isUserActive = false;

  @override
  void initState() {
    super.initState();
    allowPermissionforlocation();
    final applicationBloc = Provider.of<appbloc>(context, listen: false);
    locationSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      if (place != null) {
        _locationController.text = place.name;
        _goToTheDestination(place);
      } else
        _locationController.text = "";
    });
    getLocation();
  } //to run getlocation when code starts

  getLocation() async {
    var pos = determinePosition(); //if pos is error then
    pos.catchError(print);
    //if determinePOSITION goes in error we will handle in upper else
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = position;
    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
     final CameraPosition cameraPosition = CameraPosition(
        target:latLngPosition , //going to that cordinates which were given by my function of geolocation
        zoom: 14);
    controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String mapKey = "AIzaSyArtrJGGyuWasmlZ1rcmovSoCkl7zJWgIE";
    //var param = LatLng(position.latitude, position.longitude);
    var karam1 = position.latitude;
    var karam2 = position.longitude;
    String kar1 = karam1.toString();
    String kar2 = karam2.toString();
    String param;
    param = kar1 + "," + kar2;
    String autoCompleteUrl =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$param&key=$mapKey";
    var res = await http.get(Uri.parse(autoCompleteUrl));
    var json = convert.jsonDecode(res.body);
    mysource = json['results'][0]['formatted_address'];
    // print(json['results'][0]['formatted_address'].runtimeType);
    setState(() {
      latitude = '${position.latitude}';
      longitude =
          '${position.longitude}'; //latitude and longitude variables are getting updated here
      final lat = latitude;
      final long = longitude;
      mycircles = Set.from([
        Circle(
          circleId: CircleId('1'),
          center: LatLng(double.parse(lat), double.parse(long)),
          radius: rad,
          fillColor: Color.fromARGB(255, 33, 141, 132).withOpacity(0.5),
          strokeColor:  Colors.blue.shade100.withOpacity(0.1),
        )
      ]);

      gpslat=double.parse(lat);
      gpslong=double.parse(long);

      _kGooglePlexMarker = Marker(
        markerId: MarkerId('GooglePlex'),
        infoWindow: InfoWindow(title: mysource),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(double.parse(latitude), double.parse(longitude)),
      );



    testmarker =
    Marker(
      markerId: MarkerId(""),
      infoWindow: InfoWindow(),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(double.parse(latitude)+0.05, double.parse(longitude)), //hard coded for fast rn
    );


      _fastMarker = Marker(
        markerId: MarkerId('Fast_Marker'),
        infoWindow: InfoWindow(title: 'My Destination'),
        icon: BitmapDescriptor.defaultMarker,
        position: LatLng(33.6561535, 73.0135573), //hard coded for fast rn
      );
    });
  }





double calculateDistance(lat1, lon1, lat2, lon2){
  var p = 0.017453292519943295;
  var a = 0.5 - cos((lat2 - lat1) * p)/2 + 
        cos(lat1 * p) * cos(lat2 * p) * 
        (1 - cos((lon2 - lon1) * p))/2;
  return 12742 * asin(sqrt(a));
}


  void setPolylines() async {
    print("Source lat is ");
    print(_kGooglePlexMarker.position.latitude);
    print("Source lang is :");
    print(_kGooglePlexMarker.position.longitude);
    print("Fast lat");
    print(_fastMarker.position.latitude);
    print("fast lang is ");
    print(_fastMarker.position.longitude);

    PolylineResult presult = await polylinePoints.getRouteBetweenCoordinates(
        kGoogleApiKey,
        PointLatLng(_kGooglePlexMarker.position.latitude,
            _kGooglePlexMarker.position.longitude), //source
        PointLatLng(
            _fastMarker.position.latitude, _fastMarker.position.longitude));

      
      
      


    if (presult.status == 'OK') {
      print(
          "OKOKOKOKOKOKOOKOKOKOKOKOKKOKOKO\nOKOKOKOKOKOKOKOKOKOKOKOKOKOKOKO\nOKOKOKOKOKOKOKOKOKOKOOKOKOKOKOKOKOKOKKKOKOKOK");
      presult.points.forEach((PointLatLng point) {
        polylinecordinates.add(LatLng(point.latitude, point.longitude));
      });


      double totalDistance = 0;
        for(var i = 0; i < polylinecordinates.length-1; i++){
            totalDistance += calculateDistance(
                polylinecordinates[i].latitude, 
                polylinecordinates[i].longitude, 
                polylinecordinates[i+1].latitude, 
                polylinecordinates[i+1].longitude);
        }

        print("DISTANCE");
        print(totalDistance);



      setState(() {
        polylines.add(Polyline(
          width: 8,
          polylineId: PolylineId('PolyLine'),
          color: Colors.blueGrey,
          points: polylinecordinates,
        ));
      });
    } else {
      print(
          "NOT\nOKOKOKOKOKOKOOKOKOKOKOKOKKOKOKO\nOKOKOKOKOKOKOKOKOKOKOKOKOKOKOKO\nOKOKOKOKOKOKOKOKOKOKOOKOKOKOKOKOKOKOKKKOKOKOK");
    }
  }

  @override
  Widget build(BuildContext context) {
    final applicationbloc = Provider.of<appbloc>(context);

    print(Geolocator.distanceBetween(_kGooglePlexMarker.position.latitude, _kGooglePlexMarker.position.longitude, 
    testmarker.position.latitude, testmarker.position.longitude));

    return new Scaffold(
      appBar: AppBar(
        title: Text("hello"),
      ),
      drawer: Drawer(),
      key: homeScaffoldKey,
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 40.0,
          ),
          
          Column(

            children: [

              //   Container(
              //   margin: EdgeInsets.all(20),
              //   child: TextField(
              //     onChanged: (value) {
              //       applicationbloc.searchPlaces(value);
              //     },
              //     controller: sourceController,
              //     decoration: InputDecoration(
              //         hintText: 'Search...',
              //         border: OutlineInputBorder(
                        
              //           ),
              //         ),
              //   ),
              // ),
              
              // Container(
              //   margin: EdgeInsets.all(20),
              //   child: TextField(
              //     onChanged: (value) {
              //       applicationbloc.searchPlaces(value);
              //     },
              //     controller: msgController,
              //     decoration: InputDecoration(
                    
              //         hintText: 'Search...',
              //         border: OutlineInputBorder(
                        
              //           ),
              //         ),
              //   ),
              // ),

              // Container(
              //   child: SliderTheme(
              //     data: SliderThemeData(

              //       valueIndicatorColor: Colors.green,
              //       activeTrackColor:Colors.green,
              //       inactiveTrackColor: Colors.green.shade100,
              //       inactiveTickMarkColor: Colors.red,
              //       thumbColor: Colors.green,
              //       valueIndicatorShape: PaddleSliderValueIndicatorShape(),
              //       // thumbShape: 

              //       ),
              //     child: SizedBox(
              //       width: 250,
              //       child: Slider(

              //         divisions: 10,
              //         value: rad.toDouble(),
              //         min: 0,
              //         max:600,
                      
                    
                    
              //         label: rad.round().toString(),
              //         onChanged: (double value)=> setState((){
              //               rad=value;
              //                 mycircles = Set.from([
              //             Circle(
              //               circleId: CircleId('1'),
              //               center: LatLng(gpslat!, gpslong!),
              //               radius: rad,
              //               fillColor: Color.fromARGB(255, 33, 141, 132).withOpacity(0.5),
              //               strokeColor:  Colors.blue.shade100.withOpacity(0.1),
              //             )
              //           ]);
              //         }
              //         ),
              //       ),
              //     ),
              //   ),
              // ),




              // TextButton(
              //   onPressed:() {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(builder: (context) => const radius()),
              //     );
              //   }, 
              //   child: Text("Set Radius"))
            ],
          ),

          

          Stack(
            children: [

              Container(
                  height: 500,
                  child: GoogleMap(
                    onLongPress: addmarker,
                    markers: {_kGooglePlexMarker, _fastMarker,testmarker},
                    polylines: polylines,
                    mapType: MapType.normal,
                    initialCameraPosition: _kGooglePlex,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      newgoogleMapController = controller;
                      //black theme for google maps
                      blackThemeGoogleMap();
                      //  setPolylines();
                    },
                    myLocationEnabled: true, //for blue dot
                    circles: mycircles,

                  )),





              if (applicationbloc.searchResults.length != 0)
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(.6),
                    backgroundBlendMode: BlendMode.darken,
                  ),
                ),
              if (applicationbloc.searchResults.length != 0)
                Container(
                  height: 300,
                  child: ListView.builder(
                      itemCount: applicationbloc.searchResults
                          .length, //now search results can be none so
                      itemBuilder: ((context, index) {
                        return ListTile(
                          title: Text(
                            applicationbloc.searchResults[index].description,
                            style: TextStyle(
                                color: Color.fromARGB(255, 253, 253, 253)),
                          ),
                          onTap: () {
                            //make textfields null
                            polylinecordinates = [];
                            // setPolylines();
                            msgController.clear();
                            applicationbloc.setSelectedLocation(
                                applicationbloc.searchResults[index].placeId);
                          },
                        );
                      })),
                ),
              if(statustext!="Now Online")
                Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  color: Colors.black38,

                )
              else
                Container(),
              Positioned(
                top: statustext != "Now Online" ? MediaQuery.of(context).size.height * 0.45 : 25,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed:(){


                        if(isUserActive != true)//offline
                           {
                          UserisonlineNow();
                          UpdateUserLocationinRealtime();

                          setState(() {
                            statustext = "Now Online";
                            isUserActive= true;
                          });
                          Fluttertoast.showToast(msg: "You are online now!");
                        }
                        else{
                          UserisOfflineNow();
                          setState(() {
                            statustext = "Now Offline";
                            isUserActive= false;
                          });
                          Fluttertoast.showToast(msg: "You are offline now!");

                        }
                      },

                      style: ElevatedButton.styleFrom(
                          primary: statusbuttoncolor,
                          padding:const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          )
                      ),
                      child: statustext != "Now Online" ?
                      Text(
                        statustext,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,

                        ),
                      ):
                      const Icon(
                        Icons.phonelink_ring,
                        color: Colors.white,
                        size: 26,
                      ),

                    )
                  ],
                ),
              )
              
            ],
          ),






        ]),
      ),
      /*floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('My Location'),
        icon: Icon(Icons.location_searching),
      )*/
    );
  }

  void addmarker(LatLng pos) {
    setState(() {
      _fastMarker = Marker(
        markerId: MarkerId('Fast_Marker'),
        infoWindow: InfoWindow(title: 'My Destination'),
        icon: BitmapDescriptor.defaultMarker,
        position: pos, //hard coded for fast rn
      );
    });
    polylinecordinates = [];
    setPolylines();
  }

  Future<void> _goToTheLake() async {
    getLocation();

  }




  Future<void> _goToTheDestination(Place place) async {
    final GoogleMapController controller = await _controller.future;
    final CameraPosition destination = CameraPosition(
        target:
            LatLng(place.geometry.location.lat, place.geometry.location.lng),
        zoom: 14.0);
    controller.animateCamera(CameraUpdate.newCameraPosition(destination));

    _fastMarker = Marker(
      markerId: MarkerId(place.name),
      infoWindow: InfoWindow(title: place.name),
      icon: BitmapDescriptor.defaultMarker,
      position: LatLng(place.geometry.location.lat,
          place.geometry.location.lng), //hard coded for fast rn
    );



    mylocation=place;

    

    Marker(markerId: MarkerId('fastMarker'));
    // so hum screen ko legae +
    //humne udhar marker bh rkhdia
    polylinecordinates = [];
    setPolylines();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// WE HAVE DONE GET MY LOCATION TILL HERE

//

// i will be following this : https://www.youtube.com/watch?v=QP4FCi9MgHU

class radius extends StatefulWidget {
  const radius({ Key? key }) : super(key: key);

  @override
  State<radius> createState() => _radiusState();
}

class _radiusState extends State<radius> {
double value1=100;
      
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("hello"),
      ),
      drawer: Drawer(),
      body: Column(
          
          children: [

            Container
            (
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Go back!'),
              ),
            ),

            Container(
              child: SliderTheme(
                data: SliderThemeData(

                  valueIndicatorColor: Colors.green,
                  activeTrackColor:Colors.green,
                  inactiveTrackColor: Colors.green.shade100,
                  inactiveTickMarkColor: Colors.red,
                  thumbColor: Colors.green,
                  valueIndicatorShape: PaddleSliderValueIndicatorShape(),
                  // thumbShape: 

                  ),
                child: Slider(
                  value: value1,
                  min: 0,
                  max:100,
                  divisions: 10,
                 
                 
                  label: value1.round().toString(),
                  onChanged: (value)=> setState(()=>this.value1=value),
                ),
              ),

            ),
            Container(
              child:Text(value1.toString()),
            ),

          ],

        ),
      // body: Center(

        
      //   child: ElevatedButton(
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //     child: const Text('Go back!'),
      //   ),
      
      
      // ),

    
          
      
       
    );
  }
}