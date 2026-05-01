import 'package:flutter/material.dart';
import '../core/device_type.dart';
import '../core/app_breakpoints.dart';

/// A function signature that returns a widget based on the context and constraints.
typedef ResponsiveWidgetBuilder = Widget Function(BuildContext context, BoxConstraints constraints);

/// [ResponsiveBuilder] abstracts the [LayoutBuilder] and [DeviceType] logic
/// to provide a clean interface for building responsive UIs.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final ResponsiveWidgetBuilder mobile;
  final ResponsiveWidgetBuilder? tablet;
  final ResponsiveWidgetBuilder? desktop;

  /// Utility logic to determine the device type based on width.
  static DeviceType getDeviceType(double width) {
    if (width < AppBreakpoints.mobile) return DeviceType.mobile;
    if (width < AppBreakpoints.tablet) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = getDeviceType(constraints.maxWidth);

        if (deviceType == DeviceType.desktop && desktop != null) {
          return desktop!(context, constraints);
        }
        
        if (deviceType == DeviceType.tablet && tablet != null) {
          return tablet!(context, constraints);
        }

        // Default to mobile
        return mobile(context, constraints);
      },
    );
  }
}
