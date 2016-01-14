# Chef Tookbox

Chef周りのツールボックス。

## よく困る書き方系

### not_if

"Falseである時アクションをする"

特定のファイルがないばあい実行する。

```rb
execute "aaa" do
  command "git clone https://github.com/aaa"
  not_if { File.exists?("/home/vagrant/aaa") }
end
```
