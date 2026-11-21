import '/flutter_flow/ff_builtin_enums.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'dart:ui';
import '/custom_code/actions/index.dart' as actions;
import '/index.dart';
import 'i_ppage_xplane_widget.dart' show IPpageXplaneWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class IPpageXplaneModel extends FlutterFlowModel<IPpageXplaneWidget> {
  ///  State fields for stateful widgets in this page.

  // Stores action output result for [Custom Action - restoreAllSubscriptions] action in IPpageXplane widget.
  dynamic? xplanePageRes;
  // State field(s) for TextFieldipPc widget.
  FocusNode? textFieldipPcFocusNode;
  TextEditingController? textFieldipPcTextController;
  String? Function(BuildContext, String?)? textFieldipPcTextControllerValidator;
  // State field(s) for TextFieldSimbreifID widget.
  FocusNode? textFieldSimbreifIDFocusNode;
  TextEditingController? textFieldSimbreifIDTextController;
  String? Function(BuildContext, String?)?
      textFieldSimbreifIDTextControllerValidator;
  // State field(s) for TextFieldIVAOid widget.
  FocusNode? textFieldIVAOidFocusNode;
  TextEditingController? textFieldIVAOidTextController;
  String? Function(BuildContext, String?)?
      textFieldIVAOidTextControllerValidator;
  // State field(s) for TextFieldSessionID widget.
  FocusNode? textFieldSessionIDFocusNode;
  TextEditingController? textFieldSessionIDTextController;
  String? Function(BuildContext, String?)?
      textFieldSessionIDTextControllerValidator;
  // Stores action output result for [Custom Action - restoreAllSubscriptions] action in RichTextSpan widget.
  dynamic? restoreRes2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldipPcFocusNode?.dispose();
    textFieldipPcTextController?.dispose();

    textFieldSimbreifIDFocusNode?.dispose();
    textFieldSimbreifIDTextController?.dispose();

    textFieldIVAOidFocusNode?.dispose();
    textFieldIVAOidTextController?.dispose();

    textFieldSessionIDFocusNode?.dispose();
    textFieldSessionIDTextController?.dispose();
  }
}
