describe 'certbot' do
  context 'with two certonly webroots' do
    cached(:chef_run) do
      ChefSpec::SoloRunner
        .new(step_into: ['certbot'])
        .converge('fake::certbot-webroot')
    end

    it "will create a single domain certificate" do
      expect(chef_run).to run_execute(
        "certbot certonly --config-dir '/etc/letsencrypt' " \
        "--work-dir '/var/lib/letsencrypt' --logs-dir '/var/log/letsencrypt' "\
        "--webroot --webroot-path '/var/www/certbot' --email 'root@localhost' "\
        "--domains 'mysite1.dev' --agree-tos --non-interactive"
      )
    end

    it "will create a multi domain certificate" do
      expect(chef_run).to run_execute(
        "certbot certonly --config-dir '/etc/letsencrypt' " \
        "--work-dir '/var/lib/letsencrypt' --logs-dir '/var/log/letsencrypt' "\
        "--webroot --webroot-path '/var/www/certbot' --email 'root@localhost' "\
        "--domains 'mysite2.dev,js.mysite2.dev,css.mysite2.dev' --expand "\
        "--agree-tos --non-interactive"
      )
    end
  end

  context 'with a certonly webroot that has not agreed TOS' do
    cached(:chef_run) do
      ChefSpec::SoloRunner
        .new(step_into: ['certbot'])
        .converge('fake::certbot-webroot-disagree')
    end

    it "will raise an error" do
      expect{ chef_run }.to raise_error(
        RuntimeError,
        'certbot[single-cert] (fake::certbot-webroot-disagree line 1) ' \
        'had an error: RuntimeError: ' \
        'You need to agree to the Terms of Service by setting agree_tos true'
      )
    end
  end

  context 'with a certonly standalone single domain configuration' do
    cached(:chef_run) do
      ChefSpec::SoloRunner
        .new(step_into: ['certbot'])
        .converge('fake::certbot-standalone')
    end

    it "will create a single domain certificate" do
      expect(chef_run).to run_execute(
        "certbot certonly --config-dir '/etc/letsencrypt' "\
        "--work-dir '/var/lib/letsencrypt' --logs-dir '/var/log/letsencrypt' "\
        "--email 'root@localhost' --domains 'mysite1.dev' --standalone "\
        "--deploy-hook 'systemctl restart acme-webserver' --agree-tos "\
        "--non-interactive"
      )
    end
  end
end
