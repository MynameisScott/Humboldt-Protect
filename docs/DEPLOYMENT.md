# Implantacao

## 1. Dependencias

Instale e valide Python 3, BorgBackup, Samba, nftables e systemd. Em OMV, prefira pacotes e configuracoes suportados pela distribuicao.

## 2. Instalar arquivos

```bash
sudo ./scripts/install.sh
```

O script copia executaveis para `/usr/local/sbin`, cria `/etc/humboldt-protect` e registra a unidade systemd. Ele nao inicia o servico automaticamente.

## 3. Configurar

Edite `/etc/humboldt-protect/config.json` com paths reais das shares, repositorios Borg, rede de clientes e IP do servidor.

Crie `/etc/humboldt-protect/borg.passphrase` com permissao 600 e nunca versione esse arquivo.

Se houver integracao com Dashboard, configure `/etc/humboldt-protect/dash-notify.env` e restrinja a API por token e IP de origem.

## 4. Samba full_audit

Siga `SAMBA_AUDIT.md`. Valide o resultado efetivo com `testparm` e confirme que operacoes reais aparecem no journal antes de iniciar o detector.

## 5. Validar

```bash
sudo humboldt-protect check
sudo humboldt-protect backup-plan
sudo humboldt-protect server-backup-plan
sudo /usr/local/sbin/humboldt-protect-nft-init
sudo nft list table inet ransomware_guard
```

## 6. Ativar

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now humboldt-protect.service
sudo systemctl status humboldt-protect.service --no-pager -l
```

## 7. Testes

Use arquivos de teste e um cliente controlado. Nao simule ransomware em dados reais. Valide primeiro logs, depois classificacao de eventos e por ultimo a contencao em um IP de laboratorio.
