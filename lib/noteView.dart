import 'package:clipnote/backgroundSwitcher.dart';
import 'package:clipnote/services/firestore_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clipnote/home.dart';
import 'package:clipnote/editNoteView.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/services/db.dart';
import 'colors.dart';
import 'package:intl/intl.dart';

class NoteView extends StatefulWidget {
  final Note note;
  final Function(Note) onNoteUpdated;

  const NoteView({super.key, required this.note, required this.onNoteUpdated});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView>
    with SingleTickerProviderStateMixin {
  late Note _note;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isLoading = false;
  String? _backgroundImage;
  final ScrollController _scrollController = ScrollController();

  List<String> backgrounds = [
    "default",
    "images/bg1.jpg",
    "images/bg2.jpg",
    "images/bg3.jpg",
    "images/bg4.jpg",
    "images/bg5.jpg",
    "images/bg6.jpg",
    "images/bg7.jpg",
    "images/bg8.jpg",
    "images/bg9.jpg",
    "images/bg10.jpg"
  ];

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _setupAnimations();
    _backgroundImage = _note.backgroundImage;
  }

  void _setupAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _updateNoteArchiveStatus() async {
    if (_isLoading) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    await _controller.forward();
    await _controller.reverse();

    try {
      final updatedNote = _note.copy(isArchieve: !_note.isArchieve);
      await NotesDatabase.instance.updateNote(updatedNote);
      await FireDB().updateNoteFirestore(updatedNote);

      setState(() {
        _note = updatedNote;
        _isLoading = false;
      });

      _showSnackBar(
        _note.isArchieve ? 'Note archived' : 'Note unarchived',
        Icons.archive_outlined,
      );

      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const Home(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: animation.drive(
                  Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: child,
              );
            },
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to update note');
    }
  }

  Future<void> _updateNotePinStatus() async {
    if (_isLoading) return;

    HapticFeedback.selectionClick();
    setState(() => _isLoading = true);

    try {
      final updatedNote = _note.copy(pin: !_note.pin);
      await NotesDatabase.instance.updateNote(updatedNote);

      setState(() {
        _note = updatedNote;
        _isLoading = false;
      });

      _showSnackBar(
        _note.pin ? 'Note pinned' : 'Note unpinned',
        Icons.push_pin_outlined,
      );

      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const Home(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to update note');
    }
  }

  Future<void> _deleteNote() async {
    final shouldDelete = await _showDeleteConfirmation();
    if (!shouldDelete || _isLoading) return;

    HapticFeedback.heavyImpact();
    setState(() => _isLoading = true);

    try {
      await NotesDatabase.instance.deleteNote(_note);

      _showSnackBar('Note deleted', Icons.delete_outline);

      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const Home(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ScaleTransition(
                scale: animation.drive(
                  Tween(begin: 0.8, end: 1.0)
                      .chain(CurveTween(curve: Curves.easeOut)),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to delete note');
    }
  }

  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.grey[900],
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.amber[600], size: 28),
              const SizedBox(width: 12),
              const Text(
                'Delete Note',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to delete this note? This action cannot be undone.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[400], fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Delete', style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _editNote() async {
    if (_isLoading) return;

    HapticFeedback.selectionClick();
    setState(() => _isLoading = true);

    try {
      final updatedNote = await Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              EditNoteView(note: _note, backgroundImage: _backgroundImage),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: animation.drive(
                Tween(begin: const Offset(0.0, 1.0), end: Offset.zero)
                    .chain(CurveTween(curve: Curves.easeOut)),
              ),
              child: child,
            );
          },
        ),
      );

      if (updatedNote != null) {
        setState(() {
          _note = updatedNote;
          _backgroundImage = updatedNote.backgroundImage;
        });
        widget.onNoteUpdated(updatedNote);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _changeBackground() async {
    HapticFeedback.selectionClick();

    final selectedBackground = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: BackgroundSwitcher(backgrounds: backgrounds),
        );
      },
    );

    if (selectedBackground != null) {
      setState(() {
        _backgroundImage = selectedBackground == "default" ? "" : selectedBackground;
      });

      try {
        final updatedNote = _note.copy(backgroundImage: _backgroundImage);
        await NotesDatabase.instance.updateNote(updatedNote);
        await FireDB().updateNoteFirestore(updatedNote);
        widget.onNoteUpdated(updatedNote);

        _showSnackBar('Background changed', Icons.palette_outlined);
      } catch (e) {
        _showErrorSnackBar('Failed to change background');
      }
    }
  }

  void _showSnackBar(String message, IconData icon) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.green[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontSize: 16)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final isLandscape = size.width > size.height;

    return Scaffold(
      backgroundColor: _backgroundImage == null || _backgroundImage!.isEmpty
          ? bgColor
          : Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Image
          if (_backgroundImage != null && _backgroundImage!.isNotEmpty)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(_backgroundImage!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.4),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Main Content
          Column(
            children: [
              // Custom App Bar
              Container(
                height: kToolbarHeight + padding.top,
                padding: EdgeInsets.only(
                  top: padding.top,
                  left: 4,
                  right: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    // Back Button
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                        splashRadius: 24,
                      ),
                    ),

                    const Spacer(),

                    // Action Buttons
                    _buildActionButton(
                      icon: Icons.delete_forever_outlined,
                      onPressed: _deleteNote,
                      color: Colors.red[400]!,
                    ),
                    const SizedBox(width: 8),

                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildActionButton(
                          icon: _note.isArchieve ? Icons.star : Icons.star_outlined,
                          onPressed: _updateNoteArchiveStatus,
                          color: _note.isArchieve ? Colors.amber[400]! : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    _buildActionButton(
                      icon: _note.pin ? Icons.push_pin : Icons.push_pin_outlined,
                      onPressed: _updateNotePinStatus,
                      color: _note.pin ? Colors.red[400]! : Colors.white,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),

              // Content Area
              Expanded(
                child: Stack(
                  children: [
                    // Note Content
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isLandscape ? size.width * 0.08 : size.width * 0.05,
                        vertical: 16,
                      ),
                      child: Scrollbar(
                        controller: _scrollController,
                        thumbVisibility: true,
                        radius: const Radius.circular(8),
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(
                            bottom: 120, // Space for FABs
                            right: isLandscape ? 0 : 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Creation Date
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 16,
                                      color: Colors.grey[300],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Created ${DateFormat.yMMMMEEEEd().format(widget.note.createdTime)}",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[300],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: size.height * 0.025),

                              // Title
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _note.title.isEmpty ? 'Untitled' : _note.title,
                                  style: TextStyle(
                                    fontSize: isLandscape ? 28 : 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    height: 1.3,
                                  ),
                                ),
                              ),

                              SizedBox(height: size.height * 0.025),

                              // Content
                              Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  minHeight: size.height * 0.3,
                                ),
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.25),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _note.content.isEmpty ? 'No content' : _note.content,
                                  style: TextStyle(
                                    fontSize: isLandscape ? 18 : 16,
                                    color: Colors.white.withOpacity(0.95),
                                    height: 1.6,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Loading Overlay
                    if (_isLoading)
                      Container(
                        color: Colors.black.withOpacity(0.5),
                        child: const Center(
                          child: Card(
                            color: Colors.black87,
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.amber,
                                    strokeWidth: 3,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Processing...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),

      // Floating Action Buttons
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: padding.bottom > 0 ? padding.bottom : 16,
          right: 8,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Background Change FAB
            _buildFAB(
              heroTag: 'colorButton',
              icon: Icons.palette,
              backgroundColor: Colors.deepPurple[600]!,
              onPressed: _changeBackground,
              tooltip: 'Change Background',
            ),

            const SizedBox(height: 12),

            // Edit FAB
            _buildFAB(
              heroTag: 'editButton',
              icon: Icons.edit,
              backgroundColor: Colors.blue[600]!,
              onPressed: _editNote,
              tooltip: 'Edit Note',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 22),
        onPressed: onPressed,
        splashRadius: 24,
        tooltip: _getTooltipForIcon(icon),
      ),
    );
  }

  Widget _buildFAB({
    required String heroTag,
    required IconData icon,
    required Color backgroundColor,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return FloatingActionButton(
      heroTag: heroTag,
      onPressed: onPressed,
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      elevation: 8,
      tooltip: tooltip,
      child: Icon(icon, size: 24),
    );
  }

  String _getTooltipForIcon(IconData icon) {
    if (icon == Icons.delete_forever_outlined) return 'Delete Note';
    if (icon == Icons.star || icon == Icons.star_outlined) return 'Archive Note';
    if (icon == Icons.push_pin || icon == Icons.push_pin_outlined) return 'Pin Note';
    return '';
  }
}