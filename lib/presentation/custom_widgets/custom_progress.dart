// library flutter_progress_hud;

import 'package:flutter/material.dart';
import '../../configurations/resources/app_colors.dart';
import 'custom_text.dart';

// import '../constants.dart';

class CustomProgress extends StatefulWidget {
  final Widget child;
  final Color? color;
  final Color? indicatorColor;
  final Widget? indicatorWidget;
  final Color backgroundColor;
  final Radius backgroundRadius;
  final Color borderColor;
  final double borderWidth;
  final bool barrierEnabled;
  final Color barrierColor;
  final TextStyle textStyle;
  final EdgeInsetsGeometry padding;

  // var screenHeight;

  const CustomProgress(
      {super.key,
      required this.child,
      this.indicatorColor = Colors.black87,
      this.indicatorWidget,
      this.color,
      this.backgroundColor = const Color(0xb3fdc53a),
      // this.backgroundColor = Colors.white70,
      this.backgroundRadius = const Radius.circular(8.0),
      this.borderColor = const Color(0xff840200),
      this.borderWidth = 1.0,
      this.barrierEnabled = true,
      this.barrierColor = Colors.black12,
      this.textStyle = const TextStyle(
          color: Colors.black87, fontSize: 16.0, fontFamily: 'Main'),
      this.padding = const EdgeInsets.all(16.0)})
      : assert(child != null);

  static _CustomProgressState of(BuildContext context) {
    final progressHudState =
        context.findAncestorStateOfType<_CustomProgressState>();

    assert(() {
      if (progressHudState == null) {
        throw FlutterError(
            'ProgressHUD operation requested with a context that does not include a ProgressHUD.\n'
            'The context used to show ProgressHUD must be that of a widget '
            'that is a descendant of a ProgressHUD widget.');
      }
      return true;
    }());

    return progressHudState!;
  }

  @override
  _CustomProgressState createState() => _CustomProgressState();
}

class _CustomProgressState extends State<CustomProgress>
    with SingleTickerProviderStateMixin {
  bool _isShow = false;
  bool _barrierVisible = false;
  String? _text;

  late AnimationController _controller;
  late Animation<double> _animation;

  void show() {
    setState(() {
      _text = null;
      _controller.forward();
      _isShow = true;
    });
  }

  void showWithText(String text) {
    setState(() {
      _text = text;
      _controller.forward();
      _isShow = true;
    });
  }

  void dismiss() {
    setState(() {
      _controller.reverse();
      _isShow = false;
    });
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    );

    _animation.addStatusListener((status) {
      setState(() {
        _barrierVisible = status != AnimationStatus.dismissed;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (widget.barrierEnabled) {
      children.add(
        Visibility(
          visible: _barrierVisible,
          child: ModalBarrier(
            color: widget.barrierColor,
          ),
        ),
      );
    }
    children.add(Center(child: _buildProgress()));

    return Stack(
      children: <Widget>[
        widget.child,
        IgnorePointer(
          ignoring: !_isShow,
          child: TickerMode(
            enabled: _isShow,
            child: FadeTransition(
              opacity: _animation,
              child: Stack(children: children),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    final contentChildren = <Widget>[
      _buildDefaultIndicator(),
    ];

    if (_text != null) {
      if (_text!.isNotEmpty) {
        contentChildren.addAll(<Widget>[
          const SizedBox(height: 16.0),
          CustomText(
            title: _text!,
            color: AppColors.current.success,
            // color: Colors.black,
          ),
        ]);
      }
    }

    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.all(widget.backgroundRadius),
          border: Border.all(
            color: widget.borderColor,
            width: widget.borderWidth,
          )),
      child: FittedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: contentChildren,
        ),
      ),
    );
  }

  Widget _buildDefaultIndicator() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
            widget.color ?? AppColors.current.primary.withOpacity(0.8)),
      ),
    );
  }
}
