# Humboldt Protect

Projeto de referencia para protecao de compartilhamentos Samba contra comportamento compativel com ransomware, quarentena persistente por **IP + usuario**, backup Borg e notificacoes para um dashboard externo.

> **Importante:** este repositorio e uma base sanitizada para GitHub. Nao contem tokens, senhas, passphrases, UUIDs de discos nem caminhos reais de armazenamento. Revise `config/` antes de usar em producao.

## Componentes

- `humboldt-protect`: CLI de configuracao, verificacao, backup, listagem e liberacao de quarentenas.
- `humboldt-protect-watch`: detector que acompanha o journal do Samba `full_audit`, executa contencao e agenda backups.
- `humboldt-protect-contain`: wrapper chamado pelo detector para aplicar quarentena permanente.
- `humboldt-protect-quarantine`: gerencia o estado persistente de quarentena, bloqueio por usuario, bloqueio por IP e liberacao administrativa.
- `humboldt-protect-nft-init`: garante a tabela/set/chain nftables e reaplica IPs persistentes apos reinicio.
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
              v
      humboldt-protect-quarantine
              |
              +--> nftables: bloqueia TCP 139/445 do IP sem timeout
              +--> Samba: coloca usuario em humboldt_quarantine
              +--> smbcontrol: derruba sessoes do IP e do usuario
              +--> quarantine.json: persiste o incidente
              +--> notificacao critica ao Dash

Scheduler interno
      +--> backup de arquivos (Borg)
      +--> backup do servidor (Borg)
      +--> notificacao de sucesso/falha ao Dash
```

A quarentena **nao expira automaticamente**. Um administrador precisa analisar a origem do incidente e liberar o registro manualmente.

## Requisitos

Base testada/concebida para Debian 12 / OpenMediaVault 7 com:

- Python 3
- Samba (`smbd`, `smbcontrol`, `vfs_full_audit`)
- ambiente integrado ao AD/Winbind quando usuarios de dominio forem usados
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

Configure o Samba/OMV conforme `docs/SAMBA_AUDIT.md`. Alem do `full_audit`, cada share protegida deve negar o grupo local de quarentena:

```text
invalid users = @humboldt_quarantine
```

Em OpenMediaVault, grave essa diretiva pelas opcoes extras da share ou outro mecanismo suportado pelo OMV; nao edite `smb.conf` diretamente.

Depois:

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

sudo humboldt-protect blocked
sudo humboldt-protect unblock Q-AAAA...
sudo humboldt-protect unblock-user usuario
sudo humboldt-protect unblock-ip 192.168.150.X

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

Para operacao normal, prefira `unblock Q-...`: ele libera de forma consistente o usuario e o IP associados ao incidente, respeitando outros registros que ainda possam manter o mesmo usuario ou IP em quarentena.

`archive-delete` e deliberadamente manual: confirma a existencia do snapshot, exige que o operador digite exatamente o nome do archive, executa `borg delete` e depois `borg compact`.

## Quarentena permanente

O estado fica em:

```text
/var/lib/humboldt-protect/quarantine.json
```

O `ExecStartPre` chama `humboldt-protect-nft-init`, que recria a infraestrutura nftables quando necessario e executa `humboldt-protect-quarantine restore`. Assim, uma quarentena registrada continua aplicada apos restart do servico ou reboot do servidor.

O bloqueio do usuario e local ao Samba do servidor: a conta do Active Directory nao e desabilitada. O objetivo e impedir que a mesma credencial comprometida seja reutilizada em outro computador para acessar os compartilhamentos protegidos.

## Seguranca do backup

Excluir uma pasta do servidor **nao** apaga essa pasta de snapshots Borg antigos. Os backups novos passam a refletir o estado novo, enquanto os antigos preservam o historico ate que uma politica de retencao ou exclusao manual remova o snapshot.

Isso e importante contra exclusao acidental e ransomware: a exclusao no armazenamento primario nao e propagada como exclusao imediata de todo o historico.

## Notificacoes

O cliente `humboldt-dash-notify` usa:

```text
/etc/humboldt-protect/dash-notify.env
```

Nunca publique o token real. O envio feito pelo watcher ocorre em thread separada para que indisponibilidade do Dashboard nao interrompa a protecao SMB.

No ambiente de referencia, o Dash foi configurado para enviar e-mail **somente para alertas vermelhos**. Essa funcao pertence ao projeto do Dashboard e nao a este repositorio.

## O que este repositorio nao faz automaticamente

- Nao desabilita contas no Active Directory.
- Nao libera quarentenas por tempo; a liberacao e manual.
- Nao altera a configuracao do OpenMediaVault/Samba sem revisao administrativa.
- Nao publica credenciais ou passphrases.
- Nao faz backup de imagens de VMs por padrao.
- Nao remove snapshots historicos porque uma pasta foi apagada na origem.
- Nao substitui monitoramento, EDR/antivirus, segmentacao de rede ou estrategia de backup offline/imutavel.

## Documentacao

- `docs/ARCHITECTURE.md`
- `docs/DEPLOYMENT.md`
- `docs/OPERATIONS.md`
- `docs/QUARANTINE.md`
- `docs/SAMBA_AUDIT.md`
- `docs/SECURITY.md`
