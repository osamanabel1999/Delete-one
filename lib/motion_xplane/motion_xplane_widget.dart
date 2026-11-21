import '/flutter_flow/flutter_flow_ad_banner.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/widgets/index.dart' as custom_widgets;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'motion_xplane_model.dart';
export 'motion_xplane_model.dart';

class MotionXplaneWidget extends StatefulWidget {
  const MotionXplaneWidget({super.key});

  static String routeName = 'MotionXplane';
  static String routePath = '/motionXplane';

  @override
  State<MotionXplaneWidget> createState() => _MotionXplaneWidgetState();
}

class _MotionXplaneWidgetState extends State<MotionXplaneWidget> {
  late MotionXplaneModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => MotionXplaneModel());
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (responsiveVisibility(
              context: context,
              phone: false,
              tablet: false,
              tabletLandscape: false,
              desktop: false,
            ))
              Align(
                alignment: AlignmentDirectional(0.0, 1.0),
                child: FlutterFlowAdBanner(
                  width: MediaQuery.sizeOf(context).width * 1.0,
                  height: 50.0,
                  showsTestAd: false,
                  iOSAdUnitID: 'ca-app-pub-7880697829268273/6177072322',
                  androidAdUnitID: 'ca-app-pub-7880697829268273/5581116466',
                ),
              ),
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: custom_widgets.MotionXplane(
                  width: double.infinity,
                  height: double.infinity,
                  targetIp: FFAppState().ipPC,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
