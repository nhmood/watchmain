require "yaml"
require "base64"
require "digest/md5"
require "http/client"
require "logger"

require "./mailgun"
require "./whois"

module Watchmain
  VERSION = "0.1.0"

  puts "Watchmain v0.0.1 - #{Time.utc}"
  if ARGV.size != 2
    puts "watchmain [CONFIG_PATH] [DOMAIN]"
    exit
  end

  config_path = ARGV[0]
  domain      = ARGV[1]

  puts "Running using #{config_path} for #{domain}"

  config = File.open(config_path) do |file|
    YAML.parse(file)
  end
  puts config

  mailgun = Mailgun.new(
    domain: config["mailgun"]["domain"].as_s,
    api_key: config["mailgun"]["api_key"].as_s
  )
  puts mailgun

  whois = Whois.new(api_key: config["whois"]["api_key"].as_s)
  puts whois

  domain_file = __DIR__ + "/../domains/#{domain}"
  if File.exists?(domain_file)
    puts "Domain file already exists for #{domain}, reading existing hash"
    domain_hash = File.read(domain_file)
    puts "Hash for #{domain} -> #{ domain_hash }"
  else
    puts "No domain file found for #{ domain }"
    domain_hash = ""
  end

  new_hash = whois.lookup(domain)
  puts "New Hash: #{new_hash}"
  puts "Old Hash: #{domain_hash}"

  if new_hash != domain_hash
    puts "Hashes don't match, update occurred for #{domain}, sending email"
    message = Mailgun::Message.new(
      from:     "domainwatcher@goosecode.com",
      to:       "nhmood@goosecode.com",
      subject:  "#{domain} was updated",
      text:     "https://instantdomainsearch.com/#search=#{domain}"
    )
    puts message

    mailgun.send(message.to_hash)
    puts "Updating domain hash on record for #{domain}"
    File.write(domain_file, new_hash)
  end
end
