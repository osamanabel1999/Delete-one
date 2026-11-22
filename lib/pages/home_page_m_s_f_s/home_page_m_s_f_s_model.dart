import '/backend/api_requests/api_calls.dart';
import '/components/failure_widget.dart';
import '/flutter_flow/ff_builtin_enums.dart';
import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/instant_timer.dart';
import 'dart:ui';
import '/actions/actions.dart' as action_blocks;
import '/custom_code/actions/index.dart' as actions;
import '/custom_code/widgets/index.dart' as custom_widgets;
import '/flutter_flow/custom_functions.dart' as functions;
import '/index.dart';
import 'home_page_m_s_f_s_widget.dart' show HomePageMSFSWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class HomePageMSFSModel extends FlutterFlowModel<HomePageMSFSWidget> {
  ///  Local state fields for this page.

  int currentStep = 1;

  double currentTime = 12.0;

  String generatedKey = 'mnmn';

  dynamic selectedRunway;

  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Backend Call - API (GetSimBriefFlight)] action in HomePageMSFS widget.
  ApiCallResponse? simbreifResponse;
  InstantTimer? instantTimer;
  // Stores action output result for [Custom Action - getFlightData] action in HomePageMSFS widget.
  dynamic? flightDataMFSF;
  // Stores action output result for [Custom Action - calculateA320SpeedsFull] action in ToPerformanceWidget widget.
  dynamic? speedsResult1;
  // Stores action output result for [Custom Action - calculateA320Landing] action in LdaPerformanceWidget widget.
  dynamic? calculateA320LandingNew;
  // Stores action output result for [Backend Call - API (GetSimBriefFlight)] action in ColumnFlightPlanxxx widget.
  ApiCallResponse? simbreifResponse1;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered1 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered2 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered3 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered4 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered5 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered6 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered7 = false;
  // State field(s) for MouseRegion widget.
  bool mouseRegionHovered8 = false;
  // Stores action output result for [Backend Call - API (GetElevation)] action in EliteAviationEFB widget.
  ApiCallResponse? elevationDataMSFSrwy;
  // Stores action output result for [Backend Call - API (GetElevation)] action in EliteAviationEFB widget.
  ApiCallResponse? elevationDataMSFSgate;
  // Stores action output result for [Backend Call - API (GetElevation)] action in EliteAviationEFB widget.
  ApiCallResponse? elevationDataMSFSchartGate;
  // Stores action output result for [Backend Call - API (GetElevation)] action in EliteAviationEFB widget.
  ApiCallResponse? elevationDataMSFSANAVAIDS;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    instantTimer?.cancel();
  }
}
