puts 'nginx_manager loaded'

def nginx_restart
  `systemctl restart nginx.service`
end

def nginx_update_config
  nginx_config_name = ENV.fetch('NGINX_APP_SUBDOMAINS_CONFIG_FILE', nil)&.strip
  file_start  = File.read("tempaltes/nginx-multi-part1.conf")
  file_middle = File.read("tempaltes/nginx-multi-part2.conf")
  file_end    = File.read("tempaltes/nginx-multi-part3.conf")

  domains = File.readlines("data/customer_domains.csv").map(&:strip)

  server_names = "\n\n\n\tserver_name #{domains.join(' ')};\n\n"
  proxy_path   = "\n\n\t\tproxy_pass #{ENV.fetch('PROXY_PATH', nil)};\n\n"

  output_file = File.open("tmp/#{nginx_config_name}", 'w') do |file|
    file.write file_start
    file.write server_names

    file.write file_middle
    file.write proxy_path
    file.write file_end
  end

  `cp tmp/#{nginx_config_name} /etc/nginx/site-available/`
  nginx_restart
end

# example: test.example.com
def nginx_add_subdomain(domain_name)
  domains_filename = 'data/customer_domains.csv'
  
  domains = []
  domains = File.readlines(domains_filename).map(&:strip).map(&:downcase) if File.exist?(domains_filename)
  
  File.write(domains_filename, "#{domain_name}\n", mode: "a") unless domains.include?(domain_name) || domain_name.empty?

  nginx_update_config
end

def nginx_remove_subdomain(domain_name)
  nginx_config_name = ENV.fetch('NGINX_APP_SUBDOMAINS_CONFIG_FILE', nil)&.strip
  domains_filename = 'data/customer_domains.csv'

  return unless File.exist?(domains_filename)
  domains = File.readlines(domains_filename).map(&:strip).map(&:downcase)
  
  `rm #{domains_filename}`
  domains.each do |domain|
    add_nginx_subdomain(domain) unless domain.to_sym == domain_name.strip.downcase.to_sym || domain.strip.empty?
  end

  # cloudflare

  nginx_update_config
  nil
end