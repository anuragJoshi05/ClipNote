import 'package:clipnote/services/firestore_db.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:clipnote/model/myNoteModel.dart';
import 'package:clipnote/services/db.dart';
import 'colors.dart';

class EditNoteView extends StatefulWidget {
  final Note note;
  final String? backgroundImage;

  const EditNoteView({required this.note, this.backgroundImage, Key? key})
      : super(key: key);

  @override
  _EditNoteViewState createState() => _EditNoteViewState();
}

class _EditNoteViewState extends State<EditNoteView>
    with TickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  String? _backgroundImage;
  bool _isLoading = false;
  bool _hasChanges = false;
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupAnimations();
    _setupListeners();
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _backgroundImage = widget.backgroundImage;
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _scaleController.forward();
  }

  void _setupListeners() {
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasChanges = _titleController.text != widget.note.title ||
        _contentController.text != widget.note.content;

    if (hasChanges != _hasChanges) {
      setState(() => _hasChanges = hasChanges);
    }
  }

  Future<void> _saveNote() async {
    if (_isLoading) return;

    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);

    try {
      final updatedNote = widget.note.copy(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        backgroundImage: _backgroundImage,
      );

      await Future.wait([
        NotesDatabase.instance.updateNote(updatedNote),
        FireDB().updateNoteFirestore(updatedNote),
      ]);

      if (mounted) {
        HapticFeedback.selectionClick();
        Navigator.pop(context, updatedNote);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (_hasChanges) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Save Changes?'),
          content: const Text('You have unsaved changes. Would you like to save them?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Discard'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
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
    final mediaQuery = MediaQuery.of(context);
    final keyboardHeight = mediaQuery.viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Stack(
                  children: [
                    // Background Image with Overlay
                    _buildBackground(),

                    // Main Content
                    SafeArea(
                      child: Column(
                        children: [
                          // Custom App Bar
                          _buildAppBar(),

                          // Content Area
                          Expanded(
                            child: _buildContentArea(isKeyboardVisible),
                          ),
                        ],
                      ),
                    ),

                    // Loading Overlay
                    if (_isLoading) _buildLoadingOverlay(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: _backgroundImage != null && _backgroundImage!.isNotEmpty
              ? null
              : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueGrey.shade900,
              Colors.grey.shade900,
            ],
          ),
        ),
        child: _backgroundImage != null && _backgroundImage!.isNotEmpty
            ? Stack(
          children: [
            Image.asset(
              _backgroundImage!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
          ],
        )
            : null,
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          // Back Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () async {
                if (await _onWillPop()) {
                  Navigator.pop(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                child: Icon(
                  Icons.arrow_back_ios_rounded,
                  color: white,
                  size: 22,
                ),
              ),
            ),
          ),

          const Spacer(),

          // Save Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Material(
              color: _hasChanges
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: _hasChanges ? _saveNote : null,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.save_outlined,
                    color: _hasChanges ? Colors.blue.shade300 : white.withOpacity(0.6),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(bool isKeyboardVisible) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: isKeyboardVisible ? 20 : 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Field
            _buildTitleField(),

            const SizedBox(height: 20),

            // Content Field
            _buildContentField(),

            // Extra space for better scrolling
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
      ),
      child: TextField(
        controller: _titleController,
        focusNode: _titleFocusNode,
        style: const TextStyle(
          fontSize: 28,
          color: white,
          fontWeight: FontWeight.w600,
          height: 1.2,
        ),
        maxLines: null,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Colors.blue.shade300,
        cursorWidth: 2,
        cursorRadius: const Radius.circular(1),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: "Title",
          hintStyle: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: white.withOpacity(0.4),
            height: 1.2,
          ),
        ),
        onTap: () => HapticFeedback.selectionClick(),
      ),
    );
  }

  Widget _buildContentField() {
    return Container(
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height * 0.4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
      ),
      child: TextField(
        controller: _contentController,
        focusNode: _contentFocusNode,
        style: const TextStyle(
          fontSize: 16,
          color: white,
          height: 1.5,
          fontWeight: FontWeight.w400,
        ),
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        cursorColor: Colors.blue.shade300,
        cursorWidth: 2,
        cursorRadius: const Radius.circular(1),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          hintText: "Start writing your note...",
          hintStyle: TextStyle(
            fontSize: 16,
            color: white.withOpacity(0.4),
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),
        onTap: () => HapticFeedback.selectionClick(),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade300),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Saving...',
                  style: TextStyle(
                    color: white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }
}