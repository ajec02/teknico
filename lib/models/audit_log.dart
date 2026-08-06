// Modelo de Registo do Histórico de Auditoria (Logs)

class AuditLog {
  final int? id;
  final String baseDadosAlvo;
  final String tabelaAlvo;
  final String registoId;
  final String acao; // 'INSERIR', 'ATUALIZAR', 'ELIMINAR'
  final String? dadosAnteriores;
  final String? dadosNovos;
  final String utilizadorSistema;
  final DateTime criadoEm;

  AuditLog({
    this.id,
    required this.baseDadosAlvo,
    required this.tabelaAlvo,
    required this.registoId,
    required this.acao,
    this.dadosAnteriores,
    this.dadosNovos,
    required this.utilizadorSistema,
    required this.criadoEm,
  });

  factory AuditLog.fromMap(Map<String, dynamic> map) {
    return AuditLog(
      id: map['id'] is int ? map['id'] : int.tryParse(map['id']?.toString() ?? ''),
      baseDadosAlvo: map['base_dados_alvo']?.toString() ?? '',
      tabelaAlvo: map['tabela_alvo']?.toString() ?? '',
      registoId: map['registo_id']?.toString() ?? '',
      acao: map['acao']?.toString() ?? '',
      dadosAnteriores: map['dados_anteriores']?.toString(),
      dadosNovos: map['dados_novos']?.toString(),
      utilizadorSistema: map['utilizador_sistema']?.toString() ?? 'Sistema',
      criadoEm: map['criado_em'] != null
          ? (map['criado_em'] is DateTime
              ? map['criado_em']
              : DateTime.tryParse(map['criado_em'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }
}
