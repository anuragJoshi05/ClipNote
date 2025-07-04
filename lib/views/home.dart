import 'dart:math';
import 'package:clipnote/views/SideMenuBar.dart';
import 'package:clipnote/views/colors.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/views/searchPage.dart';
import 'package:clipnote/services/account_switcher.dart';
import 'package:clipnote/services/auth.dart';
import 'package:clipnote/services/db.dart';
import 'package:clipnote/services/firestore_db.dart';
import 'package:clipnote/services/loginInfo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:clipnote/views/noteView.dart';
import 'package:clipnote/views/createNoteView.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:clipnote/views/smart_daily_note_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isStaggered = true;
  bool isLoading = true;
  List<Note> notesList = [];
  String? imgUrl;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final List<Color> borderColors = [
    Colors.red.withOpacity(0.6),
    Colors.green.withOpacity(0.6),
    Colors.blue.withOpacity(0.6),
    Colors.yellow.withOpacity(0.6),
    Colors.orange.withOpacity(0.6),
    Colors.purple.withOpacity(0.6),
    Colors.pink.withOpacity(0.6),
    Colors.teal.withOpacity(0.6),
    Colors.indigo.withOpacity(0.6),
    Colors.cyan.withOpacity(0.6),
    Colors.amber.withOpacity(0.6),
    Colors.lime.withOpacity(0.6),
    Colors.brown.withOpacity(0.6),
    Colors.grey.withOpacity(0.6),
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    // Load user image first (fast operation)
    _loadUserImage();

    // Then load notes
    await getAllNotes();

    // Remove sync button functionality
    LocalDataSaver.saveSyncSet(false);
  }

  void _loadUserImage() {
    LocalDataSaver.getImg().then((value) {
      if (mounted) {
        setState(() {
          imgUrl = value;
        });
      }
    });
  }

  void _navigateToSmartDaily() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmartDailyNotePage(
          onNoteCreated: (note) async {
            await getAllNotes();
          },
        ),
      ),
    );
  }

  Future<List<GoogleSignInAccount>> getGoogleAccounts() async {
    try {
      await googleSignIn.signInSilently();
      return googleSignIn.currentUser != null
          ? [googleSignIn.currentUser!]
          : [];
    } catch (error) {
      print('Error getting Google accounts: $error');
      return [];
    }
  }

  Future<void> getAllNotes() async {
    if (!mounted) return;

    try {
      // Show loading only if we don't have notes yet
      if (notesList.isEmpty) {
        setState(() {
          isLoading = true;
        });
      }

      // Get local notes first for quick display
      List<Note> localNotes = await NotesDatabase.instance.readAllNotes();

      // Get Firestore notes
      final User? user = await LoginInfo().getCurrentUser();
      List<Note> firestoreNotes = [];

      if (user?.email != null) {
        try {
          firestoreNotes =
              await FireDB().getAllStoredNotesForUser(user!.email!);
        } catch (e) {
          print('Error loading Firestore notes: $e');
        }
      }

      // Combine notes and remove duplicates (prefer Firestore version)
      Map<int, Note> uniqueNotes = {};

      for (Note note in firestoreNotes) {
        uniqueNotes[note.id ?? note.hashCode] = note;
      }

      // Convert to list and sort (pinned first, then by date)
      List<Note> finalNotes = uniqueNotes.values.toList();
      finalNotes.sort((a, b) {
        if (a.pin && !b.pin) return -1;
        if (!a.pin && b.pin) return 1;
        return b.createdTime.compareTo(a.createdTime);
      });

      if (mounted) {
        setState(() {
          notesList = finalNotes;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error in getAllNotes: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> createEntry(Note note) async {
    await NotesDatabase.instance.insertEntry(note);
    await getAllNotes();
  }

  Future<void> readOneNote(int id) async {
    await NotesDatabase.instance.readOneNote(id);
  }

  Future<void> updateOneNote(Note note) async {
    await NotesDatabase.instance.updateNote(note);
    await getAllNotes();
  }

  Future<void> deleteNote(Note note) async {
    await NotesDatabase.instance.deleteNote(note);
    await getAllNotes();
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await getAllNotes();
  }

  void _toggleView() {
    HapticFeedback.selectionClick();
    setState(() {
      isStaggered = !isStaggered;
    });
  }

  Future<void> _navigateToCreateNote() async {
    HapticFeedback.mediumImpact();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNoteview()),
    );

    // Refresh notes when returning from create note
    if (result != null || mounted) {
      await getAllNotes();
    }
  }

  Future<void> _navigateToNoteView(int index) async {
    HapticFeedback.selectionClick();
    final updatedNote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteView(
          note: notesList[index],
          onNoteUpdated: (Note updatedNote) {
            // Update the specific note in the list
            setState(() {
              notesList[index] = updatedNote;
            });
          },
        ),
      ),
    );

    // Refresh notes when returning from note view
    if (updatedNote != null || mounted) {
      await getAllNotes();
    }
  }

  void _openDrawer() {
    HapticFeedback.lightImpact();
    _scaffoldKey.currentState?.openDrawer();
  }

  void _navigateToSearch() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  Future<void> _showAccountSwitcher() async {
    HapticFeedback.lightImpact();
    final accounts = await getGoogleAccounts();
    if (mounted) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => AccountSwitcher(accounts: accounts),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          _navigateToSmartDaily();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: bgColor,
        drawer: SideMenu(),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "smart_daily",
              onPressed: _navigateToSmartDaily,
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.auto_awesome, size: 24),
            ),
            const SizedBox(height: 16),
            FloatingActionButton(
              heroTag: "add_note",
              onPressed: _navigateToCreateNote,
              backgroundColor: Colors.orangeAccent,
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, size: 28),
            ),
          ],
        ),
        body: SafeArea(
          child: isLoading && notesList.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                    strokeWidth: 3,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  backgroundColor: cardColor,
                  color: Colors.orangeAccent,
                  strokeWidth: 2.5,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader()),
                      SliverToBoxAdapter(child: _buildSectionTitle()),
                      _buildNotesGrid(),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100), // Space for FAB
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 56,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _openDrawer,
            icon: const Icon(Icons.menu, color: Colors.white),
            splashRadius: 24,
          ),
          Expanded(
            child: GestureDetector(
              onTap: _navigateToSearch,
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.grey[400], size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Search notes',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _toggleView,
            icon: Icon(
              isStaggered ? Icons.view_list : Icons.grid_view,
              color: Colors.white,
            ),
            splashRadius: 24,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: _showAccountSwitcher,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[700],
                backgroundImage: imgUrl != null ? NetworkImage(imgUrl!) : null,
                child: imgUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'ALL',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          if (notesList.isNotEmpty)
            Text(
              '${notesList.length} notes',
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotesGrid() {
    if (notesList.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: isStaggered
          ? SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childCount: notesList.length,
              itemBuilder: (context, index) => _buildNoteCard(index),
            )
          : SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildNoteCard(index),
                ),
                childCount: notesList.length,
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              size: 40,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Notes you add appear here',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          FloatingActionButton.extended(
            onPressed: _navigateToCreateNote,
            backgroundColor: Colors.orangeAccent,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Create a note',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(int index) {
    final note = notesList[index];
    final borderColor = borderColors[note.id.hashCode % borderColors.length];

    return GestureDetector(
      onTap: () => _navigateToNoteView(index),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              image: note.backgroundImage != null &&
                      note.backgroundImage!.isNotEmpty
                  ? DecorationImage(
                      image: AssetImage(note.backgroundImage!),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (note.title.isNotEmpty) ...[
                    Text(
                      note.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (note.content.isNotEmpty)
                    Text(
                      note.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                      maxLines: isStaggered ? 10 : 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ),
          if (note.pin)
            Positioned(
              top: -6,
              right: -6,
              child: Transform.rotate(
                angle: 0.5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.push_pin,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
