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

class Bfmccheckout extends StatefulWidget {
  const Bfmccheckout({
    Key? key,
    this.width,
    this.height,
    this.monthlyPrice,
    this.yearlyPrice,
    this.lifetimePrice,
    this.onBuyMonthly,
    this.onBuyYearly,
    this.onBuyLifetime,
    this.onContactUs,
    this.onBuyBothSims,
    this.onTermsOfUse,
    this.onPrivacyPolicy,
  }) : super(key: key);

  final double? width;
  final double? height;
  final String? monthlyPrice;
  final String? yearlyPrice;
  final String? lifetimePrice;
  final Future Function()? onBuyMonthly;
  final Future Function()? onBuyYearly;
  final Future Function()? onBuyLifetime;
  final Future Function()? onContactUs;
  final Future Function()? onBuyBothSims;
  final Future Function()? onTermsOfUse;
  final Future Function()? onPrivacyPolicy;

  @override
  _BfmccheckoutState createState() => _BfmccheckoutState();
}

class _BfmccheckoutState extends State<Bfmccheckout> {
  // Exact Design System Colors
  static const Color _bg = Color(0xFF0B111A);
  static const Color _card = Color(0xFF101923);
  static const Color _fieldBg = Color(0xFF0B1521);
  static const Color _border = Color(0xFF26364D);
  static const Color _accent = Color(0xFF639DF0);
  static const Color _buttonDark = Color(0xFF15335E);
  static const Color _directionInactive = Color(0xFF0A1420);
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
    // 3 Days rolling cycle
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

  // Regex to extract price and calculate original price (25% off)
  Map<String, String> _parsePriceInfo(
    String fullText, {
    required String fallbackNumber,
    required String fallbackOriginal,
    String defaultSuffix = "",
  }) {
    String prefix = "\$";
    String numberStr = fallbackNumber;
    String suffix = defaultSuffix;
    String originalPriceStr = fallbackOriginal;

    try {
      final regex = RegExp(r'^([^\d]*)(\d+(?:\.\d+)?)\s*(.*)$');
      final match = regex.firstMatch(fullText);

      if (match != null) {
        prefix = match.group(1)?.trim() ?? "";
        numberStr = match.group(2) ?? fallbackNumber;
        String parsedSuffix = match.group(3)?.trim() ?? "";
        suffix = parsedSuffix.isNotEmpty ? parsedSuffix : defaultSuffix;

        double currentPriceNum = double.parse(numberStr);
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
      'originalPrice': originalPriceStr,
    };
  }

  @override
  Widget build(BuildContext context) {
    final String currentMonthlyPriceRaw =
        widget.monthlyPrice ?? "\$2.99 / month";
    final String currentYearlyPriceRaw = widget.yearlyPrice ?? "\$12.99 / year";
    final String currentLifetimePriceRaw =
        widget.lifetimePrice ?? "\$19.99 one-time";

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? double.infinity,
      color: _bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "X-Plane\nUltimate Pass",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "All plans include full, unrestricted access to the entire application. Simply choose your preferred duration.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // --- Elegant Countdown Timer ---
            _buildTimerWidget(),

            const SizedBox(height: 32),

            // --- PLAN 1: Monthly Card ---
            _buildPremiumMonthlyCard(currentMonthlyPriceRaw),

            const SizedBox(height: 32),

            // --- PLAN 2: Yearly Card ---
            _buildPremiumYearlyCard(currentYearlyPriceRaw),

            const SizedBox(height: 36),

            // --- PLAN 3: Lifetime Card (RECOMMENDED) ---
            _buildPremiumLifetimeCard(currentLifetimePriceRaw),

            const SizedBox(height: 32),

            // --- Clean Bundle Offer ---
            _buildBundleOffer(),

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.support_agent_rounded, color: _muted, size: 20),
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
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                const Text("•", style: TextStyle(color: _border, fontSize: 12)),
                InkWell(
                  onTap: () async {
                    if (widget.onPrivacyPolicy != null) {
                      await widget.onPrivacyPolicy!();
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
          "Offer ends $endDateStr",
          style: const TextStyle(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
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

  Widget _buildPremiumMonthlyCard(String rawPriceString) {
    final priceData = _parsePriceInfo(
      rawPriceString,
      fallbackNumber: "2.99",
      fallbackOriginal: "\$3.99",
      defaultSuffix: "/ month",
    );
    final String mainPrice = priceData['mainPrice']!;
    final String suffixText = priceData['suffix']!;
    final String originalPrice = priceData['originalPrice']!;

    List<String> hypedFeatures = [
      "Monthly Unrestricted Full Access",
      "Valid for 30 Days with All Updates",
      "Instant Unlock to All Premium Features",
      "Billed Monthly, Cancel Anytime",
      "Priority VIP Customer Support",
      "Connect to unlimited devices seamlessly",
    ];

    return Container(
      width: double.infinity,
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
          Positioned(
            top: -14,
            right: 24,
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
                "SAVE 25%",
                style: TextStyle(
                  color: Color(0xFF0B111A),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "MONTHLY ACCESS",
                  style: TextStyle(
                    color: _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      mainPrice,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    if (suffixText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 2),
                        child: Text(
                          suffixText,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, left: 8),
                      child: Text(
                        originalPrice,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 18,
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
                  "30 days access. Cancel anytime.",
                  style: TextStyle(
                    color: _muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
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
                                    style: const TextStyle(
                                      color: _white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (widget.onBuyMonthly != null) {
                        await widget.onBuyMonthly!();
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
                    child: const Text(
                      "Get Monthly Pass",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
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

  Widget _buildPremiumYearlyCard(String rawPriceString) {
    final priceData = _parsePriceInfo(
      rawPriceString,
      fallbackNumber: "12.99",
      fallbackOriginal: "\$17.32",
      defaultSuffix: "/ year",
    );
    final String mainPrice = priceData['mainPrice']!;
    final String suffixText = priceData['suffix']!;
    final String originalPrice = priceData['originalPrice']!;

    List<String> hypedFeatures = [
      "Annual Unrestricted Full Access",
      "All Updates Included During Subscription",
      "Instant Unlock to All Premium Features",
      "Billed Annually, Cancel Anytime",
      "Priority VIP Customer Support",
      "Connect to unlimited devices seamlessly",
    ];

    return Container(
      width: double.infinity,
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
          Positioned(
            top: -14,
            right: 24,
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
                "SAVE 25%",
                style: TextStyle(
                  color: Color(0xFF0B111A),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ANNUAL ACCESS",
                  style: TextStyle(
                    color: _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      mainPrice,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    if (suffixText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 2),
                        child: Text(
                          suffixText,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, left: 8),
                      child: Text(
                        originalPrice,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 18,
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
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
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
                                    style: const TextStyle(
                                      color: _white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
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
                    child: const Text(
                      "Claim Yearly Pass",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
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

  Widget _buildPremiumLifetimeCard(String rawPriceString) {
    final priceData = _parsePriceInfo(
      rawPriceString,
      fallbackNumber: "19.99",
      fallbackOriginal: "\$26.65",
      defaultSuffix: "one-time",
    );
    final String mainPrice = priceData['mainPrice']!;
    final String suffixText = priceData['suffix']!;
    final String originalPrice = priceData['originalPrice']!;

    List<String> hypedFeatures = [
      "Lifetime Unrestricted Full Access",
      "Free Updates Forever (Never pay again)",
      "Instant Unlock to All Premium Features",
      "One-Time Payment, Zero Hidden Fees",
      "Priority VIP Customer Support",
      "Connect to unlimited devices seamlessly",
    ];

    return Container(
      width: double.infinity,
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
          // Top Badges Row (RECOMMENDED + SAVE 25%)
          Positioned(
            top: -14,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Clean Classic Star Pill Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ],
                  ),
                ),

                // Discount Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                    "SAVE 25%",
                    style: TextStyle(
                      color: Color(0xFF0B111A),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "LIFETIME ACCESS",
                  style: TextStyle(
                    color: _accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.end,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      mainPrice,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    if (suffixText.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8, left: 2),
                        child: Text(
                          suffixText,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, left: 8),
                      child: Text(
                        originalPrice,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 18,
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
                  "Pay once. Own it forever.",
                  style: TextStyle(
                    color: _muted,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 32),
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
                                    style: const TextStyle(
                                      color: _white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
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
                    child: const Text(
                      "Get Lifetime Access",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
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

  Widget _buildBundleOffer() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _directionInactive,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _card,
                shape: BoxShape.circle,
                border: Border.all(color: _border),
              ),
              child: const Icon(Icons.flight_takeoff_rounded,
                  color: _heading, size: 28),
            ),
            const SizedBox(height: 16),
            const Text(
              "ULTIMATE EXPERIENCE",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _heading,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Fly on both X-Plane & MSFS?",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Get the Ultimate 2-in-1 Bundle at a massive discount.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () async {
                  if (widget.onBuyBothSims != null) {
                    await widget.onBuyBothSims!();
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _white,
                  side: const BorderSide(color: _border, width: 1.5),
                  backgroundColor: _card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "View Bundle Offer",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
