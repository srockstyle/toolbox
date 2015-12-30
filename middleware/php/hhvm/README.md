# HHVM

hhvmはFacebookが開発したPHPを高速で実行するミドルウェア。

 * [公式サイト](http://hhvm.com/)
 * [公式ドキュメント] (https://docs.hhvm.com/hhvm/)

## 対応PHP

[7も対応した](https://github.com/facebook/hhvm/wiki)みたいです。

 * PHP5.6〜PHP7


## インストール

### Centos7

yumで。

```sh
yum install -y epel-release
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh http://yum.gleez.com/6/x86_64/gleez-repo-6-0.el6.noarch.rpm
sed -i 's|baseurl=http://yum.gleez.com/6/$basearch/|baseurl=http://yum.gleez.com/7/$basearch/|g' /etc/yum.repos.d/gleez.repo
yum --nogpgcheck -y install hhvm
```

確認。

```sh
# hhvm --version
HipHop VM 3.9.1 (rel)
Compiler: tags/HHVM-3.9.1-0-g0f72cfc2f0a01fdfeb72fbcfeb247b72998a66db
Repo schema: 6416960c150a4a4726fda74b659105ded8819d9c)
```

### Centos6

こっちもyumで。

```sh
cd /etc/yum.repos.d
wget http://www.hop5.in/yum/el6/hop5.repo
yum clean all
yum install hhvm
```

確認方法は上とおなじ。
