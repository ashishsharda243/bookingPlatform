import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hall_booking_platform/core/theme/app_spacing.dart';
import 'package:hall_booking_platform/core/widgets/empty_state_widget.dart';
import 'package:hall_booking_platform/features/discovery/presentation/providers/discovery_providers.dart';
import 'package:hall_booking_platform/features/discovery/presentation/widgets/hall_card.dart';

/// Paginated list of hall cards with infinite scroll support.
/// Requirement 2.5, 2.7, 19.6.
class HallListView extends ConsumerStatefulWidget {
  const HallListView({
    super.key,
    required this.lat,
    required this.lng,
  });

  final double lat;
  final double lng;

  @override
  ConsumerState<HallListView> createState() => _HallListViewState();
}

class _HallListViewState extends ConsumerState<HallListView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(hallListProvider.notifier);
      if (notifier.hasMore && !notifier.isLoadingMore) {
        notifier.loadMore(lat: widget.lat, lng: widget.lng);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hallsState = ref.watch(hallListProvider);

    return hallsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text('Failed to load halls: $error'),
      ),
      data: (halls) {
        if (halls.isEmpty) {
          return const EmptyStateWidget(
            message: 'No halls found nearby',
            icon: Icons.location_off,
          );
        }

        final notifier = ref.read(hallListProvider.notifier);

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          itemCount: halls.length + (notifier.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= halls.length) {
              return const Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            final hall = halls[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: HallCard(
                hall: hall,
                onTap: () => context.push('/hall/${hall.id}'),
              ),
            );
          },
        );
      },
    );
  }
}
