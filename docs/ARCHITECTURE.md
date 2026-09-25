# Arquitetura

## Camadas

1. **Telemetria:** Samba `vfs_full_audit` envia eventos de operacoes de arquivo ao journal/syslog.
2. **Deteccao:** `humboldt-protect-watch` agrupa eventos por `(usuario, IP, share)` em uma janela curta.
3. **Contencao:** `humboldt-protect-contain` chama `humboldt-protect-quarantine`, que aplica bloqueio persistente de IP + usuario e encerra sessoes SMB.
4. **Persistencia:** `/var/lib/humboldt-protect/quarantine.json` guarda os incidentes ativos; `humboldt-protect-nft-init` reaplica a quarentena apos restart/reboot.
5. **Backup:** `humboldt-protect` cria snapshots Borg separados para `files-*` e `server-*`, aplica retencao configurada e compacta o repositorio.
6. **Agendamento:** scheduler interno do watcher dispara backups nos horarios configurados, com controle de estado e prevencao de sobreposicao.
7. **Notificacao:** eventos importantes sao enviados ao Dash de forma assincrona.

## Modelo de deteccao

O exemplo de configuracao usa janela de 5 segundos e limiares de 5 arquivos distintos, 3 escritas e 3 operacoes de rename/delete. Diretorios e temporarios `~$`/`*.tmp` sao ignorados. Ajuste os limiares ao perfil real do ambiente e valide antes de producao.

O `cooldown_seconds` evita executar a mesma acao repetidamente para o mesmo par usuario/IP em um intervalo curto. **Cooldown nao e tempo de desbloqueio.** A quarentena permanece ate liberacao administrativa.

## Quarentena

A tabela nftables e `inet ransomware_guard`, com set `blocked_ipv4`. O set nao possui timeout. A regra derruba somente trafego do IP bloqueado para TCP 139 e 445; outros protocolos do cliente nao sao bloqueados por esse mecanismo.

Em paralelo, o usuario normalizado e incluido no grupo local `humboldt_quarantine`. As shares protegidas usam:

```text
invalid users = @humboldt_quarantine
```

Isso impede que a mesma credencial acesse o Samba a partir de outro computador. A conta do AD nao e desabilitada.

O helper encerra a sessao do IP de origem e procura sessoes SMB existentes do mesmo usuario para derruba-las tambem.

## Persistencia

```text
/var/lib/humboldt-protect/quarantine.json
```

Cada registro possui ID `Q-...`, usuario, IP e horario. O `humboldt-protect-nft-init` executa `restore` antes do watcher, garantindo que o set nftables e o grupo de quarentena representem o estado salvo.

## Backup

- `files-*`: snapshots das shares marcadas com `backup: true`.
- `server-*`: paths de configuracao/servidor e metadados operacionais definidos no JSON.

Os dois repositorios sao independentes e podem ter retencao comum configurada no bloco `borg`.
