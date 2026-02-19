
import 'package:flutter/material.dart';

import '../../../configurations/localization/i18n.dart';
import '../../custom_widgets/custom_dialog.dart';

Future showErrorDialog({required BuildContext context,required message,required description}) async {
  return await showDialog(
  context: context,
  builder: (ctx) {
    return CustomDialog(
      color: Colors.redAccent,
      icon: Icons.report_outlined,
      message: message,
      description: description,
      confirmButton: () {
        Navigator.pop(context);
      },
      confirmButtonTitle: S.of(context)!.reTry,
      cancelButton: false,
    );
  });
}

Future showNoteDialog({
  required Function? onTap,
  required BuildContext context,
  required message,
  required description,
  required confirmButtonTitle,
}) async {
  return await showDialog(
  context: context,
  builder: (ctx) {
    return CustomDialog(
      color: Colors.blueAccent,
      // icon: FontAwesomeIcons.faceSmile,
      message: message,
      description: description,
      confirmButton: onTap,
      confirmButtonTitle: confirmButtonTitle,
      cancelButton: false,
    );
  });
}