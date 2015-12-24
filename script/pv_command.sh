#!/bin/sh
## PVコマンドで進捗を示す
# 参考：http://qiita.com/shouta-dev/items/af9bebecaeabff5fb62f

## リカバリの様子を見る
pv data.dump | mysql -u<username> -h<servername> <dbname>
# mysqldumpも可能。
mysqldump -u <username> -h<servername> | pv -s 9999M > data.dump
# gzipにもつかえる
pv your_data.dump | gzip > your_data.dump.gz
