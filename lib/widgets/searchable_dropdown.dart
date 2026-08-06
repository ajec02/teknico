// Dropdown Pesquisável Personalizada (Todas as Dropdowns do Sistema Devem Ser Pesquisáveis)

import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String hint;
  final bool isCompact;

  const SearchableDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint = 'Selecione ou pesquise...',
    this.isCompact = false,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  void _openSearchDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String searchText = '';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredItems = widget.items.where((item) {
              final text = item.child.toString().toLowerCase();
              final labelText = item.value?.toString().toLowerCase() ?? '';
              return text.contains(searchText.toLowerCase()) || labelText.contains(searchText.toLowerCase());
            }).toList();

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF141519) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 400,
                constraints: const BoxConstraints(maxHeight: 480),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      autofocus: true,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Pesquisar...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                        ),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF18191E) : const Color(0xFFF9FAFB),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFFF6B00), width: 1.5),
                        ),
                      ),
                      onChanged: (val) {
                        setDialogState(() {
                          searchText = val;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: filteredItems.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhum item encontrado',
                                style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filteredItems.length,
                              separatorBuilder: (_, index) => const SizedBox(height: 4),
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                final isSelected = item.value == widget.value;

                                return Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    dense: true,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    selected: isSelected,
                                    selectedTileColor: isDark ? const Color(0xFF22242B) : const Color(0xFFE5E7EB),
                                    title: item.child,
                                    onTap: () {
                                      widget.onChanged(item.value);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedItem = widget.items.firstWhere(
      (item) => item.value == widget.value,
      orElse: () => DropdownMenuItem<T>(value: null, child: Text(widget.hint)),
    );

    final vPadding = widget.isCompact ? 5.0 : 8.0;
    final hPadding = widget.isCompact ? 10.0 : 14.0;
    final labelFontSize = widget.isCompact ? 10.0 : 11.0;
    final spacing = widget.isCompact ? 2.0 : 4.0;
    final borderRadius = widget.isCompact ? 8.0 : 10.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: labelFontSize,
              letterSpacing: 0.5,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: spacing),
        ],
        InkWell(
          onTap: _openSearchDialog,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF18191E) : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: selectedItem.child,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.unfold_more_rounded,
                  size: widget.isCompact ? 16 : 18,
                  color: isDark ? const Color(0xFFFF6B00) : const Color(0xFFFF6B00),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
