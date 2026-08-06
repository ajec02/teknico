// Ecrã de CRUD Dinâmico de Tabelas - Estilo Hyper POS (Codecanyon)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/export_service.dart';
import '../widgets/custom_modal.dart';

class TableCrudScreen extends StatefulWidget {
  const TableCrudScreen({super.key});

  @override
  State<TableCrudScreen> createState() => _TableCrudScreenState();
}

class _TableCrudScreenState extends State<TableCrudScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showRecordFormDialog(BuildContext context, {Map<String, dynamic>? recordToEdit}) {
    final appState = Provider.of<AppState>(context, listen: false);
    final schema = appState.currentSchema;
    if (schema == null) return;

    final isEdit = recordToEdit != null;
    final Map<String, TextEditingController> controllers = {};
    const accentColor = Color(0xFFFF6B00);

    for (final col in schema.columns) {
      if (col.isAutoIncrement && !isEdit) continue;
      final val = recordToEdit != null ? recordToEdit[col.name]?.toString() ?? '' : (col.defaultValue ?? '');
      controllers[col.name] = TextEditingController(text: val);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: isDark ? const Color(0xFF141519) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB)),
          ),
          child: Container(
            width: 580,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isEdit ? Icons.edit_rounded : Icons.add_box_rounded,
                              color: accentColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            isEdit ? 'Editar Registo (${schema.tableName})' : 'Adicionar Registo (${schema.tableName})',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  ...schema.columns.where((c) => !c.isAutoIncrement || isEdit).map((col) {
                    final controller = controllers[col.name]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${col.name} (${col.type})',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                                ),
                              ),
                              if (col.isPrimaryKey) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Chave Primária',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: accentColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: controller,
                            enabled: !isEdit || !col.isPrimaryKey,
                            style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: isDark ? const Color(0xFF18191E) : const Color(0xFFF9FAFB),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: accentColor, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB)),
                        ),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          elevation: 4,
                          shadowColor: accentColor.withValues(alpha: 0.4),
                        ),
                        onPressed: () async {
                          final Map<String, dynamic> data = {};
                          for (final entry in controllers.entries) {
                            data[entry.key] = entry.value.text;
                          }

                          Navigator.of(ctx).pop();

                          if (isEdit) {
                            CustomModal.show(
                              context: context,
                              title: 'Confirmar Alterações',
                              message: 'Deseja realmente atualizar este registo no MySQL?',
                              type: ModalType.confirm,
                              onConfirm: () async {
                                final pkVal = recordToEdit[schema.primaryKey];
                                await appState.updateRecord(pkVal, data, recordToEdit);
                              },
                            );
                          } else {
                            await appState.insertRecord(data);
                          }
                        },
                        child: Text(
                          isEdit ? 'Guardar Alterações' : 'Inserir Registo',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final schema = appState.currentSchema;
    final records = appState.currentRecords;

    const accentColor = Color(0xFFFF6B00);

    if (appState.selectedTable == null || schema == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storage_rounded, size: 64, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(height: 16),
            Text(
              'Selecione uma tabela no menu lateral para visualizar e gerir os seus dados.',
              style: TextStyle(fontSize: 16, color: isDark ? Colors.white60 : Colors.black54),
            ),
          ],
        ),
      );
    }

    final columnNames = schema.columns.map((c) => c.name).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Painel de Estatísticas / Métricas de Tabela (Hyper POS Style)
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF141519) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF22242B) : const Color(0xFFE5E7EB),
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.05),
                  blurRadius: 15,
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.table_rows_rounded, color: accentColor, size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tabela: ${schema.tableName}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    Text(
                      'Base de dados: ${appState.selectedDatabase ?? "Online"} • Chave Primária: ${schema.primaryKey ?? "N/A"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Badge com Total de Registos
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF18191E) : const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.numbers_rounded, size: 16, color: accentColor),
                      const SizedBox(width: 8),
                      Text(
                        'Total Registos: ${records.length}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Barra de Ações (Pesquisa, Botão Novo Registo, Exportação Excel e PDF)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
                  decoration: InputDecoration(
                    hintText: 'Pesquisar registos na tabela...',
                    hintStyle: TextStyle(color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.search_rounded, color: accentColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              appState.loadRecordsForTable(appState.selectedTable!);
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? const Color(0xFF141519) : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: isDark ? const Color(0xFF22242B) : const Color(0xFFE5E7EB),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: accentColor, width: 1.5),
                    ),
                  ),
                  onSubmitted: (val) {
                    appState.loadRecordsForTable(appState.selectedTable!, searchFilter: val);
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: const Text('Novo Registo'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                  shadowColor: accentColor.withValues(alpha: 0.4),
                ),
                onPressed: () => _showRecordFormDialog(context),
              ),
              const SizedBox(width: 12),

              // Exportação Excel
              OutlinedButton.icon(
                icon: const Icon(Icons.table_view_rounded, color: Color(0xFF10B981)),
                label: const Text('Exportar Excel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : const Color(0xFF111827),
                  side: BorderSide(color: const Color(0xFF10B981).withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  final path = await ExportService.exportToExcel(
                    title: 'Relatório de ${schema.tableName}',
                    tableName: schema.tableName,
                    columns: columnNames,
                    records: records,
                  );
                  if (path != null && context.mounted) {
                    CustomModal.show(
                      context: context,
                      title: 'Ficheiro Guardado',
                      message: 'Excel exportado com sucesso para:\n$path',
                      type: ModalType.success,
                    );
                  }
                },
              ),
              const SizedBox(width: 12),

              // Exportação PDF (Relrel)
              OutlinedButton.icon(
                icon: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444)),
                label: const Text('Exportar PDF (Relrel)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : const Color(0xFF111827),
                  side: BorderSide(color: const Color(0xFFEF4444).withValues(alpha: 0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () async {
                  await ExportService.exportToPdf(
                    title: 'Relatório Completo de Dados',
                    databaseName: appState.selectedDatabase ?? 'suporte_db',
                    tableName: schema.tableName,
                    columns: columnNames,
                    records: records,
                    emittedBy: 'Utilizador ${appState.config.user} (Suporte)',
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tabela de Dados Responsiva (Ordenação Descendente: Últimos Registos Primeiro)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141519) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF22242B) : const Color(0xFFE5E7EB),
                ),
              ),
              child: records.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum registo encontrado na tabela ${schema.tableName}',
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 24,
                          headingRowHeight: 48,
                          dataRowMinHeight: 44,
                          dataRowMaxHeight: 56,
                          headingRowColor: WidgetStateProperty.all(
                            isDark ? const Color(0xFF18191E) : const Color(0xFFF3F4F6),
                          ),
                          columns: [
                            const DataColumn(
                              label: Text(
                                'Ações',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            ...schema.columns.map(
                              (col) => DataColumn(
                                label: Row(
                                  children: [
                                    Text(
                                      col.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: col.isPrimaryKey ? accentColor : null,
                                      ),
                                    ),
                                    if (col.isPrimaryKey)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 4),
                                        child: Icon(Icons.key_rounded, size: 14, color: accentColor),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          rows: records.map((record) {
                            return DataRow(
                              cells: [
                                // Célula de Ações (Editar / Eliminar com confirmação)
                                DataCell(
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_rounded, size: 18, color: accentColor),
                                        onPressed: () => _showRecordFormDialog(context, recordToEdit: record),
                                        tooltip: 'Editar Registo',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_forever_rounded, size: 18, color: Color(0xFFEF4444)),
                                        onPressed: () {
                                          if (schema.primaryKey == null) {
                                            CustomModal.show(
                                              context: context,
                                              title: 'Aviso de Eliminação',
                                              message: 'Esta tabela não tem uma Chave Primária definida para identificar o registo.',
                                              type: ModalType.warning,
                                            );
                                            return;
                                          }

                                          final pkVal = record[schema.primaryKey];

                                          CustomModal.show(
                                            context: context,
                                            title: 'Confirmar Eliminação',
                                            message: 'Deseja realmente eliminar o registo ID: $pkVal da tabela ${schema.tableName}?',
                                            type: ModalType.confirm,
                                            onConfirm: () async {
                                              await appState.deleteRecord(pkVal, record);
                                            },
                                          );
                                        },
                                        tooltip: 'Eliminar Registo',
                                      ),
                                    ],
                                  ),
                                ),

                                // Valores das Colunas
                                ...schema.columns.map((col) {
                                  final val = record[col.name]?.toString() ?? '';
                                  return DataCell(
                                    Text(
                                      val,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? const Color(0xFFE5E7EB) : const Color(0xFF374151),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
