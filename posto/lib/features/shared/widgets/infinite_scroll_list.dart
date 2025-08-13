import 'package:flutter/material.dart';

class InfiniteScrollList extends StatefulWidget {
  final int itemCount;
  final bool isLoadingMore;
  final bool canLoadMore;
  final Future<void> Function() fetchMoreData;
  final IndexedWidgetBuilder itemBuilder;

  // Forwarded ListView.builder parameters
  final bool reverse;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final Axis scrollDirection;
  final ScrollController? controller;
  final bool primary;

  const InfiniteScrollList({
    super.key,
    required this.itemCount,
    required this.isLoadingMore,
    required this.canLoadMore,
    required this.fetchMoreData,
    required this.itemBuilder,
    this.reverse = false,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
    this.scrollDirection = Axis.vertical,
    this.controller,
    this.primary = false,
  });

  @override
  State<InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> with WidgetsBindingObserver {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _controller = widget.controller ?? ScrollController();
    _controller.addListener(_onScroll);

    _ensureScrollable();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    _ensureScrollable();
  }

  void _ensureScrollable() {
    // Wait one frame to allow list rebuild with new data
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (widget.isLoadingMore) return;
      if (!widget.canLoadMore) return;
      if (_controller.position.maxScrollExtent > 0) return;

      await widget.fetchMoreData();

      _ensureScrollable();
    });
  }

  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 200 &&
        widget.canLoadMore &&
        !widget.isLoadingMore) {
      widget.fetchMoreData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalCount = widget.itemCount + (widget.isLoadingMore ? 1 : 0);

    return ListView.builder(
      controller: _controller,
      reverse: widget.reverse,
      padding: widget.padding,
      shrinkWrap: widget.shrinkWrap,
      physics: widget.physics,
      scrollDirection: widget.scrollDirection,
      primary: widget.primary,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index < widget.itemCount) {
          return widget.itemBuilder(context, index);
        }

        if (widget.isLoadingMore) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return const Text('Inicio da conversa');
      },
    );
  }
}
