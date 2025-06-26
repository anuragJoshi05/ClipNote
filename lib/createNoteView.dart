import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/services/db.dart';
import 'package:uuid/uuid.dart';
import 'colors.dart';
import 'home.dart';

class CreateNoteview extends StatefulWidget {
  const CreateNoteview({super.key});

  @override
  State<CreateNoteview> createState() => _CreateNoteviewState();
}

class _CreateNoteviewState extends State<CreateNoteview> with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _contentFocus = FocusNode();
  final _uuid = const Uuid();

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  bool _isLoading = false;
  bool _hasTyped = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));
    _scaleAnim = Tween(begin: 0.9, end: 1.0).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack));

    _fadeController.forward();
    _scaleController.forward();

    _titleController.addListener(_onTyped);
    _contentController.addListener(_onTyped);
  }

  void _onTyped() {
    final hasContent = _titleController.text.trim().isNotEmpty || _contentController.text.trim().isNotEmpty;
    if (_hasTyped != hasContent) {
      setState(() => _hasTyped = hasContent);
    }
  }

  Future<void> _saveNote() async {
    if (_isLoading) return;
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    final newNote = Note(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      uniqueID: _uuid.v1(),
      backgroundImage: null,
      createdTime: DateTime.now(),
      pin: false,
      isArchieve: false,
    );

    try {
      await NotesDatabase.instance.insertEntry(newNote);
      if (mounted) {
        HapticFeedback.selectionClick();
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Home()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _onBackPressed() async {
    if (_hasTyped) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Save before leaving?'),
          content: const Text('You have unsaved content.'),
          actions: [
            TextButton(child: const Text('Discard'), onPressed: () => Navigator.pop(context, false)),
            TextButton(child: const Text('Save'), onPressed: () => Navigator.pop(context, true)),
          ],
        ),
      );
      if (shouldSave == true) {
        await _saveNote();
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: bgColor,
        body: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      _buildAppBar(),
                      Expanded(child: _buildEditor(isKeyboardOpen)),
                    ],
                  ),
                ),
                if (_isLoading) _buildLoadingOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () async {
              if (await _onBackPressed()) Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          ),
          const Spacer(),
          if (_hasTyped)
            IconButton(
              icon: Icon(Icons.check_rounded, color: Colors.orangeAccent.shade200, size: 26),
              onPressed: _saveNote,
            ),
        ],
      ),
    );
  }

  Widget _buildEditor(bool isKeyboardOpen) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, 8, 20, isKeyboardOpen ? 24 : 64),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleField(),
          const SizedBox(height: 20),
          _buildContentField(),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextField(
      controller: _titleController,
      focusNode: _titleFocus,
      maxLines: null,
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      cursorColor: Colors.orangeAccent,
      decoration: InputDecoration(
        hintText: 'Title',
        hintStyle: TextStyle(color: Colors.white60, fontSize: 24, fontWeight: FontWeight.bold),
        border: InputBorder.none,
      ),
      onTap: () => HapticFeedback.selectionClick(),
    );
  }

  Widget _buildContentField() {
    return TextField(
      controller: _contentController,
      focusNode: _contentFocus,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(fontSize: 16, color: Colors.white70, height: 1.5),
      cursorColor: Colors.orangeAccent,
      decoration: InputDecoration(
        hintText: 'Start writing your note...',
        hintStyle: TextStyle(color: Colors.white38, fontSize: 16),
        border: InputBorder.none,
      ),
      onTap: () => HapticFeedback.selectionClick(),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orangeAccent),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                const Text('Saving...', style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _titleFocus.dispose();
    _contentFocus.dispose();
    super.dispose();
  }
}
