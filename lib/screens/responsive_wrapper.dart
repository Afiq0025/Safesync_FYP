import 'package:flutter/material.dart';
import '../utils/responsive_helper.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;
  final bool useScrollView;
  final EdgeInsetsGeometry? padding;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.useSafeArea = true,
    this.useScrollView = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final responsivePadding = ResponsiveHelper.getResponsivePadding(
      context,
      16.0,
    );

    Widget content = Padding(
      padding: padding ?? responsivePadding,
      child: child,
    );

    if (useScrollView) {
      content = SingleChildScrollView(
        child: content,
      );
    }

    if (useSafeArea) {
      content = SafeArea(
        child: content,
      );
    }

    return content;
  }
}

class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;

  const ResponsiveColumn({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing = ResponsiveHelper.getResponsivePadding(
      context,
      spacing,
    );

    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children.map((child) {
        return Padding(
          padding: EdgeInsets.only(bottom: responsiveSpacing.top),
          child: child,
        );
      }).toList(),
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;
  final double spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveSpacing = ResponsiveHelper.getResponsivePadding(
      context,
      spacing,
    );

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children.map((child) {
        return Padding(
          padding: EdgeInsets.only(right: responsiveSpacing.left),
          child: child,
        );
      }).toList(),
    );
  }
}
