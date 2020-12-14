require "yaml"
require "base64"
require "digest/md5"
require "http/client"
require "log"

require "./mailgun"
require "./whois"

module Watchmain
  VERSION = "0.1.0"
  Log.setup_from_env
  Log.info { "Watchmain v0.0.1 - #{Time.utc}" }


  process_path = Process.executable_path
  if process_path
    watchmain_path = File.dirname(process_path)
  else
    Dir.mkdir("/tmp/watchmain")
    Dir.mkdir("/tmp/watchmain/domains")
    watchmain_path = "/tmp/watchmain"
  end
  Log.debug { "Executable running path: #{watchmain_path}" }


  # if we don't have the right arguments (config + domain)
  # then show help and exit
  if ARGV.size != 2
    Log.info { "watchmain [CONFIG_PATH] [DOMAIN]" }
    exit
  end

  # todo - use optparser
  config_path = ARGV[0]
  domain      = ARGV[1]

  # read the config as yaml
  Log.info { "Watchmain running with config:#{config_path} / domain:#{domain}" }
  Log.debug { "Reading YAML config from #{config_path}" }
  config = File.open(config_path) do |file|
    YAML.parse(file)
  end
  Log.debug { config }

  # configure the mailgun sender
  Log.debug { "Configuring Mailgun with config.mailgun->#{config["mailgun"]}" }
  mailgun = Mailgun.new(
    domain: config["mailgun"]["domain"].as_s,
    api_key: config["mailgun"]["api_key"].as_s
  )
  Log.debug { mailgun }

  # configure the whois api handler
  Log.debug { "Configuring Whois with config.whois->#{config["whois"]}" }
  whois = Whois.new(api_key: config["whois"]["api_key"].as_s)
  Log.debug { whois }

  # attempt to lookup an existing entry for the domain
  domain_file = watchmain_path + "/domains/" + domain
  Log.debug { "Looking for domain entry in #{domain_file}" }
  if File.exists?(domain_file)
    Log.info { "#{domain} already tracked, reading existing whois hash" }
    domain_hash = File.read(domain_file)
    Log.debug { "#{domain} entry hash -> #{domain_hash}" }
  else
    Log.info { "New entry for #{domain}" }
    domain_hash = ""
  end

  # perform the whois lookup for the domain
  Log.debug { "Performing whois.lookup on #{domain}" }
  latest_hash = whois.lookup(domain)
  Log.debug { "Latest Domain Hash for #{domain}  : #{latest_hash}" }
  Log.debug { "Existing Domain Hash for #{domain}: #{domain_hash}" }

  # if the domain_hash is blank, this is the first attempt so send a
  # now watching email about the domain
  # if the latest whois hash is different from the one we have stored
  # then we should send out an email on the update
  if domain_hash.empty?
    Log.info { "Now watching #{domain}, sending intro email" }

    # cycle through all the "to" entries in the config and send an email to each
    from = config["mailgun"]["from"]
    config["mailgun"]["to"].as_a.each do |to|
      message = Mailgun::Message.new(
        from: from.as_s,
        to: to.as_s,
        subject: "Watchmain - 🔥 Now watching #{domain} 🔥",
        text: "Now watching #{domain}"
      )
      Log.debug { message }
      mailgun.send(message.to_hash)
    end

  elsif domain_hash != latest_hash
    Log.info { "Latest domain whois hash doesn't match on record, sending update email and updating local record" }
    # cycle through all the "to" entries in the config and send an email to each
    from = config["mailgun"]["from"]
    config["mailgun"]["to"].as_a.each do |to|
      message = Mailgun::Message.new(
        from: from.as_s,
        to: to.as_s,
        subject: "Watchmain - 🔥 #{domain} whois updated!",
        text: "#{domain} updated\n\nhttps://instantdomainsearch.com/#search=#{domain}"
      )
      Log.debug { message }
      mailgun.send(message.to_hash)
    end


  else
    Log.info { "No updates for #{domain}" }
  end

  # write the latest hash value for the domain to file
  Log.debug { "Writing hash update #{latest_hash} for #{domain} to #{domain_file}" }
  File.write(domain_file, latest_hash)
end
