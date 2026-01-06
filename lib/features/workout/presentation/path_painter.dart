import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../../core/theme/app_theme.dart';

class PathPainter extends CustomPainter {
  final List<LatLng> points;

  PathPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Find bounds of the path to normalize and center it
    double minX = points.first.longitude;
    double maxX = points.first.longitude;
    double minY = points.first.latitude;
    double maxY = points.first.latitude;

    for (var point in points) {
      if (point.longitude < minX) minX = point.longitude;
      if (point.longitude > maxX) maxX = point.longitude;
      if (point.latitude < minY) minY = point.latitude;
      if (point.latitude > maxY) maxY = point.latitude;
    }

    final double pathWidth = maxX - minX;
    final double pathHeight = maxY - minY;

    // Determine scale factor to fit path within canvas, with padding
    final double scaleX = size.width / (pathWidth * 1.2);
    final double scaleY = size.height / (pathHeight * 1.2);
    final double scale = scaleX < scaleY ? scaleX : scaleY;

    // Calculate offsets to center the path
    final double offsetX = (size.width - (pathWidth * scale)) / 2;
    final double offsetY = (size.height - (pathHeight * scale)) / 2;

    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    ui.Path path = ui.Path();

    // Move to the first point
    path.moveTo(
      (points.first.longitude - minX) * scale + offsetX,
      size.height - ((points.first.latitude - minY) * scale + offsetY),
    );

    // Draw lines to subsequent points
    for (var i = 1; i < points.length; i++) {
      path.lineTo(
        (points[i].longitude - minX) * scale + offsetX,
        size.height - ((points[i].latitude - minY) * scale + offsetY),
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
