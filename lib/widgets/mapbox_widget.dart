import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CachingTileProvider extends TileProvider {
  final BaseCacheManager cacheManager;

  CachingTileProvider({BaseCacheManager? cacheManager}) 
      : cacheManager = cacheManager ?? DefaultCacheManager();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    final url = getTileUrl(coordinates, options);
    return NetworkImage(url);
  }
}

class MapboxWidget extends StatefulWidget {
  const MapboxWidget({super.key});

  // Add static method for preloading
  static Future<void> preloadMapData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('geojson_cache');
    
    if (cachedData != null) {
      return;
    }

    try {
      final response = await http.get(Uri.parse(
          'https://api.maptiler.com/data/23e6a94e-6120-4633-9dc2-a785549b5884/features.json?key=U1ZGZGT5WX7HvfCaRryf'));
      
      if (response.statusCode == 200) {
        await prefs.setString('geojson_cache', response.body);
      }
    } catch (e) {
      debugPrint('Error preloading GeoJSON: $e');
    }
  }

  @override
  State<MapboxWidget> createState() => _MapboxWidgetState();
}

class _MapboxWidgetState extends State<MapboxWidget> {
  final MapController _mapController = MapController();
  final castillejosLocation = LatLng(14.93363, 120.19785);
  List<Polygon> polygons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGeoJSON();
  }

  Future<void> loadGeoJSON() async {
    if (polygons.isNotEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('geojson_cache');
    
    if (cachedData != null) {
      processGeoJSON(json.decode(cachedData));
    }

    try {
      final response = await http.get(Uri.parse(
          'https://api.maptiler.com/data/23e6a94e-6120-4633-9dc2-a785549b5884/features.json?key=U1ZGZGT5WX7HvfCaRryf'));
      
      if (response.statusCode == 200) {
        await prefs.setString('geojson_cache', response.body);
        processGeoJSON(json.decode(response.body));
      }
    } catch (e) {
      debugPrint('Error loading GeoJSON: $e');
    }
  }

  void processGeoJSON(Map<String, dynamic> geojson) {
    final features = geojson['features'] as List;
    setState(() {
      polygons = features.map((feature) {
        final coordinates = feature['geometry']['coordinates'][0] as List;
        return Polygon(
          points: coordinates.map((coord) => LatLng(coord[1], coord[0])).toList().cast<LatLng>(),
          color: Colors.blue.withAlpha(77),
          borderColor: Colors.blue,
          borderStrokeWidth: 2,
        );
      }).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: castillejosLocation,
            initialZoom: 13,
            onMapReady: () {
              setState(() {
                isLoading = false;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://api.maptiler.com/maps/basic-v2/{z}/{x}/{y}.png?key=U1ZGZGT5WX7HvfCaRryf',
              userAgentPackageName: 'com.example.app',
              tileProvider: CachingTileProvider(),
              maxZoom: 18,
              minZoom: 1,
            ),
            PolygonLayer(
              polygons: polygons,
            ),
          ],
        ),
        if (isLoading)
          Container(
            color: Colors.white.withValues(red: 255, green: 255, blue: 255, alpha: 204),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              _buildMinimalButton(
                icon: Icons.add,
                onPressed: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom + 1,
                  );
                },
                heroTag: "zoomIn",
              ),
              const SizedBox(height: 8),
              _buildMinimalButton(
                icon: Icons.remove,
                onPressed: () {
                  _mapController.move(
                    _mapController.camera.center,
                    _mapController.camera.zoom - 1,
                  );
                },
                heroTag: "zoomOut",
              ),
              const SizedBox(height: 8),
              _buildMinimalButton(
                icon: Icons.my_location,
                onPressed: () {
                  _mapController.move(castillejosLocation, 13);
                },
                heroTag: "resetLocation",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMinimalButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String heroTag,
  }) {
    return SizedBox(
      width: 36,
      height: 36,
      child: FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        mini: true,
        elevation: 2,
        backgroundColor: const Color(0xFFE0E0E0),
        foregroundColor: const Color(0xFF424242),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}