// Automatic FlutterFlow imports
import '/flutter_flow/ff_builtin_enums.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart' hide RepeatMode;
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class AircraftWebView extends StatefulWidget {
  const AircraftWebView({
    super.key,
    this.width,
    this.height,
    this.overhead,
    this.mcdu,
    this.efb,
  });

  final double? width;
  final double? height;
  final String? overhead;
  final String? mcdu;
  final String? efb;

  @override
  State<AircraftWebView> createState() => _AircraftWebViewState();
}

class _AircraftWebViewState extends State<AircraftWebView> {
  // 0 = OVERHEAD (Default), 1 = MCDU, 2 = EFB
  int _selectedTab = 0;
  bool _mcduMounted = false;
  bool _efbMounted = false;

  void _switchTab(int index) {
    if (_selectedTab == index) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedTab = index;
      if (index == 1) {
        _mcduMounted = true;
      } else if (index == 2) {
        _efbMounted = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return SizedBox(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      child: Container(
        color: const Color(0xFF0B111A),
        child: Column(
          children: [
            // Top Avionics Mode Switcher Banner
            SafeArea(
              top: true,
              left: true,
              right: true,
              bottom: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isLandscape ? 10 : 12,
                  isLandscape ? 4 : 6,
                  isLandscape ? 10 : 12,
                  isLandscape ? 4 : 6,
                ),
                child: _buildTopModeSwitcher(compact: isLandscape),
              ),
            ),

            // Active WebView Pane (All 3 isolated and preserved inside IndexedStack)
            Expanded(
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _OverheadWebViewPane(
                    key: const ValueKey('aircraft_overhead_webview_pane'),
                    initialUrl: widget.overhead,
                  ),
                  _mcduMounted
                      ? _McduWebViewPane(
                          key: const ValueKey('aircraft_mcdu_webview_pane'),
                          initialUrl: widget.mcdu,
                        )
                      : const SizedBox.shrink(),
                  _efbMounted
                      ? _EfbWebViewPane(
                          key: const ValueKey('aircraft_efb_webview_pane'),
                          initialUrl: widget.efb,
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopModeSwitcher({required bool compact}) {
    return Container(
      height: compact ? 34 : 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF09111B),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0xFF223349),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSwitcherTab(
              label: 'OVERHEAD',
              icon: Icons.tune_rounded,
              selected: _selectedTab == 0,
              compact: compact,
              onTap: () => _switchTab(0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildSwitcherTab(
              label: 'MCDU',
              icon: Icons.dialpad_rounded,
              selected: _selectedTab == 1,
              compact: compact,
              onTap: () => _switchTab(1),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildSwitcherTab(
              label: 'EFB',
              icon: Icons.tablet_mac_rounded,
              selected: _selectedTab == 2,
              compact: compact,
              onTap: () => _switchTab(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitcherTab({
    required String label,
    required IconData icon,
    required bool selected,
    required bool compact,
    required VoidCallback onTap,
  }) {
    const Color accent = Color(0xFF639DF0);
    const Color cyan = Color(0xFF38BDF8);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withOpacity(0.28),
                    cyan.withOpacity(0.14),
                  ],
                )
              : null,
          color: selected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? accent.withOpacity(0.9) : Colors.transparent,
            width: 1.1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withOpacity(0.30),
                    blurRadius: 10,
                    spreadRadius: 0.5,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: selected ? 6 : 0,
              height: selected ? 6 : 0,
              margin: EdgeInsets.only(right: selected ? 6 : 0),
              decoration: BoxDecoration(
                color: cyan,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cyan.withOpacity(0.8),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
            Icon(
              icon,
              size: compact ? 13.5 : 15,
              color: selected ? Colors.white : const Color(0xFF8EA4BE),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : const Color(0xFF8EA4BE),
                  fontSize: compact ? 10 : 11.5,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  letterSpacing: 0.7,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAB 1: OVERHEAD WEBVIEW (EXACT ORIGINAL CONFIGURATION UNCHANGED)
// ============================================================================

class _OverheadWebViewPane extends StatefulWidget {
  const _OverheadWebViewPane({
    super.key,
    this.initialUrl,
  });

  final String? initialUrl;

  @override
  State<_OverheadWebViewPane> createState() => _OverheadWebViewPaneState();
}

class _OverheadWebViewPaneState extends State<_OverheadWebViewPane> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    _initializeWebView();
  }

  @override
  void didUpdateWidget(covariant _OverheadWebViewPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String? newUrl = widget.initialUrl;
    if (newUrl != null && newUrl.isNotEmpty && newUrl != oldWidget.initialUrl) {
      _controller.loadRequest(Uri.parse(newUrl));
    }
  }

  Future<void> _initializeWebView() async {
    // Disable WebView zoom before loading the page.
    await _controller.enableZoom(false);

    await _controller.setJavaScriptMode(
      JavaScriptMode.unrestricted,
    );

    await _controller.setBackgroundColor(
      const Color(0x00000000),
    );

    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onWebResourceError: (WebResourceError error) {
          debugPrint('Overhead WebView Error: ${error.description}');
        },
      ),
    );

    final String? url = widget.initialUrl;
    if (url != null && url.isNotEmpty) {
      await _controller.loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

// ============================================================================
// TAB 2: MCDU WEBVIEW (EXACT ORIGINAL CONFIGURATION UNCHANGED)
// ============================================================================

class _McduWebViewPane extends StatefulWidget {
  const _McduWebViewPane({
    super.key,
    this.initialUrl,
  });

  final String? initialUrl;

  @override
  State<_McduWebViewPane> createState() => _McduWebViewPaneState();
}

class _McduWebViewPaneState extends State<_McduWebViewPane> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    _initializeWebView();
  }

  @override
  void didUpdateWidget(covariant _McduWebViewPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String? newUrl = widget.initialUrl;
    if (newUrl != null && newUrl.isNotEmpty && newUrl != oldWidget.initialUrl) {
      _controller.loadRequest(Uri.parse(newUrl));
    }
  }

  Future<void> _initializeWebView() async {
    // Disable WebView zoom before loading the page.
    await _controller.enableZoom(false);

    await _controller.setJavaScriptMode(
      JavaScriptMode.unrestricted,
    );

    await _controller.setBackgroundColor(
      const Color(0x00000000),
    );

    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onWebResourceError: (WebResourceError error) {
          debugPrint('MCDU WebView Error: ${error.description}');
        },
      ),
    );

    final String? url = widget.initialUrl;
    if (url != null && url.isNotEmpty) {
      await _controller.loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

// ============================================================================
// TAB 3: EFB WEBVIEW (EXACT ORIGINAL CONFIGURATION UNCHANGED)
// ============================================================================

class _EfbWebViewPane extends StatefulWidget {
  const _EfbWebViewPane({
    super.key,
    this.initialUrl,
  });

  final String? initialUrl;

  @override
  State<_EfbWebViewPane> createState() => _EfbWebViewPaneState();
}

class _EfbWebViewPaneState extends State<_EfbWebViewPane> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _controller = WebViewController.fromPlatformCreationParams(params);

    _initializeWebView();
  }

  @override
  void didUpdateWidget(covariant _EfbWebViewPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String? newUrl = widget.initialUrl;
    if (newUrl != null && newUrl.isNotEmpty && newUrl != oldWidget.initialUrl) {
      _controller.loadRequest(Uri.parse(newUrl));
    }
  }

  Future<void> _initializeWebView() async {
    // Disable WebView zoom before loading the page.
    await _controller.enableZoom(false);

    await _controller.setJavaScriptMode(
      JavaScriptMode.unrestricted,
    );

    await _controller.setBackgroundColor(
      const Color(0x00000000),
    );

    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onWebResourceError: (WebResourceError error) {
          debugPrint('EFB WebView Error: ${error.description}');
        },
      ),
    );

    final String? url = widget.initialUrl;
    if (url != null && url.isNotEmpty) {
      await _controller.loadRequest(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
