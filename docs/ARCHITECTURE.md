# Arquitetura

## Camadas

1. **Telemetria:** Samba `vfs_full_audit` envia eventos de operacoes de arquivo ao journal/syslog.
2. **Deteccao:** `humboldt-protect-watch` agrupa eventos por `(usuario, IP, share)` em uma janela curta.
3. **Contencao:** `humboldt-protect-contain` bloqueia somente SMB (TCP 139/445) para o IP suspeito por tempo limitado e encerra sessoes existentes.
4. **Backup:** `humboldt-protect` cria snapshots Borg separados para `files-*` e `server-*`, aplica retencao configurada e compacta o repositorio.
5. **Agendamento:** scheduler interno do watcher dispara backups nos horarios configurados, com controle de estado e prevencao de sobreposicao.
6. **Notificacao:** eventos importantes sao enviados ao Dash de forma assincrona.

## Modelo de deteccao

O exemplo de configuracao usa janela de 5 segundos e limiares de 5 arquivos distintos, 3 escritas e 3 operacoes de rename/delete. Diretorios e temporarios `~$`/`*.tmp` sao ignorados. Ajuste os limiares ao perfil real do ambiente e valide antes de producao.

## Contencao

A tabela nftables e `inet ransomware_guard`, com set `blocked_ipv4`. A regra gerenciada derruba trafego do set para TCP 139 e 445; outros protocolos do cliente nao sao bloqueados por esse mecanismo. O helper rejeita IP fora da rede de clientes e tambem rejeita o IP do proprio servidor.

## Backup

- `files-*`: snapshots das shares marcadas com `backup: true`.
- `server-*`: paths de configuracao/servidor e metadados operacionais definidos no JSON.

Os dois repositorios sao independentes e podem ter retencao comum configurada no bloco `borg`.
