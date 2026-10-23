# Operacao diaria

## Estado geral

```bash
sudo systemctl is-active humboldt-protect.service
sudo humboldt-protect check
sudo humboldt-protect list
```

## Quarentenas

Listar todos os bloqueios ativos:

```bash
sudo humboldt-protect blocked
```

Saida esperada quando houver um incidente:

```text
ID                          USUARIO          IP               DESDE
Q-AAAAMMDD-HHMMSS-xxxxxx    usuario          192.168.150.X    ...
```

A liberacao recomendada e pelo ID:

```bash
sudo humboldt-protect unblock Q-AAAAMMDD-HHMMSS-xxxxxx
```

Tambem existem comandos administrativos por identidade:

```bash
sudo humboldt-protect unblock-user usuario
sudo humboldt-protect unblock-ip 192.168.150.X
```

Use `unblock-user` ou `unblock-ip` somente quando houver um motivo operacional claro. `unblock Q-...` preserva melhor a relacao entre usuario e IP registrada no incidente.

**Nunca libere um incidente apenas para restabelecer acesso rapidamente.** Primeiro identifique e isole a maquina, verifique a origem da atividade, faça a limpeza/analise necessaria e somente depois remova a quarentena.

## Backups

```bash
sudo humboldt-protect archives
sudo humboldt-protect backup-plan
sudo humboldt-protect server-backup-plan
```

Execucao manual:

```bash
sudo humboldt-protect backup-now
sudo humboldt-protect server-backup-now
```

## Exclusao manual de um snapshot

```bash
sudo humboldt-protect archive-delete files files-AAAA-MM-DD_HH-MM-SS
sudo humboldt-protect archive-delete server server-AAAA-MM-DD_HH-MM-SS
```

O comando exige confirmacao digitando o nome exato do archive. Excluir um snapshot nao invalida os demais.

## Logs

```bash
sudo journalctl -u humboldt-protect.service --since today --no-pager
sudo journalctl -t humboldt-protect --since today --no-pager
sudo nft list table inet ransomware_guard
getent group humboldt_quarantine
```

## Politica de operacao

- A quarentena nao expira automaticamente.
- Nao remova usuarios diretamente do grupo com `gpasswd -d` em operacao normal; use o CLI para manter o JSON e o nftables sincronizados.
- Nao remova IPs diretamente do set nftables em operacao normal; use o CLI.
- Nao remova historico Borg automaticamente apenas porque uma pasta foi apagada na origem.
- Antes de alterar limiares de ransomware, analise logs reais para evitar falso positivo.
- Antes de mudar regras nftables, confirme que a regra continua restrita ao SMB pretendido.
- Mantenha credenciais fora do Git.

## ClamAV e AppArmor - verificacao e manutencao

**Ultima manutencao documentada: 23/10/2026.** O ClamAV passou de `1.4.3+dfsg-1~deb12u2` para `1.4.6+dfsg-0+deb12u1`, com configuracoes locais preservadas. Nenhum reboot foi necessario. Estes comandos sao de **consulta**, nao instalam pacotes nem alteram a politica do sistema.

### Servicos, versoes e assinaturas

```bash
sudo systemctl is-active clamav-daemon clamav-freshclam
dpkg-query -W libclamav12 clamdscan clamav-daemon clamav-base clamav-freshclam
sudo journalctl -u clamav-freshclam -n 50 --no-pager
sudo ls -lh /var/lib/clamav/
```

Na validacao de 23/10/2026, ambos os servicos estavam ativos e as bases `daily.cld`, `main.cvd` e `bytecode.cvd` estavam atualizadas. O processo `clamd` utilizava aproximadamente 984 MB de RAM no momento observado, valor historico, nao limite ou consumo garantido.

### AppArmor e logs

```bash
sudo aa-status
sudo apparmor_parser -Q -T /etc/apparmor.d/usr.sbin.clamd
sudo journalctl -u clamav-daemon -u clamav-freshclam -p warning -n 50 --no-pager
sudo journalctl -k --since "10 minutes ago" --no-pager | grep -E 'apparmor="DENIED".*(clamd|freshclam)' || true
```

Na ultima verificacao, os perfis `/usr/sbin/clamd` e `/usr/bin/freshclam` estavam em `enforce`. Nao foram encontradas novas negativas de AppArmor relativas a eles na janela consultada. Haviam registros historicos de falha de inicializacao do ClamAV de 15/09/2026, nao investigados durante a manutencao.

### Arquivo de configuracao e recuperacao

```text
Perfil ativo:   /etc/apparmor.d/usr.sbin.clamd
Versao Debian:  /etc/apparmor.d/usr.sbin.clamd.dpkg-dist
Backup local:   /root/apparmor-backups/usr.sbin.clamd.bak-20261023
```

O backup local esta sob `/root/apparmor-backups`, diretorio com permissoes `700`. A ultima manutencao manteve `freshclam.conf`, os overrides systemd e a diretiva `include <local/usr.sbin.clamd>`; adicionou apenas `@{PROC}/[0-9]*/mountinfo r,` e `/sys/fs/cgroup/system.slice/cpu.max r,` ao perfil de `clamd`.

A validacao de sintaxe foi feita com `apparmor_parser -Q -T`; **apos a alteracao autorizada do perfil**, a aplicacao registrada foi `sudo apparmor_parser -r -T /etc/apparmor.d/usr.sbin.clamd`. Nao execute recarga por rotina se nao houver mudanca a aplicar.

### Pendencias de auditoria (nao realizadas em 23/10/2026)

- Confirmar se existem varreduras periodicas e se estao sendo executadas.
- Conferir abrangencia das pastas, exclusoes e eventuais areas sem varredura.
- Documentar o fluxo de tratamento de deteccoes e de arquivos suspeitos.
- Avaliar os perfis Samba que permanecem em `complain`, sem alteracoes preventivas de modo.
- Continuar verificando atualizacao de assinaturas e logs; considerar teste EICAR controlado em outra janela de manutencao.

**Atencao:** atualizar assinaturas nao significa que todas as pastas estejam sendo verificadas automaticamente. O Humboldt Protect segue independente da camada ClamAV/AppArmor.
