template '/root/.ssh/authorized_keys' do
  source 'root_authorized_keys.erb'
  owner 'root'
  group 'root'
  mode '0600'
end
