import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../../configurations/helpers_functions.dart';
import '../../configurations/localization/i18n.dart';
import 'custom_text.dart';

class CustomDialog extends StatelessWidget {
  final String message;
  final IconData icon;
  final Function? confirmButton;
  final Function? cancelButtonFun;
  final bool cancelButton;
  final bool disableIcon;
  final String? cancelButtonTitle;
  final String? confirmButtonTitle;
  final String? description;
  final Color color;
  final List<Widget>? widgets;

  const CustomDialog({
    Key? key,
    required this.message,
    this.icon = Icons.warning,
    required this.confirmButton,
    this.cancelButton = true,
    this.confirmButtonTitle,
    this.cancelButtonTitle,
    this.cancelButtonFun,
    this.description,
    this.widgets,
    this.disableIcon = false,
    this.color = Colors.red,
  }) : super(key: key);
  // f(AnimationController controller){
  //   return controller;
  // }
  // AnimationController controller = AnimationController(vsync: this);
  @override
  Widget build(BuildContext context) {
    return ZoomIn(
      duration: const Duration(milliseconds: 400),
      // animate: true,controller: () => ,
      child: Dialog(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10), color: Colors.white),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                disableIcon
                    ? Container()
                    : Container(
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10)),
                            color: color),
                        height: 130,
                        width: widthOfScreen(context),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CustomText(
                    title: message,
                    color: Colors.black,
                    textAlign: TextAlign.center,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                if (description != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomText(
                      title: description!,
                      textAlign: TextAlign.center,
                          color: Colors.black,
                          size: Theme.of(context).textTheme!.bodySmall!.fontSize,
                          // fontFamily: fontFamily,
                          fontWeight: FontWeight.normal),
                  ),
                if (description != null)
                  const SizedBox(
                    height: 15,
                  ),
                if (widgets != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: widgets!,
                    ),
                  ),
                if (widgets != null)
                  const SizedBox(
                    height: 15,
                  ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (cancelButton)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: cancelButtonFun == null
                                ? () async {
                                    Navigator.pop(context);
                                  }
                                : () => cancelButtonFun!(),
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(2.0),
                              backgroundColor: MaterialStateProperty.all(
                                color.withOpacity(0.7),
                              ),
                              shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                              ),
                            ),
                            child: Text(
                              cancelButtonTitle ?? S.of(context)!.no,
                              style: const TextStyle(
                                color: Colors.white,
                                // fontFamily: fontFamily
                              ),
                            ),
                          ),
                        ),
                      ElevatedButton(
                        onPressed: () => confirmButton!(),
                        style: ButtonStyle(
                          elevation: MaterialStateProperty.all(2.0),
                          backgroundColor: MaterialStateProperty.all(
                            color,
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                          ),
                        ),
                        child: Text(
                          confirmButtonTitle ?? S.of(context)!.yes,
                          style: const TextStyle(
                            color: Colors.white,
                            // fontFamily: fontFamily
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
