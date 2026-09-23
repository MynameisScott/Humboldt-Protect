# Humboldt Protect

Projeto de referencia para protecao de compartilhamentos Samba contra comportamento compativel com ransomware, contencao temporaria por IP, backup Borg e notificacoes para um dashboard externo.

> **Importante:** este repositorio e uma base sanitizada para GitHub. Nao contem tokens, senhas, passphrases, UUIDs de discos nem caminhos reais de armazenamento. Revise `config/` antes de usar em producao.

## Componentes

- `humboldt-protect`: CLI de configuracao, verificacao e backup.
- `humboldt-protect-watch`: detector que acompanha o journal do Samba `full_audit`, executa contencao e agenda backups.
- `humboldt-protect-contain`: helper de contencao; valida IP, adiciona-o ao set nftables e encerra sessoes SMB existentes.
- `humboldt-protect-nft-init`: garante tabela/set/chain nftables usados na quarentena.
- `humboldt-dash-notify`: cliente HTTP para notificacoes no Dash.
- `humboldt-protect.service`: unidade systemd.

## Fluxo resumido

```text
Samba full_audit
      |
      v
humboldt-protect-watch
      |
      +--> janela curta de eventos por usuario/IP/share
      |
      +--> limiares atingidos
              |
              v
      humboldt-protect-contain
              |
              +--> nftables: bloqueia 139/445 temporariamente
              +--> smbcontrol: derruba sessoes do IP
              +--> notificacao critica ao Dash

Scheduler interno
      +--> backup de arquivos (Borg)
      +--> backup do servidor (Borg)
      +--> notificacao de sucesso/falha ao Dash
```

## Requisitos

Base testada/concebida para Debian 12 / OpenMediaVault 7 com:

- Python 3
- Samba (`smbd`, `smbcontrol`, `vfs_full_audit`)
- nftables
- BorgBackup 1.x
- systemd
- `journalctl`

## Instalacao-base

```bash
sudo ./scripts/install.sh
sudo nano /etc/humboldt-protect/config.json
sudo nano /etc/humboldt-protect/dash-notify.env
sudo install -o root -g root -m 600 /dev/null /etc/humboldt-protect/borg.passphrase
sudo nano /etc/humboldt-protect/borg.passphrase
```

Configure o Samba/OMV conforme `docs/SAMBA_AUDIT.md`. Depois:

```bash
sudo humboldt-protect check
sudo systemctl enable --now humboldt-protect.service
sudo systemctl status humboldt-protect.service
```

## Comandos principais

```bash
sudo humboldt-protect list
sudo humboldt-protect check
sudo humboldt-protect config
sudo humboldt-protect backup-plan
sudo humboldt-protect backup-now
sudo humboldt-protect server-backup-plan
sudo humboldt-protect server-backup-now
sudo humboldt-protect archives
sudo humboldt-protect archive-delete files NOME_DO_ARCHIVE
sudo humboldt-protect archive-delete server NOME_DO_ARCHIVE
sudo humboldt-protect protect NOME_DA_SHARE on|off
sudo humboldt-protect backup NOME_DA_SHARE on|off
sudo humboldt-protect server-backup on|off
```

`archive-delete` e deliberadamente manual: confirma a existencia do snapshot, exige que o operador digite exatamente o nome do archive, executa `borg delete` e depois `borg compact`.

## Seguranca do backup

Excluir uma pasta do servidor **nao** apaga essa pasta de snapshots Borg antigos. Os backups novos passam a refletir o estado novo, enquanto os antigos preservam o historico ate que uma politica de retencao ou exclusao manual remova o snapshot.

Isso e importante contra exclusao acidental e ransomware: a exclusao no armazenamento primario nao e propagada como exclusao imediata de todo o historico.

## Notificacoes

O cliente `humboldt-dash-notify` usa:

```text
/etc/humboldt-protect/dash-notify.env
```

Nunca publique o token real. O envio feito pelo watcher ocorre em thread separada para que indisponibilidade do Dashboard nao interrompa a protecao SMB.

## O que este repositorio nao faz automaticamente

- Nao altera a configuracao do OpenMediaVault/Samba sem revisao administrativa.
- Nao publica credenciais ou passphrases.
- Nao faz backup de imagens de VMs por padrao.
- Nao remove snapshots historicos porque uma pasta foi apagada na origem.
- Nao substitui monitoramento, EDR/antivirus, segmentacao de rede ou estrategia de backup offline/imutavel.

## Documentacao

- `docs/ARCHITECTURE.md`
- `docs/DEPLOYMENT.md`
- `docs/OPERATIONS.md`
- `docs/SAMBA_AUDIT.md`
- `docs/SECURITY.md`
