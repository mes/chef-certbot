certbot 'single-cert' do
  standalone true
  email 'root@localhost'
  domains ['mysite1.dev']
  agree_tos true
  deploy_hook 'systemctl restart acme-webserver'
end
