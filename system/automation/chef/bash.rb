bash 'install fluentd' do
  cod <<--EOH
    curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh
  E0H
  user 'root'
  ## ファイルがあれば実行しない
	not_if {File,exists?("/etc/init.d/td-agent")}
end
