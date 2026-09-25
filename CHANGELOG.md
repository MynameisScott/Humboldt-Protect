# Changelog

## 2026-09-25 - quarentena persistente por IP + usuario

- Contencao deixou de expirar automaticamente.
- Set nftables `blocked_ipv4` passou a operar sem timeout e continua restrito a TCP 139/445.
- Criado `humboldt-protect-quarantine` com estado persistente em `/var/lib/humboldt-protect/quarantine.json`.
- Usuario associado ao incidente passa a ser incluido no grupo local `humboldt_quarantine`.
- Shares Samba protegidas devem usar `invalid users = @humboldt_quarantine`.
- Sessoes SMB do IP de origem e sessoes encontradas para o mesmo usuario sao encerradas.
- Quarentenas sao reaplicadas apos restart/reboot pelo `humboldt-protect-nft-init`.
- CLI ganhou `blocked`, `unblock`, `unblock-user` e `unblock-ip`.
- Fluxo real validado com deteccao pelo `full_audit`, bloqueio permanente de IP/usuario e liberacao manual.
- Mensagens do watcher atualizadas de "quarentena temporaria" para "quarentena permanente".
- Documentacao e smoke tests atualizados.

## 2026-09-24 - validacao operacional e alertas

- Scheduler automatico validado em producao: `files` as 23:00 e `server` as 02:00, ambos com `rc=0`.
- Integracao Valdecir -> Dash confirmada pelo canal privado.
- Alertas vermelhos do Dash passaram a gerar e-mail no ambiente operacional; a implementacao de SMTP pertence ao repositorio do Dashboard.
- Horario dos e-mails do Dash ajustado para `America/Sao_Paulo`.

## 2026-09-23 - pacote de referencia

- Protecao Samba com detector por janela de eventos.
- Contencao SMB temporaria via nftables + smbcontrol na versao inicial.
- Backup Borg de arquivos e servidor.
- Scheduler integrado ao watcher.
- Listagem de archives e exclusao manual protegida.
- Integracao assincrona com API de notificacoes do Dash.
- Exemplos de configuracao sanitizados para publicacao em GitHub.
