import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_map_polyline/google_map_polyline.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'directions_provider.dart';


class Maps extends StatefulWidget {

  @override
  _MapsState createState() => _MapsState();
}

class _MapsState extends State<Maps> {
  LatLng warehousePoint = LatLng(-38.956176, -67.920666);
  LatLng destinationPoint = LatLng(-38.953724, -67.923921);
 // LatLng startLocationPoint;
  var _placeDistance;
  GoogleMapController _mapController;
 // List<LatLng> routeCoords;
  /*GoogleMapPolyline googleMapPolyline =
      new GoogleMapPolyline(apiKey: "YOUR_API_KEY");*/
 // Position startLocation;
  bool isLoading = true;

 /* getsomePoints() async {
    routeCoords = await googleMapPolyline.getCoordinatesWithLocation(
        origin: warehousePoint, // LatLng(40.6782, -73.9442),
        destination: destinationPoint, // LatLng(40.6944, -73.9212),
        mode: RouteMode.driving);
  }

  getaddressPoints() async {
    routeCoords = await googleMapPolyline.getPolylineCoordinatesWithAddress(
      origin: 'Clyde House Reform Rd Maidenhead SL6 8BY United Kingdom',
      destination:'Oldfield Guards Club Road Maidenhead SL6 8DN United Kingdom',
      mode: RouteMode.driving,
    );
  }*/

  @override
  void initState() {
    super.initState();
    isLoading = false;
  /*  getLocation().then((pos){
      print("Current Location : $pos");

      setState(() {
        startLocation = pos;
        startLocationPoint = LatLng(startLocation.latitude, startLocation.longitude);
        isLoading = false;
      });
    });*/
    // getsomePoints();
  }

  @override
  build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(child:
        Icon(Icons.arrow_back_ios,color: Colors.white, size: 25,),
          onTap:() => Navigator.pop(context),
        ),
        title:Text("Let's go!"),
      ),
      backgroundColor: Colors.deepPurple
      ,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                AlwaysStoppedAnimation<
                    Color>(
                    Colors.white),
              ),
            )
          : Consumer<DirectionProvider>(
              builder: (BuildContext context, DirectionProvider api, child) {
                return Stack(
                  children: [
                    GoogleMap(
                      mapToolbarEnabled: false,

                      mapType: MapType.normal,
                      initialCameraPosition:
                          CameraPosition(target: destinationPoint, zoom: 14.0),
                      polylines: api.currentRoute,
                      //polyline,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      onMapCreated: onMapCreated,
                      markers: _createMarkers(),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 0, screenHeight*0.02),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FloatingActionButton.extended(
                          onPressed: zoomCenter,
                          backgroundColor: Colors.grey,
                          label: Text('Zoom the points!'),
                          icon: Icon(Icons.zoom_out_map),
                        ),
                      ),
                    ),

                  ],
                );
              },
            ),
    //  floatingActionButton:
    );
  }

  onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  //  _mapController.complete(controller);

    _centerView();
    /* polyline.add(Polyline(
          polylineId: PolylineId('routeee'),
          visible: true,
          points: routeCoords,
          width: 4,
          color: Colors.blue,
          startCap: Cap.roundCap,
          endCap: Cap.buttCap));*/


  }

  Set<Marker> _createMarkers() {
    var markers = Set<Marker>();

    markers.add(
      Marker(
          onTap: (){
            warehousePoint != null ? zoomMarker(warehousePoint) : print(" ware null");
          } ,
          markerId: MarkerId("fromPoint"),
          position: warehousePoint,
          infoWindow: InfoWindow(title: "The Warehouse", snippet: "Maidenhead"),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)),
    );
  /*  if(startLocationPoint!= null ){
      markers.add(
        Marker(
            onTap: (){
              startLocationPoint != null ? zoomMarker(startLocationPoint) : print(" start null");
            } ,
            markerId: MarkerId("driverLocation"),
            position: startLocationPoint,
            infoWindow: InfoWindow(title: "You are here!"),
            icon:
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet)),
      );
    }*/

    markers.add(
      Marker(
          onTap: (){
            destinationPoint != null ? zoomMarker(destinationPoint) : print(" dest. null");
          } ,
          markerId: MarkerId("toPoint"),
          position: destinationPoint,
          infoWindow: InfoWindow(title: "Destination", snippet: "Let's go"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueRed)),
    );
    return markers;
  }


  zoomCenter() async {
    await _mapController.getVisibleRegion();
    var left = min(warehousePoint.latitude, destinationPoint.latitude);
    var right = max(warehousePoint.latitude, destinationPoint.latitude);
    var top = max(warehousePoint.longitude, destinationPoint.longitude);
    var bottom = min(warehousePoint.longitude, destinationPoint.longitude);

    var bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    _mapController.animateCamera(cameraUpdate);
  }

  _centerView() async {
    var api = Provider.of<DirectionProvider>(context, listen: false);

    await _mapController.getVisibleRegion();

    print("Center View");
    await api.findDirections(warehousePoint, destinationPoint);

    var left = min(warehousePoint.latitude, destinationPoint.latitude);
    var right = max(warehousePoint.latitude, destinationPoint.latitude);
    var top = max(warehousePoint.longitude, destinationPoint.longitude);
    var bottom = min(warehousePoint.longitude, destinationPoint.longitude);

    api.currentRoute.first.points.forEach((point) {
      left = min(left, point.latitude);
      right = max(right, point.latitude);
      top = max(top, point.longitude);
      bottom = min(bottom, point.longitude);
    });

    var bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    _mapController.animateCamera(cameraUpdate);


    double totalDistance = 0.0;

// Calculating the total distance by adding the distance
// between small segments
    for (int i = 0; i < api.currentRoute.first.points.length - 1; i++) {
      totalDistance += _coordinateDistance(
        api.currentRoute.first.points[i].latitude,
        api.currentRoute.first.points[i].longitude,
        api.currentRoute.first.points[i + 1].latitude,
        api.currentRoute.first.points[i + 1].longitude,
      );
    }

// Storing the calculated total distance of the route
    setState(() {
      _placeDistance = totalDistance.toStringAsFixed(2);
      print('DISTANCE: $_placeDistance km');
    });


  }

  zoomMarker(point) async {
    {
      await _mapController.getVisibleRegion();
      var left = point.latitude;
      var right = point.latitude;
      var top = point.longitude;
      var bottom = point.longitude;

      var bounds = LatLngBounds(
        southwest: LatLng(left, bottom),
        northeast: LatLng(right, top),
      );
      var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 70);
      _mapController.animateCamera(cameraUpdate);
    }
  }

  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
  /*Future<Position> getLocation() async {
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }*/

}
