# Seguranca

## Segredos

Nunca publique:

- `/etc/humboldt-protect/borg.passphrase`
- `/etc/humboldt-protect/dash-notify.env`
- tokens de API
- chaves SSH
- dumps de configuracao contendo credenciais

## Principio da contencao

A contencao foi desenhada para ser limitada: somente clientes IPv4 da rede configurada podem ser adicionados ao set, o IP do servidor e recusado e somente SMB (139/445) e bloqueado.

## Falha do Dashboard

O watcher envia notificacoes em thread separada. Falha ou lentidao do Dash nao deve impedir a contencao local nem a execucao do detector.

## Backups

RAID nao substitui backup. Retencao Borg ajuda na recuperacao historica, mas ambientes criticos devem considerar copias offline/imutaveis e testes periodicos de restauracao.
