## フォルダつくったりする
directory '/root/.ssh' do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end
