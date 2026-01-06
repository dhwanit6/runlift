import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:latlong2/latlong.dart';
import 'package:confetti/confetti.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_utils.dart';
import '../../../domain/models/training_program.dart';
import 'path_painter.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final Workout workout;
  final int durationSeconds;
  final double distanceMeters;
  final List<LatLng>? routeHistory;
  
  const WorkoutSummaryScreen({
    required this.workout,
    required this.durationSeconds,
    this.distanceMeters = 0,
    this.routeHistory,
    super.key,
  });

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  final GlobalKey _globalKey = GlobalKey();
  late ConfettiController _confettiController;
  bool _isSharing = false;
  bool _useGradientBackground = true; // Toggle between gradient and transparent

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Stat Calculations
  int get _calories {
    if (widget.workout.type == WorkoutType.run) {
      if (widget.distanceMeters < 50) return 0;
      return ((widget.distanceMeters / 1000) * 72).toInt();
    } else {
      return ((widget.durationSeconds / 60) * 6).toInt();
    }
  }

  String get _pace {
    if (widget.distanceMeters == 0) return '--:--';
    final double distanceKm = widget.distanceMeters / 1000;
    final double minutes = widget.durationSeconds / 60;
    final double pace = minutes / distanceKm;
    
    final int paceMin = pace.floor();
    final int paceSec = ((pace - paceMin) * 60).toInt();
    return '$paceMin:${paceSec.toString().padLeft(2, '0')}';
  }
  
  String get _formatDuration {
    final int hours = widget.durationSeconds ~/ 3600;
    final int minutes = (widget.durationSeconds % 3600) ~/ 60;
    final int remainingSeconds = widget.durationSeconds % 60;
    
    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _shareStory() async {
    setState(() => _isSharing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final imagePath = await File('${directory.path}/runlift_story.png').create();
      await imagePath.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(imagePath.path)], text: 'Workout Complete! #RunLift');
    } catch (e) {
      debugPrint('Share error: $e');
    } finally {
      setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRun = widget.workout.type == WorkoutType.run;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.go('/today'),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Text(
                    'WORKOUT COMPLETE',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance
                ],
              ),
            ),

            // SHAREABLE CARD (Capture Target)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: _useGradientBackground
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF1A1A2E),
                                Color(0xFF16213E),
                                Color(0xFF0F3460),
                              ],
                            )
                          : null,
                      color: _useGradientBackground ? null : Colors.black.withAlphaValue(0.3),
                      border: Border.all(
                        color: Colors.white.withAlphaValue(_useGradientBackground ? 0.1 : 0.2),
                        width: 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Route background (subtle)
                        if (widget.routeHistory != null && widget.routeHistory!.isNotEmpty)
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.15,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: CustomPaint(
                                  painter: PathPainter(points: widget.routeHistory!),
                                ),
                              ),
                            ),
                          ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // LOGO + BRANDING
                              Row(
                                children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppTheme.primary,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primary.withAlpha(100),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 28),
                                    ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'RUNLIFT',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 3,
                                        ),
                                      ),
                                      Text(
                                        '28 DAYS TO 5K',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontSize: 10,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  ConfettiWidget(
                                    confettiController: _confettiController,
                                    blastDirectionality: BlastDirectionality.explosive,
                                    shouldLoop: false,
                                    colors: const [
                                      AppTheme.primary,
                                      Color(0xFF60A5FA), // Soft blue
                                      Color(0xFF34D399), // Emerald
                                      Color(0xFFF472B6), // Pink
                                      Colors.white,
                                    ],
                                    gravity: 0.2, // Smoother fall
                                    numberOfParticles: 20,
                                    minimumSize: const Size(5, 5),
                                    maximumSize: const Size(15, 15),
                                  ),
                                ],
                              ),

                              const Spacer(),

                              // MAIN STAT (Duration or Distance)
                              if (isRun) ...[
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${(widget.distanceMeters / 1000).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 72,
                                      fontWeight: FontWeight.w200,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'KILOMETERS',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ] else ...[
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _formatDuration,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 64,
                                      fontWeight: FontWeight.w200,
                                      height: 1,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'DURATION',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 14,
                                    letterSpacing: 4,
                                  ),
                                ),
                              ],

                              const SizedBox(height: 32),

                              // SECONDARY STATS ROW
                              Row(
                                children: [
                                  if (isRun) ...[
                                    _buildMiniStat(_formatDuration, 'TIME'),
                                    const SizedBox(width: 24),
                                    _buildMiniStat(_pace, '/KM'),
                                    const SizedBox(width: 24),
                                  ],
                                  _buildMiniStat(_calories.toString(), 'CAL'),
                                ],
                              ),

                              const Spacer(),

                              // WORKOUT NAME
                              Text(
                                widget.workout.name.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // BACKGROUND STYLE TOGGLE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStyleButton(
                    'Gradient',
                    _useGradientBackground,
                    () => setState(() => _useGradientBackground = true),
                  ),
                  const SizedBox(width: 12),
                  _buildStyleButton(
                    'Glass',
                    !_useGradientBackground,
                    () => setState(() => _useGradientBackground = false),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // SHARE BUTTON
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSharing ? null : _shareStory,
                  icon: _isSharing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.share),
                  label: Text(_isSharing ? 'CREATING...' : 'SHARE TO STORY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStyleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withAlphaValue(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.primary : Colors.white24,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.primary : Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
