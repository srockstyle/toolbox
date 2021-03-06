# MySQL Toolbox

MySQLのもろもろです。

## Version

5.6系。

## SQLワンライナー

### 現在のプロセスリストをみる

sleepなもの、時間がかかっているものがあれば注意。

```sql
show processlist
```

### DBに専用のユーザをつくる

すべてのDBにしないように注意

```sql
create database srockstyle_dev;

# 全てのホストから
grant all privileges on `srockstyle_dev`.* TO 'srockstyle_dev'@'%' IDENTIFIED BY '<password>';

# 一部のホストから
grant all privileges on `srockstyle_dev`.* TO 'srockstyle_dev'@'192.168.1.2' IDENTIFIED BY '<password>';

# 参照のみ
grant select on `srockstyle_dev`.* to `srockstyle_select_user`@"192.168.0.7" identified by '<パスワード>';
```

## Chefレシピ

Chefで使う場合

### MySQLの最新版をインストール

```chef
bash 'add_mysql_community' do
  user 'root'
  code <<-EOC
    rpm -ivh http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm
  EOC
  creates "/etc/yum.repos.d/mysql-community.repo"
end


%w{
	mysql-community-client
	mysql-community-devel
	mysql-community-server
}.each do |p|
  yum_package p do
    allow_downgrade node['mysql-libs']['downgrade']
    arch node['mysql-libs']['arch']
    provider node['mysql-libs']['provider']
    version node['mysql-libs']['version']
    action :install
  end
end

template '/etc/my.cnf' do
  source 'my.cnf.erb'
end
```


## チューニングについて

適切なパラメータを設定するには。

### なるべくアプリの状況に応じて数値は変更

左がデフォルトの値。

現状多すぎるので制限。
```my.cnf
max_connection ? -> アプリで使う使用量
```

自動コミットはしないほうがよい
```my.cnf
autocommit  TRUE -> FALSE
```

in系クエリを早くするのであれば増やす。
```my.cnf
eq_range_index_dive_limit   50
```

更新＆書き込みが多い場合は有効にする
```my.cnf
innodb_adaptive_flushing  0 -> 1
innodb_adaptive_flushing_lwm  0 -> 50
```

RDSのみ:キャッシュウォーミングを有効。再起動後の高速化できる
```my.cnf
innodb_buffer_pool_dump_at_shutdown 0 -> 1
innodb_buffer_pool_load_at_startup  0 -> 1
```

スレッドをロックを待つ秒数。デフォルト50秒だが多い。
```my.cnf
innodb_lock_wait_timeout  50 -> 2
```

書き込みが走る回数を減らす。95%たまった時点で書き込み。
```my.cnf
innodb_max_dirty_pages_pct  75 -> 95
```

インデックスを使わない検索のバッファ。きちんとインデックスされていればデフォルトでいい。
```my.cnf
read_buffer_size  26214 -> 26214
```

インデックスが貼ってあるサイズ。
```my.cnf
read_rnd_buffer_size  52428 -> インデックスの量にもよる。
```

起動の遅いスレッドをみる。
```my.cnf
slow_launch_time    2 -> 1
```

ソートするときのバッファサイズ
```my.cnf
sort_buffer_size  2097144 -> 2倍〜3倍
```

インデックスを用いないjoinさせるときのバッファサイズ
```my.cnf
join_buffer_size 1048572 -> インデックスを用いるなら少なくていい。
```

heapテーブル最大サイズ。メモリ量の割にすくない。二倍くらいにする。
```my.cnf
max_heap_table_size 16777216 -> 33554432
```

tmpテーブル最大サイズ。これがないとMyISMに切り替わり遅くなるから増やす。max_heep_table_sizeと同じくらいにする。
```my.cnf
tmp_table_size 16777216 -> 33554432
```

キャッシュするスレッド数。
```my.cnf
thread_cache_size 10 -> スレッド数と同じにする。
```

話し合って調節するか決めるやつ。
クエリキャッシュしないのであれば不要。

```my.cnf
query_cache_size 1048576 -> 0
query_cache_type OFF
```

### チューニング計算式

数値は状況に応じて変更。

```計算SQL
SELECT (
   /* グローバル */
  @@key_buffer_size
  + @@query_cache_size
  + @@innodb_buffer_pool_size
  + @@innodb_additional_mem_pool_size
  + @@innodb_log_buffer_size
  + @@max_heap_table_size

  /* スレッドごと */
  + @@max_connection * (
    @@read_buffer_size
    + @@read_rnd_buffer_size
    + @@sort_buffer_size
    + @@join_buffer_size
    + @@binlog_cache_size
    + @@thread_stack + @@tmp_table_size
    )
  ) / (1024 * 1024 * 1024) AS MAX_MEMORY_GB;
```

スレッドごとにmax_allows_packetも含めるべきだが、アップロード容量が多いアプリの場合はバカみたいなメモリ量になるので、場合によっては含めない。
これでだいたい200connectionほどで15〜20GBの間くらいになるはず。


