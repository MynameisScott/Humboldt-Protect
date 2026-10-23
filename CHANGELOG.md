# Changelog

## 2026-10-23 - manutencao ClamAV e AppArmor (sem alteracao no Humboldt Protect)

- No servidor Valdecir (Debian 12 / OpenMediaVault), os pacotes `libclamav12`, `clamdscan`, `clamav-daemon`, `clamav-base` e `clamav-freshclam` foram atualizados da versao `1.4.3+dfsg-1~deb12u2` para `1.4.6+dfsg-0+deb12u1`.
- Foram preservados o `freshclam.conf`, as personalizacoes do perfil AppArmor do `clamd` e as configuracoes locais dos servicos systemd.
- Ao perfil `/etc/apparmor.d/usr.sbin.clamd` foram acrescentadas somente as permissoes de leitura `@{PROC}/[0-9]*/mountinfo r,` e `/sys/fs/cgroup/system.slice/cpu.max r,`.
- O perfil foi validado com `apparmor_parser -Q -T` e recarregado com `apparmor_parser -r -T`, ambos sem erros.
- Confirmados `clamav-daemon` e `clamav-freshclam` ativos, bases `daily.cld`, `main.cvd` e `bytecode.cvd` atualizadas, e perfis do ClamAV em modo `enforce`.
- A verificacao de 10 minutos dos logs do kernel nao encontrou novas negativas `apparmor="DENIED"` relativas a `clamd` ou `freshclam`.
- Backup do perfil anterior preservado em `/root/apparmor-backups/usr.sbin.clamd.bak-20261023`, sob diretorio com permissao `700`.
- Nao houve reboot nem alteracao no Samba, nas politicas do OMV, nos agendamentos de varredura ou no codigo/servicos do Humboldt Protect. Esta entrada documenta manutencao do ambiente, nao uma nova funcionalidade do projeto.
- Pendencias de acompanhamento: auditar rotinas e cobertura de varredura, exclusoes, resposta a deteccoes e perfis Samba ainda em `complain`. Nao foram executadas nesta manutencao.

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
