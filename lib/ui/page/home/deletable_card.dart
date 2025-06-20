import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class DeletableCard extends StatefulWidget {
  final VoidCallback? onDeleted;
  final Widget? child;

  const DeletableCard({super.key, this.child, this.onDeleted});

  @override
  State<DeletableCard> createState() => _DeletableCardState();
}

class _DeletableCardState extends State<DeletableCard>
    with SingleTickerProviderStateMixin {
  late final SlidableController _slidableController;
  double _elevation = 0;
  double _iconSize = 0;

  @override
  void initState() {
    super.initState();
    _slidableController = SlidableController(this);
    _slidableController.animation.addListener(_handleAnimationUpdate);
  }

  @override
  void dispose() {
    _slidableController.animation.removeListener(_handleAnimationUpdate);
    _slidableController.dispose();
    super.dispose();
  }

  void _handleAnimationUpdate() {
    final animation = _slidableController.animation;
    setState(() {
      _elevation = (animation.value * 20).clamp(0, 4);
      _iconSize = (animation.value * 100).clamp(0, 24);
    });
  }

  CustomSlidableAction _buildDeleteAction(BuildContext context) {
    return CustomSlidableAction(
      onPressed: (_) => widget.onDeleted?.call(),
      foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
      backgroundColor: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: Icon(Icons.delete, size: _iconSize),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.99,
      child: Stack(
        children: [
          Positioned.fill(
            child: Card.filled(
              color: Theme.of(context).colorScheme.errorContainer,
              margin: EdgeInsets.zero,
            ),
          ),
          Slidable(
            controller: _slidableController,
            endActionPane: ActionPane(
              openThreshold: 0.33,
              extentRatio: 0.33,
              motion: const BehindMotion(),
              children: [_buildDeleteAction(context)],
            ),
            startActionPane: ActionPane(
              openThreshold: 0.33,
              extentRatio: 0.33,
              motion: const BehindMotion(),
              children: [_buildDeleteAction(context)],
            ),
            child: Transform.scale(
              scale: 1.01,
              child: Card.filled(
                margin: EdgeInsets.zero,
                elevation: _elevation,
                child: widget.child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
