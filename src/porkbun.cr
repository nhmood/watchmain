require "http/client"
require "log"
require "json"
require "xml"


module Watchmain
  module Porkbun
    PORKBUN_HOST = "porkbun.com"
    PORKBUN_DOMAINS = "/products/domains"

    def self.to_cash(str)
      str.gsub(/\$|,/, "").to_f
    end # to_cash

    def self.get_html(url)
      client = HTTP::Client.new(PORKBUN_HOST, 443, true)
      response = client.get(PORKBUN_DOMAINS)

      return response.body
    end # get_html

    def self.get_domains(body)
      porkbun = XML.parse_html(body)
      entries = porkbun.xpath_nodes("//*[@class=\"domainsPricingAllExtensionsItem\"]")

      domains = {} of String => Hash(Symbol, String|Hash(Symbol, String|Float64|Nil))
      entries.map do |entry|
        nodes = entry.children.reject {|n| !n.type.element_node? }
        nodes = nodes.first.children.reject {|n| !n.type.element_node? }

        domain    = nodes[0].text.strip
        price     = nodes[1].text.strip
        renewal   = nodes[2].text.strip
        transfer  = nodes[3].text.strip

        price     = get_cost(price)
        renewal   = get_cost(renewal)
        transfer  = get_cost(transfer)

        domains[domain] = {
          #:raw      => nodes.to_s,
          :domain   => domain,
          :price    => price,
          :renewal  => renewal,
          :transfer => transfer
        }
      end

      return domains
    end # get_domains

    def self.get_cost(entry)
      parts = entry.split(" ")
      cost = parts.shift
      sale = parts.pop { nil }
      type = sale ? parts.join(" ") : nil

      cost = Porkbun.to_cash(cost)
      sale = sale ? Porkbun.to_cash(sale) : nil

      {
        #:raw  => entry,
        :cost => cost,
        :sale => sale,
        :type => type
      }
    end # get_cost

    body = Porkbun.get_html(PORKBUN_DOMAINS)
    domains = get_domains(body)
    json = domains.to_json

    filename = "domains.json"
    if ARGV.size == 1
      filename = ARGV[0]
    end

    File.write(filename, json)
  end # Porkbun
end # Watchmain
