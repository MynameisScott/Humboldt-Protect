# Seguranca

## Segredos

Nunca publique:

- `/etc/humboldt-protect/borg.passphrase`
- `/etc/humboldt-protect/dash-notify.env`
- tokens de API
- chaves SSH
- dumps de configuracao contendo credenciais
- copias reais de `quarantine.json` quando elas revelarem usuarios/IPs internos

## Principio da contencao

A contencao possui duas camadas e e deliberadamente limitada:

- somente clientes IPv4 da rede configurada podem ser colocados no set;
- o IP do proprio servidor e recusado;
- o nftables bloqueia somente SMB (TCP 139/445);
- o usuario e bloqueado no Samba por meio do grupo local `humboldt_quarantine`;
- a conta do Active Directory nao e desabilitada pelo Humboldt Protect.

## Quarentena permanente

Nao existe timeout automatico. Isso evita que uma estacao ainda comprometida recupere acesso so porque um temporizador expirou.

A liberacao deve acontecer somente depois de analise da maquina/usuario afetado:

```bash
sudo humboldt-protect blocked
sudo humboldt-protect unblock Q-...
```

A manipulacao direta do grupo ou do set nftables deve ficar restrita a recuperacao/troubleshooting, pois pode deixar o estado persistente inconsistente.

## Persistencia

`quarantine.json` permite reaplicar os bloqueios apos restart ou reboot. Proteja `/var/lib/humboldt-protect` com acesso administrativo restrito.

## Falha do Dashboard

O watcher envia notificacoes em thread separada. Falha ou lentidao do Dash nao deve impedir a contencao local nem a execucao do detector.

No ambiente de origem, alertas vermelhos no Dash tambem geram e-mail. O e-mail e uma camada adicional de aviso e nao participa da decisao de bloquear/liberar.

## Backups

RAID nao substitui backup. Retencao Borg ajuda na recuperacao historica, mas ambientes criticos devem considerar copias offline/imutaveis e testes periodicos de restauracao.
