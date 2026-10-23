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

## Camada complementar: ClamAV e AppArmor no Valdecir

**Referencia da manutencao: 23/10/2026.** O ClamAV complementa a deteccao comportamental do Humboldt Protect, mas **nao a substitui**. A atualizacao do antivirus nao alterou as regras de quarentena por usuario/IP, o `full_audit` ou os backups Borg.

- ClamAV atualizado para `1.4.6+dfsg-0+deb12u1`; `clamav-daemon` e `clamav-freshclam` foram encontrados ativos ao final da manutencao.
- Na verificacao registrada, as bases `daily.cld`, `main.cvd` e `bytecode.cvd` estavam atualizadas.
- Os perfis AppArmor de `/usr/sbin/clamd` e `/usr/bin/freshclam` estavam carregados em modo `enforce`.
- O perfil local do `clamd` foi preservado. Foram adicionadas somente as regras de leitura abaixo, disponibilizadas na versao do pacote Debian:

```text
@{PROC}/[0-9]*/mountinfo r,
/sys/fs/cgroup/system.slice/cpu.max r,
```

- A inclusao personalizada `include <local/usr.sbin.clamd>` foi mantida. O perfil passou pela validacao sintatica e foi recarregado sem erros.
- O perfil anterior foi preservado **somente no servidor** em `/root/apparmor-backups/usr.sbin.clamd.bak-20261023`; nao versionar esse arquivo real no Git.
- Alguns perfis associados ao Samba permaneciam em modo `complain`. Nao foram alterados nesta manutencao; revisar impactos antes de qualquer migracao para `enforce`.

**Limite das evidencias:** servicos ativos e assinaturas atualizadas **nao comprovam**, por si so, varredura automatica, cobertura de todas as shares, quarentena de arquivos infectados ou capacidade de resposta em tempo real. Esses itens ainda exigem auditoria especifica. Nenhum teste EICAR nem verificacao de cobertura foi registrado nesta manutencao.

Nunca coloque `clamd`, `freshclam` ou perfis Samba em modo permissivo para contornar erros sem analise e aprovacao. Preserve a configuracao local em atualizacoes e compare-a com os arquivos `.dpkg-dist` quando disponiveis.
