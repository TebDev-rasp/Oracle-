import 'package:flutter/material.dart';
import 'package:oracle/models/heat_index_data.dart';
import 'package:oracle/models/temperature_data.dart';
import 'package:oracle/models/humidity_data.dart';
import 'package:oracle/widgets/map_placeholder.dart';
import 'package:provider/provider.dart';
import '../widgets/sidebar_menu.dart';
import '../widgets/heat_index_container.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/temperature_container.dart';
import '../widgets/humidity_container.dart';
import '../widgets/user_avatar.dart';
import '../widgets/heat_index_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isFahrenheit = false;  // Changed from true to false
  late final Humidity _humidityProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _humidityProvider = Humidity();  // Create single instance
  }

  @override
  void dispose() {
    _tabController.dispose();
    _humidityProvider.dispose();  // Dispose of the Humidity instance
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Provider.of<UserProfileProvider>(context);
    
    return Scaffold(
      backgroundColor: isDarkMode ? null : const Color(0xFFFAFAFA),
      appBar: AppBar(
        toolbarHeight: 80,
        leading: Builder(
          builder: (context) => Container(
            margin: const EdgeInsets.all(8),
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
        title: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
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
                  fontSize: 14.0,  // Slightly smaller
                  fontWeight: FontWeight.w500,  // Slightly less bold
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        titleSpacing: NavigationToolbar.kMiddleSpacing + 20, // Adjust for the actions width
        actions: [
          SizedBox(
            width: 100, // Fixed width for actions
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    context.watch<UserProfileProvider>().username ?? 'User',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                UserAvatar(
                  size: 32,
                  onTap: () {},
                  inAppBar: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16), // Right padding
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
      drawer: const SidebarMenu(),
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
                padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 24.0), // Reduced top padding
                child: Column(
                  children: [
                    ChangeNotifierProvider(
                      create: (_) => HeatIndex(),
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
                    const HeatIndexChart(),
                    ChangeNotifierProvider(
                      create: (_) => Temperature(),
                      child: Consumer<Temperature>(
                        builder: (context, temperature, _) => TemperatureContainer(
                          temperature: temperature,
                          onSwap: () {
                            setState(() {
                              isFahrenheit = !isFahrenheit;
                            });
                          },
                        ),
                      ),
                    ),
                    ChangeNotifierProvider(
                      create: (_) => Humidity(),
                      child: Consumer<Humidity>(
                        builder: (context, humidity, _) => const HumidityContainer(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0), // Reduced top padding
              child: const MapPlaceholder(),
            ),
          ),
        ],
      ),
    );
  }
}