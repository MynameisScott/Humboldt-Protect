# Quarentena persistente

## Objetivo

Quando o detector identifica um padrao compativel com ransomware, a resposta deve impedir tanto a continuidade da maquina de origem quanto o reaproveitamento da mesma credencial em outro equipamento.

Por isso a contencao possui duas camadas:

```text
IP suspeito      -> nftables -> TCP 139/445 bloqueado
usuario suspeito -> Samba    -> invalid users = @humboldt_quarantine
```

## Estado persistente

Os incidentes ativos ficam em:

```text
/var/lib/humboldt-protect/quarantine.json
```

O arquivo e gravado com permissao restrita e contem IDs `Q-...`, usuario, IP e horario da criacao.

## Bloqueio do usuario

O helper normaliza nomes como `DOMINIO\\usuario` para `usuario` e usa o grupo local:

```text
humboldt_quarantine
```

As shares protegidas precisam conter:

```text
invalid users = @humboldt_quarantine
```

A conta no Active Directory continua habilitada. O bloqueio e especifico ao acesso Samba neste servidor.

## Bloqueio do IP

O set:

```text
inet ransomware_guard / blocked_ipv4
```

nao possui timeout. O IP permanece no conjunto ate liberacao administrativa. A regra gerenciada bloqueia somente TCP 139 e 445.

## Encerramento de sessoes

Ao aplicar uma quarentena, o helper:

1. bloqueia o usuario;
2. bloqueia o IP;
3. consulta sessoes SMB do mesmo usuario;
4. executa `smbcontrol smbd kill-client-ip` nos IPs encontrados e no IP de origem.

## Persistencia apos restart/reboot

`humboldt-protect-nft-init` e executado em `ExecStartPre`. Depois de garantir a estrutura nftables, ele chama:

```bash
/usr/local/sbin/humboldt-protect-quarantine restore
```

O restore reaplica usuarios e IPs gravados no JSON.

## Operacao

```bash
sudo humboldt-protect blocked
sudo humboldt-protect unblock Q-...
sudo humboldt-protect unblock-user usuario
sudo humboldt-protect unblock-ip 192.168.150.X
```

A liberacao por ID e a opcao preferencial.

## Teste validado no ambiente de origem

O fluxo controlado criou/escreveu oito arquivos, realizou renames/deletes e atingiu os limiares do detector. O resultado observado foi:

- 8 arquivos distintos;
- 16 writes;
- 3 rename/delete no instante do disparo;
- 20 eventos totais;
- IP bloqueado no nftables;
- usuario inserido no grupo de quarentena;
- porta TCP 445 inacessivel a partir do cliente;
- bloqueio persistiu apos restart do servico;
- `unblock Q-...` removeu usuario e IP e restaurou o acesso.
