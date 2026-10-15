import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../theme/tokens.dart';
import 'cards.dart';
import 'dialogs.dart';

/// Rounded search field
class SearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final String initial;
  final bool autofocus;

  const SearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.initial = '',
    this.autofocus = false,
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      textInputAction: TextInputAction.search,
      onChanged: (v) {
        setState(() {});
        widget.onChanged(v);
      },
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(999)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(999)),
          borderSide: BorderSide(color: context.cs.primary, width: 2),
        ),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Clear',
                onPressed: () {
                  _controller.clear();
                  setState(() {});
                  widget.onChanged('');
                },
              ),
      ),
    );
  }
}

/// One option of a [FilterChips] row
class FilterOption<T> {
  final T value;
  final String label;
  final int? count;
  final IconData? icon;

  const FilterOption(this.value, this.label, {this.count, this.icon});
}

/// Horizontally scrolling single-choice chips
class FilterChips<T> extends StatelessWidget {
  final List<FilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final EdgeInsetsGeometry padding;

  const FilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (final o in options) ...[
            ChoiceChip(
              avatar: o.icon == null ? null : Icon(o.icon, size: 18),
              label: Text(o.count == null ? o.label : '${o.label} · ${o.count}'),
              selected: o.value == selected,
              showCheckmark: false,
              onSelected: (_) => onSelected(o.value),
            ),
            const Gap(Insets.sm),
          ],
        ],
      ),
    );
  }
}

// ==================== Settings tiles ====================

/// A titled group of settings
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final String? footer;

  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Insets.xs, Insets.lg, Insets.xs, Insets.sm),
          child: Text(
            title,
            style: context.tt.titleSmall?.copyWith(color: context.cs.primary),
          ),
        ),
        TileGroup(children: children),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(Insets.lg, Insets.sm, Insets.lg, 0),
            child: Text(
              footer!,
              style: context.tt.bodySmall?.copyWith(color: context.cs.onSurfaceVariant),
            ),
          ),
      ],
    );
  }
}

class SwitchSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Tone tone;

  const SwitchSettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.tone = Tone.primary,
  });

  @override
  Widget build(BuildContext context) {
    return ActionTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      tone: tone,
      onTap: onChanged == null ? null : () => onChanged!(!value),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}

/// Opens a list of choices and shows the current one
class ChoiceSettingTile<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final T value;
  final List<(T, String)> choices;
  final ValueChanged<T> onChanged;
  final Tone tone;

  const ChoiceSettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.choices,
    required this.onChanged,
    this.tone = Tone.primary,
  });

  String get _label {
    for (final c in choices) {
      if (c.$1 == value) return c.$2;
    }
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    return ActionTile(
      icon: icon,
      title: title,
      subtitle: subtitle ?? _label,
      tone: tone,
      trailing: subtitle != null
          ? Text(_label, style: context.tt.labelLarge?.copyWith(color: context.cs.primary))
          : null,
      onTap: () async {
        final picked = await showChoiceSheet<T>(
          context,
          title: title,
          value: value,
          choices: choices,
        );
        if (picked != null) onChanged(picked);
      },
    );
  }
}

/// A slider with its current value
class SliderSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double) format;
  final ValueChanged<double> onChanged;
  final Tone tone;

  const SliderSettingTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.format,
    required this.onChanged,
    this.tone = Tone.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.md, Insets.sm, Insets.md, 0),
      child: Column(
        children: [
          Row(
            children: [
              IconBadge(icon, tone: tone),
              const Gap(Insets.lg),
              Expanded(child: Text(title, style: context.tt.titleSmall)),
              Text(
                format(value),
                style: context.tt.labelLarge?.copyWith(
                  color: context.cs.primary,
                  fontFeatures: tabularFigures,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: format(value),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Search field plus optional filter chips, for [PageScaffold.bottom]
class SearchFilterBar<T> extends StatelessWidget implements PreferredSizeWidget {
  final String hint;
  final ValueChanged<String> onSearch;
  final List<FilterOption<T>> filters;
  final T? selected;
  final ValueChanged<T>? onFilter;

  /// Extra widget next to the search field, e.g. a sort button
  final Widget? trailing;

  const SearchFilterBar({
    super.key,
    required this.hint,
    required this.onSearch,
    this.filters = const [],
    this.selected,
    this.onFilter,
    this.trailing,
  });

  @override
  Size get preferredSize => Size.fromHeight(filters.isEmpty ? 64 : 112);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: Breakpoints.maxContent),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Insets.page, Insets.xs, Insets.page, Insets.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: SearchField(hint: hint, onChanged: onSearch)),
                  if (trailing != null) ...[const Gap(Insets.xs), trailing!],
                ],
              ),
              if (filters.isNotEmpty) ...[
                const Gap(Insets.sm),
                SizedBox(
                  height: 40,
                  child: FilterChips<T>(
                    options: filters,
                    selected: selected as T,
                    onSelected: (v) => onFilter?.call(v),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
