import 'package:flutter/material.dart';

/// The entry point of the application.
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      // ScrollableList is our main screen widget.
      home: ScrollableList(),
    ),
  );
}

/// ScrollableList demonstrates a classic layout pattern:
/// A Fixed Header + A Scrollable Body + A Fixed Footer.
class ScrollableList extends StatelessWidget {
  const ScrollableList({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("ScrollableList build");

    // Scaffold provides the basic visual layout structure for a screen.
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Soft background color
      appBar: AppBar(
        title: const Text(
          "Advanced Scrollable View",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
        ),
        centerTitle: true,
        elevation: 0, // Removes the shadow under the AppBar
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      // Column stacks widgets vertically.
      body: Column(
        children: [
          // 1. FIXED HEADER SECTION
          // This widget stays at the top and doesn't scroll.
          const _HeaderSection(),

          // 2. SCROLLABLE CONTENT (The Body)
          // Expanded is used here to tell the ListView to take up all
          // the remaining vertical space between the header and footer.
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: 20, // Number of items in our list
              // BouncingScrollPhysics gives an iOS-style bounce effect when reaching ends.
              physics: const BouncingScrollPhysics(),
              // itemBuilder is called only for visible items, making it memory-efficient.
              itemBuilder: (context, index) {
                return _ScrollItemView(index: index);
              },
            ),
          ),

          // 3. FIXED BOTTOM ACTION BAR
          // This stays at the bottom of the screen regardless of scrolling.
          const _BottomActionBar(),
        ],
      ),
    );
  }
}

/// A simple header component to display a title.
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    // Container is a versatile widget used for padding, background colors, and sizing.
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dynamic Content List",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// _ScrollItemView represents a single card in our list.
class _ScrollItemView extends StatelessWidget {
  final int index;
  final Color itemColor;

  // Constructor initializes the item index and its unique color.
  _ScrollItemView({required this.index}) : itemColor = _generateColor(index);

  // Helper method to pick a color based on the item's position.
  static Color _generateColor(int index) {
    final colors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF43F5E), // Rose
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF10B981), // Emerald
      const Color(0xFF3B82F6), // Blue
      const Color(0xFF06B6D4), // Cyan
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 120,
      // BoxDecoration is used to style the card with gradients, borders, and shadows.
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [itemColor, itemColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: itemColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6), // Shadow position
          ),
        ],
      ),
      // Stack allows us to overlay widgets (like the background icon).
      child: Stack(
        children: [
          // Background decorative icon
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.auto_awesome,
              size: 100,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          // Content inside the card
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "FEATURE ITEM ${index + 1}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Interactive Design Component",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(), // Pushes the following Row to the bottom
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Active",
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                    const Spacer(), // Pushes the following Row other children to the right
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A fixed footer component with an action button.
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      // SafeArea ensures the button isn't obscured by the home indicator or notches.
      child: SafeArea(
        top: false, // We only care about the bottom padding
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E293B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Get Started",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
