import 'package:flutter/material.dart';
import '../widgets/responsive_builder.dart';
import '../widgets/mobile_layout.dart';
import '../widgets/tablet_layout.dart';
import '../widgets/desktop_layout.dart';

/// [ResponsiveDemoScreen] showcases the [ResponsiveBuilder] usage.
class ResponsiveDemoScreen extends StatefulWidget {
  const ResponsiveDemoScreen({super.key, required this.orientation});

  final Orientation orientation;

  @override
  State<ResponsiveDemoScreen> createState() => _ResponsiveDemoScreenState();
}

class _ResponsiveDemoScreenState extends State<ResponsiveDemoScreen> {
  late Orientation orient;

  @override
  void initState() {
    super.initState();
    orient = widget.orientation;
  }

  @override
  void didUpdateWidget(covariant ResponsiveDemoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.orientation != widget.orientation) {
      setState(() {
        orient = widget.orientation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      mobile: (context, constraints) => MobileLayout(orientation: orient),
      tablet: (context, constraints) => const TabletLayout(),
      desktop: (context, constraints) => const DesktopLayout(),
    );
  }
}
