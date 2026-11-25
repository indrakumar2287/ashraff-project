import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopping_app/route_names.dart';
import 'package:shopping_app/screens/auth/controller/auth_controller.dart';
import 'package:shopping_app/services/local_db_sf.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static final List<_HomeModule> _modules = [
    _HomeModule(
      title: 'Chat 2',
      description: 'Chat 2 ',
      icon: Icons.chat_rounded,
      color: Colors.green,
      route: RouteNames.userListChat,
    ),

    _HomeModule(
      title: 'RealTime DB',
      description: 'RealTime DB ',
      icon: Icons.chat_bubble_outline,
      color: Colors.indigo,
      route: RouteNames.realtimeDb,
    ),
    _HomeModule(
      title: 'Map',
      description: 'View your location on a map',
      icon: Icons.map_outlined,
      color: Colors.blue,
      route: RouteNames.mapScreen,
    ),
    _HomeModule(
      title: 'Chats',
      description: 'Firebase messaging',
      icon: Icons.chat_bubble_outline,
      color: Colors.indigo,
      route: RouteNames.chatList,
    ),
    _HomeModule(
      title: 'Firebase Lesson',
      description: 'Real-time collection sync',
      icon: Icons.cloud_sync_outlined,
      color: Colors.deepPurple,
      route: RouteNames.firebaseLesson,
    ),
    _HomeModule(
      title: 'Books',
      description: 'Books and details',
      icon: Icons.menu_book_outlined,
      color: Colors.deepOrange,
      route: RouteNames.booksScreen,
    ),
    _HomeModule(
      title: 'Employees',
      description: 'Add and remove names',
      icon: Icons.people_outline,
      color: Colors.teal,
      route: RouteNames.employeeScreen,
    ),
    _HomeModule(
      title: 'Images & Files',
      description: 'Pick and preview files',
      icon: Icons.perm_media_outlined,
      color: Colors.purple,
      route: RouteNames.imageWidgets,
    ),
    _HomeModule(
      title: 'GetX Widgets',
      description: 'State and navigation',
      icon: Icons.widgets_outlined,
      color: Colors.blue,
      route: RouteNames.getxWidgets,
    ),
    _HomeModule(
      title: 'Builder Widgets',
      description: 'Explore Flutter builders',
      icon: Icons.view_quilt_outlined,
      color: Colors.green,
      route: RouteNames.builders,
    ),
    _HomeModule(
      title: 'Multi Selection',
      description: 'Select several names',
      icon: Icons.checklist_outlined,
      color: Colors.cyan,
      route: RouteNames.multiSelection,
    ),
    _HomeModule(
      title: 'Search',
      description: 'Search and choose a user',
      icon: Icons.search,
      color: Colors.pink,
      route: RouteNames.search,
    ),
    _HomeModule(
      title: 'User Data',
      description: 'View user details',
      icon: Icons.badge_outlined,
      color: Colors.brown,
      route: RouteNames.userData,
    ),
    _HomeModule(
      title: 'User List',
      description: 'Browse sample users',
      icon: Icons.list_alt,
      color: Colors.blueGrey,
      route: RouteNames.userList,
    ),
    _HomeModule(
      title: 'Local Students',
      description: 'SQLite student example',
      icon: Icons.school_outlined,
      color: Colors.red,
      route: RouteNames.addStudent,
    ),
  ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    getuserNamefromLocal();
  }

  Future<void> getuserNamefromLocal() async {
    userName = await getUserName();
    setState(() {});
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'Are you sure you want to log out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    try {
      await FirebaseAuth.instance.signOut();
      Get.offAllNamed(RouteNames.loginScreen);
      LocalDb.setBool(LocalDbStrings.ISLOGIN, false);
    } on FirebaseAuthException catch (error) {
      Get.snackbar('Logout failed', error.message ?? error.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Hub'),
        actions: [
          Text(userName),

          if (user == null)
            IconButton(
              onPressed: () => Get.toNamed(RouteNames.loginScreen),
              icon: const Icon(Icons.login),
              tooltip: 'Sign in',
            )
          else
            IconButton(
              onPressed: () => _confirmLogout(context),
              icon: const Icon(Icons.logout),
              tooltip: 'Log out',
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user == null ? 'Welcome!' : 'Welcome, $userName!',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose a module to continue learning.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 700 ? 3 : 2;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    itemCount: HomeScreen._modules.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final module = HomeScreen._modules[index];
                      return _ModuleCard(
                        module: module,
                        onTap: () => Get.toNamed(module.route),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeModule {
  const _HomeModule({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module, required this.onTap});

  final _HomeModule module;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [module.color.withValues(alpha: 0.78), module.color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(module.icon, color: Colors.white, size: 28),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      module.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
