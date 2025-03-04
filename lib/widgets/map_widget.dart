import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
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

// Rename class to MapWidget
class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  // Remove preloadMapData method as it's no longer needed for OSM

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  final castillejosLocation = LatLng(14.93363, 120.19785);
  bool isLoading = true;

  @override
  void dispose() {
    _mapController.dispose();
    // Cancel any active subscriptions if you have any
    // _subscription?.cancel();
    super.dispose();
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
              urlTemplate: 'https://api.maptiler.com/maps/basic-v2/256/{z}/{x}/{y}.png?key=U1ZGZGT5WX7HvfCaRryf',
              userAgentPackageName: 'com.example.app',
              tileProvider: CachingTileProvider(),
              maxZoom: 20,
              minZoom: 1,
              additionalOptions: const {
                'attribution': '\u003ca href="https://www.maptiler.com/copyright/" target="_blank"\u003e\u0026copy; MapTiler\u003c/a\u003e',
              },
            ),
          ],
        ),
        if (isLoading)
          Container(
            color: Colors.white.withAlpha(204), // 0.8 * 255 = 204
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