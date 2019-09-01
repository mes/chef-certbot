certbot 'single-cert' do
  webroot true
  webroot_path '/var/www/certbot'
  email 'root@localhost'
  domains ['mysite1.dev']
  expand false
end
