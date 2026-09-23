# Operacao diaria

## Estado geral

```bash
sudo systemctl is-active humboldt-protect.service
sudo humboldt-protect check
sudo humboldt-protect list
```

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
```

## Politica de operacao

- Nao remova historico Borg automaticamente apenas porque uma pasta foi apagada na origem.
- Antes de alterar limiares de ransomware, analise logs reais para evitar falso positivo.
- Antes de mudar regras nftables, confirme que a regra continua restrita ao SMB pretendido.
- Mantenha credenciais fora do Git.
