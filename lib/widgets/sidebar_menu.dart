import 'package:flutter/material.dart';
import 'package:oracle/screens/home_screen.dart';
import 'package:oracle/widgets/user_avatar_edit.dart';
import 'package:provider/provider.dart';
import 'package:oracle/screens/record_screen.dart';
import 'sign_out_tile.dart';
import 'user_avatar.dart';
import 'delete_account_tile.dart';
import '../providers/user_profile_provider.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Drawer(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(2)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 20, bottom: 20, left: 80, right: 80),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDarkMode ? Colors.blue : Colors.blue.shade700,
                            width: 3.0,
                          ),
                        ),
                        child: UserAvatar(
                          size: 160,
                          onTap: () {},
                        ),
                      ),
                      Positioned(
                        right: -20,
                        bottom: -20,
                        child: AvatarEditMenu(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.watch<UserProfileProvider>().username ?? 'User',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.home_outlined,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    title: Text(
                      'Home',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                    selected: ModalRoute.of(context)?.settings.name == '/',
                    selectedTileColor: isDarkMode 
                        ? Colors.blue.withAlpha(51)
                        : Colors.purple.withAlpha(26),
                    onTap: () {
                      if (ModalRoute.of(context)?.settings.name == '/') {
                        Navigator.pop(context); // Just close drawer if already on home
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                            settings: const RouteSettings(name: '/'),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.history,
                      color: isDarkMode ? Colors.white54 : Colors.black54,
                    ),
                    title: Text(
                      'Record',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    selected: ModalRoute.of(context)?.settings.name == '/record',
                    selectedTileColor: isDarkMode 
                        ? Colors.blue.withAlpha(51)
                        : Colors.purple.withAlpha(26),
                    onTap: () {
                      if (ModalRoute.of(context)?.settings.name == '/record') {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RecordScreen(),
                            settings: const RouteSettings(name: '/record'),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),            DeleteAccountTile(),
            const SignOutTile(),
          ],
        ),
      ),
    );
  }
}