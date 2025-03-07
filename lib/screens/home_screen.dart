import 'package:flutter/material.dart';
import 'package:oracle/models/heat_index_data.dart';
import 'package:oracle/models/humidity_data.dart';
import 'package:oracle/widgets/map_placeholder.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/heat_index_container.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/hth_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFahrenheit = false;
  late final Humidity _humidityProvider;

  // Modified sample data generator
  Map<String, double> _generateSampleData() {
    return {
      'value': 20.0,
      'celsius': 25.0
    };
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _humidityProvider = Humidity(value: _generateSampleData()['value']!);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _humidityProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Provider.of<UserProfileProvider>(context);
    
    return Scaffold(
      backgroundColor: isDarkMode ? null : const Color(0xFFFAFAFA),
      drawer: const SidebarMenu(),
      appBar: AppBar(
        toolbarHeight: 80,
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Material(
              type: MaterialType.circle,
              clipBehavior: Clip.hardEdge,
              color: Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.menu),
                splashRadius: 24,
                constraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
        ),
        title: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Oracle',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '°',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Text(
                'Castillejos, PH',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: const [
          SizedBox(width: 48),
        ],
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Map View'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0),
                child: Column(
                  children: [
                    ChangeNotifierProvider(
                      create: (_) => HeatIndex(
                        value: _generateSampleData()['value']!,
                        celsius: _generateSampleData()['celsius']!
                      ),
                      child: Consumer<HeatIndex>(
                        builder: (context, heatIndex, _) => HeatIndexContainer(
                          heatIndex: heatIndex,
                          onSwap: () {
                            setState(() {
                              isFahrenheit = !isFahrenheit;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const HTHChart(),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
              child: const MapPlaceholder(),
            ),
          ),
        ],
      ),
    );
  }
}