// Ecrã de Visualização do Histórico de Logs de Auditoria - Estilo Hyper POS (Codecanyon)

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/audit_log.dart';
import '../providers/app_state.dart';

enum DiffType { modified, added, removed, unchanged }

class FieldDiff {
  final String fieldName;
  final dynamic oldValue;
  final dynamic newValue;
  final DiffType status;

  FieldDiff({
    required this.fieldName,
    required this.oldValue,
    required this.newValue,
    required this.status,
  });
}

class StringDiffChunk {
  final String text;
  final String status; // 'added', 'removed', 'unchanged'
  StringDiffChunk(this.text, this.status);
}

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});

  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  final TextEditingController _filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppState>(context, listen: false).loadAuditLogs();
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  /// Calcula diferenças ao nível de palavras para destacar o conteúdo exato alterado
  List<StringDiffChunk> _diffStrings(String oldStr, String newStr) {
    if (oldStr == newStr) return [StringDiffChunk(oldStr, 'unchanged')];
    if (oldStr.isEmpty) return [StringDiffChunk(newStr, 'added')];
    if (newStr.isEmpty) return [StringDiffChunk(oldStr, 'removed')];

    final oldWords = oldStr.split(' ');
    final newWords = newStr.split(' ');

    final List<StringDiffChunk> chunks = [];
    int i = 0, j = 0;

    while (i < oldWords.length && j < newWords.length) {
      if (oldWords[i] == newWords[j]) {
        chunks.add(StringDiffChunk('${oldWords[i]} ', 'unchanged'));
        i++;
        j++;
      } else {
        int matchInNew = newWords.indexOf(oldWords[i], j);
        int matchInOld = oldWords.indexOf(newWords[j], i);

        if (matchInNew != -1 && (matchInOld == -1 || matchInNew - j <= matchInOld - i)) {
          while (j < matchInNew) {
            chunks.add(StringDiffChunk('${newWords[j]} ', 'added'));
            j++;
          }
        } else if (matchInOld != -1) {
          while (i < matchInOld) {
            chunks.add(StringDiffChunk('${oldWords[i]} ', 'removed'));
            i++;
          }
        } else {
          chunks.add(StringDiffChunk('${oldWords[i]} ', 'removed'));
          chunks.add(StringDiffChunk('${newWords[j]} ', 'added'));
          i++;
          j++;
        }
      }
    }

    while (i < oldWords.length) {
      chunks.add(StringDiffChunk('${oldWords[i]} ', 'removed'));
      i++;
    }
    while (j < newWords.length) {
      chunks.add(StringDiffChunk('${newWords[j]} ', 'added'));
      j++;
    }

    return chunks;
  }

  List<FieldDiff> _calculateDiffs(String? jsonAnt, String? jsonNov) {
    Map<String, dynamic> oldMap = {};
    Map<String, dynamic> newMap = {};

    String sanitizeJson(String str) {
      return str.replaceAll('\r', '').replaceAll('\n', r'\n').trim();
    }

    if (jsonAnt != null && jsonAnt.isNotEmpty) {
      try {
        final sanitized = sanitizeJson(jsonAnt);
        oldMap = Map<String, dynamic>.from(jsonDecode(sanitized));
      } catch (_) {}
    }

    if (jsonNov != null && jsonNov.isNotEmpty) {
      try {
        final sanitized = sanitizeJson(jsonNov);
        newMap = Map<String, dynamic>.from(jsonDecode(sanitized));
      } catch (_) {}
    }

    final allKeys = {...oldMap.keys, ...newMap.keys}.toList();
    final List<FieldDiff> diffs = [];

    for (final key in allKeys) {
      final hasOld = oldMap.containsKey(key);
      final hasNew = newMap.containsKey(key);

      final oldVal = oldMap[key];
      final newVal = newMap[key];

      final strOld = oldVal?.toString().trim() ?? '';
      final strNew = newVal?.toString().trim() ?? '';

      final isBothEmpty = (oldVal == null || strOld == '' || strOld == 'null') &&
                          (newVal == null || strNew == '' || strNew == 'null');

      if (hasOld && !hasNew) {
        if (isBothEmpty) {
          diffs.add(FieldDiff(fieldName: key, oldValue: oldVal, newValue: newVal, status: DiffType.unchanged));
        } else {
          diffs.add(FieldDiff(fieldName: key, oldValue: oldVal, newValue: null, status: DiffType.removed));
        }
      } else if (!hasOld && hasNew) {
        if (isBothEmpty) {
          diffs.add(FieldDiff(fieldName: key, oldValue: oldVal, newValue: newVal, status: DiffType.unchanged));
        } else {
          diffs.add(FieldDiff(fieldName: key, oldValue: null, newValue: newVal, status: DiffType.added));
        }
      } else {
        if (isBothEmpty || strOld == strNew) {
          diffs.add(FieldDiff(fieldName: key, oldValue: oldVal, newValue: newVal, status: DiffType.unchanged));
        } else {
          diffs.add(FieldDiff(fieldName: key, oldValue: oldVal, newValue: newVal, status: DiffType.modified));
        }
      }
    }

    return diffs;
  }

  void _showLogDetailModal(BuildContext context, AuditLog log) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final diffs = _calculateDiffs(log.dadosAnteriores, log.dadosNovos);

    final modifiedCount = diffs.where((d) => d.status == DiffType.modified).length;
    final addedCount = diffs.where((d) => d.status == DiffType.added).length;
    final removedCount = diffs.where((d) => d.status == DiffType.removed).length;
    final changedDiffs = diffs.where((d) => d.status != DiffType.unchanged).toList();

    bool showOnlyChanges = true;
    const accentColor = Color(0xFFFF6B00);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activeDiffs = showOnlyChanges ? changedDiffs : diffs;

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF141519) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB)),
              ),
              child: Container(
                width: 820,
                constraints: const BoxConstraints(maxHeight: 720),
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cabeçalho da Modal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _getBadgeColor(log.acao).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getActionIcon(log.acao),
                                color: _getBadgeColor(log.acao),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Detalhes da Ação: ${log.acao}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  'BD: ${log.baseDadosAlvo} | Tabela: ${log.tabelaAlvo} | ID Registo: ${log.registoId}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Efetuado por: ${log.utilizadorSistema} às ${DateFormat('dd/MM/yyyy HH:mm:ss').format(log.criadoEm)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              'Mostrar apenas alterações',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563),
                              ),
                            ),
                            Switch(
                              value: showOnlyChanges,
                              activeThumbColor: accentColor,
                              onChanged: (val) {
                                setModalState(() {
                                  showOnlyChanges = val;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 20),

                    // Resumo Visual de Estatísticas de Alterações (Diff Badges)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF18191E) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDiffSummaryBadge(
                            label: 'ALTERADO',
                            count: modifiedCount,
                            color: const Color(0xFFFF6B00),
                            isDark: isDark,
                          ),
                          _buildDiffSummaryBadge(
                            label: 'ADICIONADO',
                            count: addedCount,
                            color: const Color(0xFF10B981),
                            isDark: isDark,
                          ),
                          _buildDiffSummaryBadge(
                            label: 'REMOVIDO',
                            count: removedCount,
                            color: const Color(0xFFEF4444),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lista Detalhada de Campos com Destaques Coloridos no Conteúdo
                    Expanded(
                      child: activeDiffs.isEmpty
                          ? Center(
                              child: Text(
                                'Nenhuma alteração de valores registada para esta ação.',
                                style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                              ),
                            )
                          : ListView.separated(
                              itemCount: activeDiffs.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final diff = activeDiffs[index];
                                return _buildDiffCard(diff, isDark);
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

  Widget _buildDiffSummaryBadge({
    required String label,
    required int count,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Text(
            '$label: $count',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDiffCard(FieldDiff diff, bool isDark) {
    Color cardBorderColor;
    Color badgeBgColor;
    Color badgeTextColor;
    String statusText;

    switch (diff.status) {
      case DiffType.modified:
        cardBorderColor = const Color(0xFFFF6B00);
        badgeBgColor = const Color(0xFFFF6B00).withValues(alpha: 0.15);
        badgeTextColor = const Color(0xFFFF6B00);
        statusText = 'ALTERADO';
        break;
      case DiffType.added:
        cardBorderColor = const Color(0xFF10B981);
        badgeBgColor = const Color(0xFF10B981).withValues(alpha: 0.15);
        badgeTextColor = const Color(0xFF10B981);
        statusText = 'ADICIONADO';
        break;
      case DiffType.removed:
        cardBorderColor = const Color(0xFFEF4444);
        badgeBgColor = const Color(0xFFEF4444).withValues(alpha: 0.15);
        badgeTextColor = const Color(0xFFEF4444);
        statusText = 'REMOVIDO';
        break;
      case DiffType.unchanged:
        cardBorderColor = isDark ? const Color(0xFF2A2C35) : const Color(0xFFE5E7EB);
        badgeBgColor = isDark ? const Color(0xFF18191E) : const Color(0xFFF3F4F6);
        badgeTextColor = isDark ? Colors.white54 : Colors.black54;
        statusText = 'SEM ALTERAÇÃO';
        break;
    }

    final oldStr = diff.oldValue?.toString() ?? '';
    final newStr = diff.newValue?.toString() ?? '';
    final contentChunks = _diffStrings(oldStr, newStr);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18191E) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardBorderColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nome do Campo & Badge de Estado
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                diff.fieldName,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeTextColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Destaque Inline de Alterações no Conteúdo
          if (diff.status == DiffType.modified) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141519) : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF6B00).withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Diferença no Conteúdo (Destaque Inline):',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF6B00),
                    ),
                  ),
                  const SizedBox(height: 6),
                  RichText(
                    text: TextSpan(
                      children: contentChunks.map((chunk) {
                        if (chunk.status == 'removed') {
                          return TextSpan(
                            text: chunk.text,
                            style: const TextStyle(
                              backgroundColor: Color(0x66EF4444),
                              color: Color(0xFFFCA5A5),
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          );
                        } else if (chunk.status == 'added') {
                          return TextSpan(
                            text: chunk.text,
                            style: const TextStyle(
                              backgroundColor: Color(0x6610B981),
                              color: Color(0xFF6EE7B7),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          );
                        } else {
                          return TextSpan(
                            text: chunk.text,
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF111827),
                              fontSize: 13,
                            ),
                          );
                        }
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Valor Anterior (Vermelho)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Antes (Anterior):',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFEF4444)),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          oldStr,
                          style: const TextStyle(
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.arrow_forward_rounded, color: Color(0xFFFF6B00), size: 20),
                ),
                // Valor Novo (Verde)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Depois (Novo):',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                        ),
                        const SizedBox(height: 4),
                        SelectableText(
                          newStr,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else if (diff.status == DiffType.added) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
              ),
              child: SelectableText(
                newStr,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
            ),
          ] else if (diff.status == DiffType.removed) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
              ),
              child: SelectableText(
                oldStr,
                style: const TextStyle(fontSize: 12, decoration: TextDecoration.lineThrough, color: Color(0xFFEF4444)),
              ),
            ),
          ] else ...[
            SelectableText(
              newStr,
              style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
            ),
          ],
        ],
      ),
    );
  }

  Color _getBadgeColor(String acao) {
    switch (acao.toUpperCase()) {
      case 'INSERIR':
        return const Color(0xFF10B981);
      case 'ATUALIZAR':
        return const Color(0xFFFF6B00);
      case 'ELIMINAR':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFFF6B00);
    }
  }

  IconData _getActionIcon(String acao) {
    switch (acao.toUpperCase()) {
      case 'INSERIR':
        return Icons.add_circle_outline_rounded;
      case 'ATUALIZAR':
        return Icons.edit_note_rounded;
      case 'ELIMINAR':
        return Icons.delete_outline_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isDark = appState.isDarkMode;
    final logs = appState.auditLogs;
    const accentColor = Color(0xFFFF6B00);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de Filtro de Logs
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _filterController,
                  style: TextStyle(color: isDark ? Colors.white : const Color(0xFF111827)),
                  decoration: InputDecoration(
                    hintText: 'Filtrar histórico por base de dados, tabela ou ação...',
                    hintStyle: TextStyle(color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF)),
                    prefixIcon: const Icon(Icons.filter_list_rounded, color: accentColor),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: accentColor),
                      onPressed: () {
                        appState.loadAuditLogs(filterText: _filterController.text);
                      },
                    ),
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
                    appState.loadAuditLogs(filterText: val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tabela/Lista de Logs de Auditoria
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF141519) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF22242B) : const Color(0xFFE5E7EB),
                ),
              ),
              child: logs.isEmpty
                  ? Center(
                      child: Text(
                        'Nenhum registo de histórico encontrado em suporte_db.historico_logs',
                        style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: logs.length,
                      separatorBuilder: (_, __) => const Divider(height: 12),
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final badgeColor = _getBadgeColor(log.acao);

                        return ListTile(
                          onTap: () => _showLogDetailModal(context, log),
                          leading: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: badgeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: badgeColor),
                            ),
                            child: Text(
                              log.acao,
                              style: TextStyle(
                                color: badgeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          title: Text(
                            'BD: ${log.baseDadosAlvo} | Tabela: ${log.tabelaAlvo} (ID Registo: ${log.registoId})',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Efetuado por: ${log.utilizadorSistema} em ${DateFormat('dd/MM/yyyy HH:mm:ss').format(log.criadoEm)}',
                            style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                          ),
                          trailing: const Icon(Icons.remove_red_eye_rounded, size: 20, color: accentColor),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
