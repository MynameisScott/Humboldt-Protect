# Samba full_audit

O detector depende de eventos de operacoes de arquivo gerados pelo modulo `vfs_full_audit`.

No ambiente que originou este projeto, as shares protegidas eram: Biblioteca, Ti, Fileserver, Imagens, Scanner e Studio. A lista efetiva de operacoes auditadas incluiu:

```text
mkdirat renameat unlinkat pwrite write pwrite_recv
offload_read_send offload_read_recv offload_write_send offload_write_recv
```

A instalacao concreta em OpenMediaVault deve usar o mecanismo suportado pelo OMV. Evite editar manualmente arquivos que o OMV regenera.

O exemplo `config/samba-full-audit.example.conf` serve apenas como referencia. O parser do watcher funciona melhor quando o prefixo do full_audit fornece, nesta ordem, usuario, IP e share (`%u|%I|%S`).

Valide sempre:

```bash
testparm -s
journalctl -f
```

Crie, renomeie, escreva e exclua arquivos de teste por SMB e confirme que os eventos esperados chegam ao journal.
