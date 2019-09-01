resource_name :certbot

property :email, String, required: true
property :domains, Array, required: true
property :expand, kind_of: [TrueClass, FalseClass], default: false
property :agree_tos, kind_of: [TrueClass, FalseClass]
property :standalone, kind_of: [TrueClass, FalseClass]
property :webroot, kind_of: [TrueClass, FalseClass]
property :webroot_path, String
property :deploy_hook, String

# Lifted from https://github.com/inviqa/chef-certbot/blob/master/providers/certonly_webroot.rb
action :create do
  options = {
    'config-dir' => node['certbot']['config_dir'],
    'work-dir' => node['certbot']['work_dir'],
    'logs-dir' => node['certbot']['logs_dir'],
    'server' => node['certbot']['server'],
    'webroot' => new_resource.webroot,
    'webroot-path' => new_resource.webroot_path,
    'email' => new_resource.email,
    'domains' =>  new_resource.domains.join(','),
    'expand' => new_resource.expand,
    'standalone' => new_resource.standalone,
    'deploy-hook' => new_resource.deploy_hook,
    'agree-tos' => new_resource.agree_tos,
    'non-interactive' => true
  }

  unless options['agree-tos']
    raise 'You need to agree to the Terms of Service by setting agree_tos true'
  end

  options_array = options.map do |key, value|
    case value
    when true
      ["--#{key}"]
    when false, nil
      []
    else
      ["--#{key}", "'#{value}'"]
    end
  end

  execute "#{node['certbot']['bin']} certonly #{options_array.flatten.join(' ')}"
end

action :install do
  package %w[certbot] do
    action :upgrade
    retries 5
    retry_delay 10
  end
end
