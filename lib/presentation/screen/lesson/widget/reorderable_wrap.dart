import 'package:flutter/material.dart';

class ReorderableWrap extends StatefulWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final void Function(int, int) onReorder;

  const ReorderableWrap({
    required this.children,
    required this.onReorder,
    this.spacing = 0,
    this.runSpacing = 0,
    Key? key,
  }) : super(key: key);

  @override
  _ReorderableWrapState createState() => _ReorderableWrapState();
}

class _ReorderableWrapState extends State<ReorderableWrap> {
  late List<Widget> _children;

  @override
  void initState() {
    super.initState();
    _children = widget.children;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      children: _children,
    );
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _children.removeAt(oldIndex);
      _children.insert(newIndex, item);
    });
    widget.onReorder(oldIndex, newIndex);
  }
}