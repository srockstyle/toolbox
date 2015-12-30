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

## ネットワーク

IPアドレスを確認する

```sh
ip a
```

## 注意点

注意点がいくつかあるから気をつけること。[参考](http://qiita.com/suemoc/items/e29285e8e67263298f35)。

### /tmpが消える

tmpwatchが入ってないので、いつの間にか消去されていく。

消されたくないのは置かないこと。

### アクセス出来ない/tmp

sessionファイルをそこに吐き出さないこと

```引用
SystemdのServiceにはPrivateTmpというオプションがあります。
そのService専用の/tmpと/var/tmpの領域を用意する機能です。
デフォルトで有効になっています。
/tmp/hoge_app/sessionディレクトリはService専用の/tmpには存在しません。
```

なんだってーーーー！

php-fpmの起動ファイルを書き換える。

```ini
# PrivateTmp=true
PrivateTmp=false
```

### /var/runが消える

pidとか置かない。

/etc/tmpfiles.d/tmpfile.dに設定ファイルを作って起動時二作りたいフォルダを指定しておく。

### システムログが消える設定になっている

journaldで管理されているが、置き場所が/var/runのため、再起動で消える。

設定で/var/log/journalに変更しておくこと。

```/etc/systemd/journald.conf
[Journal]
# Storage=auto
Storage=persistent
```

### CentOS7つらい
