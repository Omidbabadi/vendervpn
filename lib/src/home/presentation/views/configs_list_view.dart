import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vendervpn/core/common/app/riverpod/current_configs_list.dart';
import 'package:vendervpn/src/home/presentation/views/server_tile.dart';

class ServerListScreen extends ConsumerWidget {
  const ServerListScreen({super.key});
  static const path = '/servers';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final configs = ref.watch(currentConfigsListProvider);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          children: [
            _Header(isDark: isDark),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: configs.length,
                itemBuilder: (_, index) {
                  return ServerTile(
                    dimmed: false,
                    config: configs[index],
                    country: configs[index].country ?? 'N/A',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDark;
  const _Header({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF101622) : const Color(0xFFF6F6F8))
            .withOpacity(0.95),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1A2436) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Select Location',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () {}),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final bool isDark;
  const _SearchBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search country or city...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: isDark ? const Color(0xFF1A2436) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final bool isDark;

  const _SegmentedControl({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A2436) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: List.generate(3, (i) {
            final labels = ['All Locations', 'Favorites', 'Streaming'];
            final selected = value == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(i),
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        selected ? const Color(0xFF135BEC) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.grey,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
