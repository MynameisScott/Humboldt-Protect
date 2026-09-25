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
