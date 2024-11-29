puts 'dokku_mannager loaded'


def dokku_add_domain(domain_name)
  app_name = ENV.fetch("DOKKU_APPLICATOIN_NAME", nil)
  domains_filename = 'data/platform_domains.csv'

  domain_name = domain_name.strip.downcase
  
  domains = []
  domains = File.readlines(domains_filename).map(&:strip).map(&:downcase) if File.exist?(domains_filename)
  
  File.write(domains_filename, "#{domain_name}\n", mode: "a") unless domains.include?(domain_name) || domain_name.empty?

  `dokku domains:add #{app_name} #{domain_name}`

  nil
end

def dokku_remove_domain(domain_name)
  app_name = ENV.fetch("DOKKU_APPLICATOIN_NAME", nil)
  domains_filename = 'data/platform_domains.csv'

  domain_name = domain_name.strip.downcase

  return unless File.exist?(domains_filename)
  domains = File.readlines(domains_filename).map(&:strip).map(&:downcase)

  `rm #{domains_filename}`
  domains.each do |domain|
    add_dokku_domain(domain) unless domain.to_sym == domain_name.to_sym || domain.strip.empty?
  end

  `dokku domains:remove #{app_name} #{domain_name}`

  nil
end