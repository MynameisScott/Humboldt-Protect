# Implantacao

## 1. Dependencias

Instale e valide Python 3, BorgBackup, Samba, Winbind quando houver AD, nftables e systemd. Em OMV, prefira pacotes e configuracoes suportados pela distribuicao.

## 2. Instalar arquivos

```bash
sudo ./scripts/install.sh
```

O script copia os executaveis para `/usr/local/sbin`, cria `/etc/humboldt-protect`, garante o grupo local `humboldt_quarantine` e registra a unidade systemd. Ele nao inicia o servico automaticamente.

## 3. Configurar

Edite `/etc/humboldt-protect/config.json` com paths reais das shares, repositorios Borg, rede de clientes e IP do servidor.

Crie `/etc/humboldt-protect/borg.passphrase` com permissao 600 e nunca versione esse arquivo.

Se houver integracao com Dashboard, configure `/etc/humboldt-protect/dash-notify.env` e restrinja a API por token e IP de origem.

## 4. Samba full_audit e bloqueio de usuario

Siga `SAMBA_AUDIT.md`. Alem da auditoria, cada share protegida precisa negar o grupo local:

```text
invalid users = @humboldt_quarantine
```

Em OpenMediaVault, grave essa diretiva na configuracao gerenciada pelo OMV, por exemplo em `extraoptions`. Nao edite `smb.conf` diretamente.

Valide o resultado efetivo:

```bash
getent group humboldt_quarantine
sudo testparm -s 2>/dev/null | grep -n 'invalid users'
```

## 5. Validar

```bash
sudo humboldt-protect check
sudo humboldt-protect backup-plan
sudo humboldt-protect server-backup-plan
sudo /usr/local/sbin/humboldt-protect-nft-init
sudo nft list table inet ransomware_guard
sudo humboldt-protect blocked
```

O set `blocked_ipv4` nao deve mostrar `timeout` ou `flags timeout`.

## 6. Ativar

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now humboldt-protect.service
sudo systemctl status humboldt-protect.service --no-pager -l
```

## 7. Teste controlado

Use somente arquivos de teste e um cliente controlado. Nao simule ransomware em dados reais.

A validacao final deve confirmar:

1. eventos reais chegando pelo `full_audit`;
2. limiares de deteccao atingidos;
3. IP inserido no set sem timeout;
4. usuario inserido em `humboldt_quarantine`;
5. porta SMB do cliente bloqueada;
6. `sudo humboldt-protect blocked` mostrando o ID;
7. liberacao por `sudo humboldt-protect unblock Q-...`;
8. acesso SMB restaurado somente depois da liberacao manual.

## 8. Migracao de versao antiga com timeout

O `humboldt-protect-nft-init` detecta um set legado com `timeout`, remove a tabela gerenciada e recria a estrutura permanente. Antes de migrar um ambiente diferente, confirme que a tabela `ransomware_guard` e exclusiva do Humboldt Protect.
