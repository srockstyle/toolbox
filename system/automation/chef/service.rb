service "nginx" do
  if node['deploy']['env'] == "production"
    action [:enable, :stop]
  else
    action [:enable, :start]
  end
end
