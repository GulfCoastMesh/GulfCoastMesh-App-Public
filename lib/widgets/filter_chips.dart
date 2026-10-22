import 'package:flutter/material.dart';

class FilterChipItem<T> {
  final T value;
  final String label;
  final int? count;

  const FilterChipItem({required this.value, required this.label, this.count});
}

class FilterChipRow<T> extends StatelessWidget {
  final List<FilterChipItem<T>> items;
  final T selected;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;

  const FilterChipRow({
    super.key,
    required this.items,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.fromLTRB(8, 0, 8, 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              _PillChip(
                label: items[i].label,
                count: items[i].count,
                selected: items[i].value == selected,
                onTap: () => onSelected(items[i].value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  const _PillChip({
    required this.label,
    this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = selected
        ? scheme.primary
        : scheme.surfaceContainerHighest.withValues(alpha: 0.85);
    final fg = selected ? scheme.onPrimary : scheme.onSurface;

    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      backgroundColor: bg,
      selectedColor: bg,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      labelPadding: const EdgeInsets.symmetric(horizontal: 8),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: fg,
            ),
          ),
          if (count != null && count! > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.onPrimary.withValues(alpha: 0.2)
                    : scheme.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count! > 99 ? '99+' : '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: selected ? scheme.onPrimary : scheme.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
