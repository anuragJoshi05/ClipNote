import 'dart:math';
import 'package:clipnote/colors.dart';
import 'package:clipnote/services/account_switcher.dart';
import 'package:clipnote/services/firestore_db.dart';
import 'package:clipnote/noteView.dart';
import 'package:clipnote/createNoteView.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/searchPage.dart';
import 'package:clipnote/services/loginInfo.dart';
import 'package:clipnote/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ArchieveView extends StatefulWidget {
  const ArchieveView({super.key});
  @override
  State<ArchieveView> createState() => _ArchieveViewState();
}

class _ArchieveViewState extends State<ArchieveView> {
  bool isStaggered = true;
  bool isLoading = true;
  List<Note> notesList = [];
  String? imgUrl;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
    _loadUserImage();
    _getArchivedNotes();
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

  Future<void> _getArchivedNotes() async {
    final user = await LoginInfo().getCurrentUser();
    if (user?.email != null) {
      final allNotes = await FireDB().getAllStoredNotesForUser(user!.email!);
      final archivedNotes = allNotes.where((note) => note.isArchieve).toList();
      setState(() {
        notesList = archivedNotes;
        isLoading = false;
      });
    }
  }

  Future<List<GoogleSignInAccount>> _getGoogleAccounts() async {
    try {
      await _googleSignIn.signInSilently();
      return _googleSignIn.currentUser != null ? [_googleSignIn.currentUser!] : [];
    } catch (_) {
      return [];
    }
  }

  void _toggleView() {
    HapticFeedback.selectionClick();
    setState(() {
      isStaggered = !isStaggered;
    });
  }

  Future<void> _navigateToCreateNote() async {
    HapticFeedback.mediumImpact();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateNoteview()),
    );
    await _getArchivedNotes();
  }

  Future<void> _navigateToNoteView(int index) async {
    HapticFeedback.selectionClick();
    final updatedNote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteView(
          note: notesList[index],
          onNoteUpdated: (Note updatedNote) {
            setState(() {
              notesList[index] = updatedNote;
            });
          },
        ),
      ),
    );
    if (updatedNote != null || mounted) {
      await _getArchivedNotes();
    }
  }

  void _navigateToSearch() {
    HapticFeedback.lightImpact();
    Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()));
  }

  void _showAccountSwitcher() async {
    HapticFeedback.lightImpact();
    final accounts = await _getGoogleAccounts();
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AccountSwitcher(accounts: accounts),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateNote,
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, size: 28),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
            strokeWidth: 3,
          ),
        )
            : RefreshIndicator(
          onRefresh: _getArchivedNotes,
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
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
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
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home())),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
            'ARCHIVED',
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
        child: Center(
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
                  Icons.archive_outlined,
                  size: 40,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No archived notes',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
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
              image: note.backgroundImage != null && note.backgroundImage!.isNotEmpty
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
