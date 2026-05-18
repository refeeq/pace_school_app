import 'dart:async';

import 'package:flutter/material.dart';

/// iOS HUD–style toast: dark frosted pill over [Overlay], reusable app-wide.
class IosToast {
  IosToast._();

  static OverlayEntry? _entry;

  static void _dismiss() {
    _entry?.remove();
    _entry = null;
  }

  /// Shows an iOS-style pill toast. Any currently visible toast is removed first.
  static void show(
    BuildContext context, {
    required String message,
    required IconData icon,
    Duration duration = const Duration(milliseconds: 2000),
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _dismiss();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(
              child: IgnorePointer(ignoring: true, child: SizedBox.expand()),
            ),
            _IosToastWidget(
              message: message,
              icon: icon,
              holdDuration: duration,
              onDismissed: () {
                entry.remove();
                if (_entry == entry) {
                  _entry = null;
                }
              },
            ),
          ],
        );
      },
    );

    _entry = entry;
    overlay.insert(entry);
  }
}

class _IosToastWidget extends StatefulWidget {
  const _IosToastWidget({
    required this.message,
    required this.icon,
    required this.holdDuration,
    required this.onDismissed,
  });

  final String message;
  final IconData icon;
  final Duration holdDuration;
  final VoidCallback onDismissed;

  @override
  State<_IosToastWidget> createState() => _IosToastWidgetState();
}

class _IosToastWidgetState extends State<_IosToastWidget>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _entryOpacity;
  late final Animation<double> _entryScale;

  late final AnimationController _exitController;
  late final Animation<double> _exitOpacity;
  late final Animation<double> _exitScale;

  Timer? _holdTimer;
  bool _exitPlaying = false;

  static const Duration _entryDuration = Duration(milliseconds: 220);
  static const Duration _exitDuration = Duration(milliseconds: 180);

  static const Color _pillFill = Color(0xF0111827);
  static const List<BoxShadow> _pillShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.25),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  static const TextStyle _labelStyle = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.1,
  );

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: _entryDuration,
      vsync: this,
    );
    final entryMotion = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _entryOpacity = Tween<double>(begin: 0, end: 1).animate(entryMotion);
    _entryScale = Tween<double>(begin: 0.85, end: 1).animate(entryMotion);

    _exitController = AnimationController(duration: _exitDuration, vsync: this);
    final exitMotion = CurvedAnimation(
      parent: _exitController,
      curve: Curves.easeIn,
    );
    _exitOpacity = Tween<double>(begin: 1, end: 0).animate(exitMotion);
    _exitScale = Tween<double>(begin: 1, end: 0.85).animate(exitMotion);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _entryController.forward().then((_) {
        if (!mounted) return;
        _holdTimer = Timer(widget.holdDuration, _playExit);
      });
    });
  }

  void _playExit() {
    if (!mounted) return;
    _holdTimer = null;
    setState(() => _exitPlaying = true);
    _exitController.forward().then((_) {
      if (!mounted) return;
      widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _entryController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final activeController = !_exitPlaying ? _entryController : _exitController;

    return AnimatedBuilder(
      animation: activeController,
      builder: (context, child) {
        final opacity = !_exitPlaying
            ? _entryOpacity.value
            : _exitOpacity.value;
        final scale = !_exitPlaying ? _entryScale.value : _exitScale.value;

        return Positioned(
          left: 0,
          right: 0,
          bottom: 100 + bottomInset,
          child: Center(
            child: Opacity(
              opacity: opacity,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: _pillFill,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: _pillShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, color: Colors.white, size: 17),
                      const SizedBox(width: 8),
                      Text(widget.message, style: _labelStyle),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
