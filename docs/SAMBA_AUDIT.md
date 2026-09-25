# Samba full_audit e quarentena de usuario

O detector depende de eventos de operacoes de arquivo gerados pelo modulo `vfs_full_audit`.

No ambiente que originou este projeto, as shares protegidas eram: Biblioteca, Ti, Fileserver, Imagens, Scanner e Studio. A lista efetiva de operacoes auditadas incluiu:

```text
mkdirat renameat unlinkat pwrite write pwrite_recv
offload_read_send offload_read_recv offload_write_send offload_write_recv
```

A instalacao concreta em OpenMediaVault deve usar o mecanismo suportado pelo OMV. Evite editar manualmente arquivos que o OMV regenera.

O exemplo `config/samba-full-audit.example.conf` serve apenas como referencia. O parser do watcher funciona melhor quando o prefixo do full_audit fornece usuario, IP e share no inicio do registro.

## Grupo de quarentena

Crie o grupo local:

```bash
sudo groupadd --system humboldt_quarantine
```

Nas shares protegidas, adicione pelo mecanismo gerenciado do OMV:

```text
invalid users = @humboldt_quarantine
```

Em um ambiente OMV, uma forma validada foi acrescentar essa diretiva em `extraoptions` de cada share e depois executar o deploy do Samba. O resultado efetivo deve ser conferido com `testparm`.

Validacao:

```bash
getent group humboldt_quarantine
sudo testparm -s 2>/dev/null | awk '/^\[/ { sec=$0 } /invalid users =/ { print sec " -> " $0 }'
```

## Teste de usuario

Antes de integrar ao detector, pode-se validar com uma conta controlada:

```bash
sudo gpasswd -a usuario.teste humboldt_quarantine
id usuario.teste
```

Uma nova conexao SMB desse usuario deve receber acesso negado. Remova o teste imediatamente ao terminar:

```bash
sudo gpasswd -d usuario.teste humboldt_quarantine
```

Depois da implantacao do Humboldt Protect, **nao use `gpasswd` para liberar incidentes reais**; use `sudo humboldt-protect unblock ...` para manter estado, grupo e nftables sincronizados.

## Auditoria

Valide sempre:

```bash
testparm -s
journalctl -f
```

Crie, renomeie, escreva e exclua arquivos de teste por SMB e confirme que os eventos esperados chegam ao journal.
