import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'colors.dart';

class BackgroundSwitcher extends StatefulWidget {
  final List<String> backgrounds;

  const BackgroundSwitcher({super.key, required this.backgrounds});

  @override
  _BackgroundSwitcherState createState() => _BackgroundSwitcherState();
}

class _BackgroundSwitcherState extends State<BackgroundSwitcher>
    with SingleTickerProviderStateMixin {
  late List<String> backgrounds;
  String? selectedBackground;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glitterAnimation;

  @override
  void initState() {
    super.initState();
    backgrounds = widget.backgrounds;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..repeat(reverse: true);
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.1).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _glitterAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                "Background",
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Add space between text and list
          SizedBox(
            height: 150, // Adjust the height to accommodate the CircleAvatar
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: backgrounds.length,
              itemBuilder: (context, index) {
                return _buildBackgroundImageItem(context, backgrounds[index]);
              },
            ),
          ),
          const SizedBox(height: 16), // Add space before the button
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context,
                  selectedBackground); // Pass the selected background back
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.black,
              backgroundColor: Colors.yellow, // Text color
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Save Changes',
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImageItem(BuildContext context, String background) {
    final isSelected = selectedBackground == background;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedBackground = background; // Update the selected background
          _controller.forward().then((value) => _controller.reverse());
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: isSelected
                  ? _scaleAnimation
                  : const AlwaysStoppedAnimation(1.0),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2), // Border width
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset:
                              const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: isSelected
                            ? [Colors.blue, Colors.lightBlueAccent]
                            : [Colors.white, Colors.grey[300]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: isSelected ? 4.0 : 2.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 40, // Adjust the radius as needed
                      backgroundColor: background == "default" ? bgColor : null,
                      backgroundImage: background != "default"
                          ? AssetImage(background)
                          : null,
                      child: background == "default"
                          ? const Stack(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: bgColor,
                                ),
                                Center(
                                  child: Icon(
                                    Icons.cyclone_sharp,
                                    size: 32,
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                  ),
                  if (isSelected)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: GlitterPainter(_glitterAnimation),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlitterPainter extends CustomPainter {
  final Animation<double> animation;
  final Random random = Random();
  GlitterPainter(this.animation) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.indigo,
      Colors.pink,
      Colors.cyan,
      Colors.amber,
      Colors.brown,
      Colors.lime,
      Colors.deepPurple,
      Colors.lightGreen,
    ];

    for (int i = 0; i < 100; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final distance = (random.nextDouble() * radius * animation.value) / 2;
      final x = radius + distance * cos(angle);
      final y = radius + distance * sin(angle);
      final color = colors[random.nextInt(colors.length)];
      final paint = Paint()..color = color;
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
