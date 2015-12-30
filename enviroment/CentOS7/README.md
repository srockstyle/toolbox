# CentOS7

CentOS7関連。

## 始めに

セキュリティの設定。

### SELnux

こいつは無効

```/etc/sysconfig/selinux
SELINUX=disabled
```

iptablesはfirewalldってのに変わってる
```sh
## 停止
systemctl stop firewalld
## 起動時に停止
systemctl disable firewalld
```

とりあえずVagrantとかはこれでいける。

## systemd

もろもろ

```sh
# 起動
systemctl start <daemon_name>

# 停止
systemctl stop <daemon_name>

#再起動
systemctl restart <daemon_name>

#システムブート時に起動する
systemctl enable <daemon_name>

#システムブート時に起動しない
systemctl disable <daemon_name>
```
