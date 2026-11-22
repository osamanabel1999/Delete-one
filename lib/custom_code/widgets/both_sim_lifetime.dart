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

import 'dart:async';
import 'dart:ui';

class BothSimLifetime extends StatefulWidget {
  const BothSimLifetime({
    Key? key,
    this.width,
    this.height,
    this.yearlyPrice,
    this.lifetimePrice,
    this.onBuyYearly,
    this.onBuyLifetime,
    this.onContactUs,
    this.onTermsOfUse,
    this.onPrivacyPolicy,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String? yearlyPrice;
  final String? lifetimePrice;
  final Future Function()? onBuyYearly;
  final Future Function()? onBuyLifetime;
  final Future Function()? onContactUs;
  final Future Function()? onTermsOfUse;
  final Future Function()? onPrivacyPolicy;

  @override
  _BothSimLifetimeState createState() => _BothSimLifetimeState();
}

class _BothSimLifetimeState extends State<BothSimLifetime> {
  // Your Exact Design System Colors applied to the Premium Layout
  static const Color _bg = Color(0xFF0B111A);
  static const Color _card = Color(0xFF101923);
  static const Color _fieldBg = Color(0xFF0B1521);
  static const Color _border = Color(0xFF26364D);
  static const Color _accent = Color(0xFF639DF0);
  static const Color _buttonDark = Color(0xFF15335E);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _muted = Color(0xFF8B949E);
  static const Color _heading = Color(0xFF9BB8E1);
  static const Color _good = Color(0xFF69F0AE);

  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    // 3 Days rolling cycle for Urgency
    const int cycleMs = 3 * 24 * 60 * 60 * 1000;
    int nowMs = DateTime.now().millisecondsSinceEpoch;
    int remainingMs = cycleMs - (nowMs % cycleMs);

    _endDate = DateTime.now().add(Duration(milliseconds: remainingMs));
    _timeLeft = Duration(milliseconds: remainingMs);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft.inSeconds > 0) {
            _timeLeft = _timeLeft - const Duration(seconds: 1);
          } else {
            _timeLeft = const Duration(days: 3);
            _endDate = DateTime.now().add(const Duration(days: 3));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Regex to extract price and add exactly 25% to original price!
  Map<String, String> _parsePriceInfo(
    String fullText, {
    String fallbackNumber = "39.99",
    String fallbackOriginal = "\$53.32",
  }) {
    String prefix = "\$";
    String numberStr = fallbackNumber;
    String suffix = "";
    String originalPriceStr = fallbackOriginal;

    try {
      final regex = RegExp(r'^([^\d]*)(\d+(?:\.\d+)?)\s*(.*)$');
      final match = regex.firstMatch(fullText);

      if (match != null) {
        prefix = match.group(1)?.trim() ?? "";
        numberStr = match.group(2) ?? fallbackNumber;
        suffix = match.group(3)?.trim() ?? "";

        double currentPriceNum = double.parse(numberStr);
        // Calculate original price (25% off means current / 0.75)
        double originalPriceNum = currentPriceNum / 0.75;

        String symbol = prefix.isNotEmpty ? prefix : "\$";
        originalPriceStr = '$symbol${originalPriceNum.toStringAsFixed(2)}';
      }
    } catch (e) {
      // Fallback
    }

    return {
      'mainPrice': '$prefix$numberStr',
      'suffix': suffix,
      'originalPrice': originalPriceStr
    };
  }

  @override
  Widget build(BuildContext context) {
    final String currentYearlyPriceRaw = widget.yearlyPrice ?? "\$19.99 / year";
    final String currentLifetimePriceRaw =
        widget.lifetimePrice ?? "\$39.99 one-time";

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: _bg,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.of(context).size.width;
          final bool isTablet = availableWidth >= 720;
          final bool isCompactTablet = isTablet && availableWidth < 840;
          final double horizontalPadding =
              isCompactTablet ? 20 : (isTablet ? 32 : 20);
          final double columnGap = isCompactTablet ? 18 : 24;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: 32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 900 : double.infinity,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Premium Header Text ---
                    Text(
                      isTablet
                          ? "Ultimate 2-in-1 Simulator Pass"
                          : "Ultimate 2-in-1\nSimulator Pass",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _white,
                        fontSize: isTablet ? 32 : 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isTablet ? 580 : double.infinity,
                      ),
                      child: const Text(
                        "Take absolute control over both MSFS and X-Plane. Secure your access today with a massive 25% flash discount!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _muted,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Elegant Countdown Timer ---
                    _buildTimerWidget(),

                    SizedBox(height: isTablet ? 40 : 32),

                    // --- PLANS: 2 Columns Side-by-Side on iPad/Tablet, Stacked on Mobile ---
                    if (isTablet)
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _buildPremiumYearlyCard(
                                currentYearlyPriceRaw,
                                isTablet: true,
                                isCompactTablet: isCompactTablet,
                              ),
                            ),
                            SizedBox(width: columnGap),
                            Expanded(
                              child: _buildPremiumLifetimeCard(
                                currentLifetimePriceRaw,
                                isTablet: true,
                                isCompactTablet: isCompactTablet,
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // --- Premium Yearly Card (25% OFF) ---
                      _buildPremiumYearlyCard(currentYearlyPriceRaw),

                      const SizedBox(height: 36),

                      // --- Premium Lifetime Card (RECOMMENDED + 25% OFF) ---
                      _buildPremiumLifetimeCard(currentLifetimePriceRaw),
                    ],

                    const SizedBox(height: 48),

                    // --- Footer ---
                    const Divider(color: _border, thickness: 1),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        if (widget.onContactUs != null) {
                          await widget.onContactUs!();
                        }
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.support_agent_rounded,
                                color: _muted, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Need Help? Contact Support",
                              style: TextStyle(
                                color: _muted,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- Legal Links ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                            if (widget.onTermsOfUse != null) {
                              await widget.onTermsOfUse!();
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              "Terms of Use",
                              style: TextStyle(
                                color: _muted,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                        const Text("•",
                            style: TextStyle(color: _border, fontSize: 12)),
                        InkWell(
                          onTap: () async {
                            if (widget.onPrivacyPolicy != null) {
                              await widget.onPrivacyPolicy!();
                            }
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: Text(
                              "Privacy Policy",
                              style: TextStyle(
                                color: _muted,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimerWidget() {
    String days = _timeLeft.inDays.toString().padLeft(2, '0');
    String hours = (_timeLeft.inHours % 24).toString().padLeft(2, '0');
    String minutes = (_timeLeft.inMinutes % 60).toString().padLeft(2, '0');
    String seconds = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    String endDateStr = "${months[_endDate.month - 1]} ${_endDate.day}";

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: _fieldBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 15,
                offset: Offset(0, 5),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _timeBox(days, "DAYS"),
              _timeColon(),
              _timeBox(hours, "HRS"),
              _timeColon(),
              _timeBox(minutes, "MINS"),
              _timeColon(),
              _timeBox(seconds, "SECS"),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Flash Sale Ends $endDateStr",
          style: const TextStyle(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _timeBox(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: _white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: _heading,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _timeColon() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: EdgeInsets.only(bottom: 14),
        child: Text(
          ":",
          style: TextStyle(
            color: _border,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumYearlyCard(
    String rawPriceString, {
    bool isTablet = false,
    bool isCompactTablet = false,
  }) {
    final priceData = _parsePriceInfo(
      rawPriceString,
      fallbackNumber: "19.99",
      fallbackOriginal: "\$26.65",
    );
    final String mainPrice = priceData['mainPrice']!;
    final String suffixText = priceData['suffix']!;
    final String originalPrice = priceData['originalPrice']!;

    final EdgeInsets cardPadding = isCompactTablet
        ? const EdgeInsets.fromLTRB(22, 28, 22, 24)
        : const EdgeInsets.all(28);
    final double priceFontSize = isCompactTablet ? 40 : (isTablet ? 44 : 48);
    final double suffixFontSize = isCompactTablet ? 16 : 18;
    final double featureFontSize = isCompactTablet ? 14 : 15;
    final double buttonHeight = isCompactTablet ? 52 : 56;
    final double buttonFontSize = isCompactTablet ? 16 : 17;

    List<String> hypedFeatures = [
      "Full Access to MSFS 2020, 2024 & X-Plane 11/12",
      "Unrestricted Annual App Access",
      "All Updates Included During Subscription",
      "Instant Unlock to All Premium Tools",
      "Connect to unlimited devices seamlessly",
      "Priority VIP Customer Support",
    ];

    return Container(
      width: isTablet ? null : double.infinity,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 15,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Elegant Discount Badge using your _good color (25% OFF)
          Positioned(
            top: -14,
            right: isCompactTablet ? 18 : 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _good,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _good.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Text(
                "SAVE 25% TODAY",
                style: TextStyle(
                  color: Color(0xFF0B111A),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          Padding(
            padding: cardPadding,
            child: Column(
              mainAxisSize: isTablet ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ANNUAL 2-IN-1 PASS",
                  style: TextStyle(
                    color: _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // --- Smart Pricing Area ---
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      mainPrice,
                      style: TextStyle(
                        color: _white,
                        fontSize: priceFontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    if (suffixText.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: isCompactTablet ? 6 : 8,
                          left: 2,
                        ),
                        child: Text(
                          suffixText,
                          style: TextStyle(
                            color: _muted,
                            fontSize: suffixFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: isCompactTablet ? 8 : 10,
                        left: 8,
                      ),
                      child: Text(
                        originalPrice,
                        style: TextStyle(
                          color: _muted,
                          fontSize: suffixFontSize,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: _muted,
                          decorationThickness: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Text(
                  "Billed annually. Cancel anytime.",
                  style: TextStyle(
                    color: _muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: isCompactTablet ? 26 : 32),

                // Features List
                Column(
                  children: hypedFeatures
                      .map((feat) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: _accent, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feat,
                                    style: TextStyle(
                                      color: _white,
                                      fontSize: featureFontSize,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),

                if (isTablet) const Spacer(),
                SizedBox(height: isCompactTablet ? 24 : 32),

                // CTA Button (Using your active button style)
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (widget.onBuyYearly != null) {
                        await widget.onBuyYearly!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonDark,
                      foregroundColor: _white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: _accent, width: 1.5),
                      ),
                      shadowColor: _accent.withOpacity(0.5),
                    ).copyWith(
                      elevation: MaterialStateProperty.all(8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "CLAIM 25% OFF NOW",
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumLifetimeCard(
    String rawPriceString, {
    bool isTablet = false,
    bool isCompactTablet = false,
  }) {
    final priceData = _parsePriceInfo(
      rawPriceString,
      fallbackNumber: "39.99",
      fallbackOriginal: "\$53.32",
    );
    final String mainPrice = priceData['mainPrice']!;
    final String suffixText = priceData['suffix']!;
    final String originalPrice = priceData['originalPrice']!;

    final EdgeInsets cardPadding = isCompactTablet
        ? const EdgeInsets.fromLTRB(22, 28, 22, 24)
        : const EdgeInsets.all(28);
    final double priceFontSize = isCompactTablet ? 40 : (isTablet ? 44 : 48);
    final double suffixFontSize = isCompactTablet ? 16 : 18;
    final double featureFontSize = isCompactTablet ? 14 : 15;
    final double buttonHeight = isCompactTablet ? 52 : 56;
    final double buttonFontSize = isCompactTablet ? 16 : 17;

    List<String> hypedFeatures = [
      "Full Access to MSFS 2020, 2024 & X-Plane 11/12",
      "Unrestricted Lifetime App Access",
      "Free Updates Forever (Never pay again)",
      "Instant Unlock to All Premium Tools",
      "Connect to unlimited devices seamlessly",
      "Priority VIP Customer Support",
    ];

    return Container(
      width: isTablet ? null : double.infinity,
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Top Badges Row (RECOMMENDED + SAVE 25% TODAY)
          Positioned(
            top: -14,
            left: isCompactTablet ? 14 : 20,
            right: isCompactTablet ? 14 : 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Clean Classic Star Pill Badge
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompactTablet ? 10 : 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _accent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _accent.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.star_rounded,
                            color: Color(0xFF0B111A),
                            size: 15,
                          ),
                          SizedBox(width: 4),
                          Text(
                            "RECOMMENDED",
                            style: TextStyle(
                              color: Color(0xFF0B111A),
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Discount Badge
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isCompactTablet ? 11 : 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _good,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: _good.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "SAVE 25% TODAY",
                        style: TextStyle(
                          color: Color(0xFF0B111A),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: cardPadding,
            child: Column(
              mainAxisSize: isTablet ? MainAxisSize.max : MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ULTIMATE 2-IN-1 PASS",
                  style: TextStyle(
                    color: _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),

                // --- Smart Pricing Area ---
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      mainPrice,
                      style: TextStyle(
                        color: _white,
                        fontSize: priceFontSize,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    if (suffixText.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: isCompactTablet ? 6 : 8,
                          left: 2,
                        ),
                        child: Text(
                          suffixText,
                          style: TextStyle(
                            color: _muted,
                            fontSize: suffixFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: isCompactTablet ? 8 : 10,
                        left: 8,
                      ),
                      child: Text(
                        originalPrice,
                        style: TextStyle(
                          color: _muted,
                          fontSize: suffixFontSize,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: _muted,
                          decorationThickness: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                const Text(
                  "One payment. Endless flights.",
                  style: TextStyle(
                    color: _muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: isCompactTablet ? 26 : 32),

                // Features List
                Column(
                  children: hypedFeatures
                      .map((feat) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: _accent, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feat,
                                    style: TextStyle(
                                      color: _white,
                                      fontSize: featureFontSize,
                                      fontWeight: FontWeight.w600,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),

                if (isTablet) const Spacer(),
                SizedBox(height: isCompactTablet ? 24 : 32),

                // CTA Button (Using your active button style)
                SizedBox(
                  width: double.infinity,
                  height: buttonHeight,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (widget.onBuyLifetime != null) {
                        await widget.onBuyLifetime!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonDark,
                      foregroundColor: _white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: _accent, width: 1.5),
                      ),
                      shadowColor: _accent.withOpacity(0.5),
                    ).copyWith(
                      elevation: MaterialStateProperty.all(8),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "CLAIM 25% OFF NOW",
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
