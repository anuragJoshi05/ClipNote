import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clipnote/archieveView.dart';
import 'package:clipnote/settingsView.dart';
import 'package:clipnote/home.dart';
import 'package:clipnote/colors.dart';

class SideMenu extends StatefulWidget {
  final String currentRoute;

  const SideMenu({
    super.key,
    this.currentRoute = '/home',
  });

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Google Keep Dark Mode Colors
  static const Color _darkBackground = Color(0xFF202124);
  static const Color _darkSurface = Color(0xFF303134);
  static const Color _darkSurfaceVariant = Color(0xFF3C4043);
  static const Color _primaryText = Color(0xFFE8EAED);
  static const Color _secondaryText = Color(0xFF9AA0A6);
  static const Color _selectedBackground = Color(0xFFFEF7E0);
  static const Color _selectedText = Color(0xFF202124);
  static const Color _accentBlue = Color(0xFF8AB4F8);
  static const Color _accentGreen = Color(0xFF81C995);
  static const Color _accentYellow = Color(0xFFFDD663);
  static const Color _accentRed = Color(0xFFF28B82);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _darkBackground,
      elevation: 0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildMenuItems(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _accentYellow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFF202124),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Clipnote',
            style: TextStyle(
              color: _primaryText,
              fontSize: 22,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItems() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 8),
        _buildMenuItem(
          icon: Icons.lightbulb_outline,
          selectedIcon: Icons.lightbulb,
          label: 'Notes',
          destination: const Home(),
          route: '/home',
        ),
        _buildMenuItem(
          icon: Icons.notifications_none,
          selectedIcon: Icons.notifications,
          label: 'Reminders',
          destination: const Home(),
          route: '/reminders',
        ),
        const SizedBox(height: 16),
        _buildSectionDivider(),
        const SizedBox(height: 16),
        _buildMenuItem(
          icon: Icons.add,
          selectedIcon: Icons.add,
          label: 'Create new label',
          destination: const Home(),
          route: '/create-label',
          isCreateNew: true,
        ),
        const SizedBox(height: 24),
        _buildMenuItem(
          icon: Icons.archive_outlined,
          selectedIcon: Icons.archive,
          label: 'Archive',
          destination: const ArchieveView(),
          route: '/archive',
        ),
        _buildMenuItem(
          icon: Icons.delete_outline,
          selectedIcon: Icons.delete,
          label: 'Trash',
          destination: const ArchieveView(),
          route: '/trash',
        ),
        const SizedBox(height: 24),
        _buildMenuItem(
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings,
          label: 'Settings',
          destination: const Settingsview(),
          route: '/settings',
        ),
        _buildMenuItem(
          icon: Icons.help_outline,
          selectedIcon: Icons.help,
          label: 'Help & feedback',
          destination: const Settingsview(),
          route: '/help',
        ),
      ],
    );
  }

  Widget _buildSectionDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 1,
      color: _darkSurfaceVariant,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required Widget destination,
    required String route,
    bool isCreateNew = false,
  }) {
    final isSelected = widget.currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleNavigation(context, destination, route),
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? _selectedBackground : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? selectedIcon : icon,
                  size: 24,
                  color: isSelected
                      ? _selectedText
                      : isCreateNew
                      ? _secondaryText
                      : _primaryText,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isSelected
                          ? _selectedText
                          : isCreateNew
                          ? _secondaryText
                          : _primaryText,
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _handleNavigation(BuildContext context, Widget destination, String route) {
    // Light haptic feedback like Google Keep
    HapticFeedback.lightImpact();

    // Close drawer first
    Navigator.pop(context);

    // Only navigate if different route
    if (widget.currentRoute != route) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => destination,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Google Keep style fade transition
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 200),
        ),
      );
    }
  }
}