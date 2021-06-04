#!/usr/bin/env ruby

require 'net/https'
require 'oga'
require 'pry'
require 'json'
require 'awesome_print'

PORKBUN_DOMAINS = "https://porkbun.com/products/domains"



class String
  def to_cash
    self.gsub(/\$|,/, '').to_f
  end # to_cash
end

def get_html(url)
  uri = URI(url)
  body = Net::HTTP.get(uri)
  return body
end # get_html

def get_domains(body)
  porkbun = Oga.parse_html(body)
  entries = porkbun.xpath('//*[@class="domainsPricingAllExtensionsItem"]')

  domains = entries.map do |entry|
    nodes = entry.children.reject {|n| !n.is_a?(Oga::XML::Element) }
    nodes = nodes.first.children.reject {|n| !n.is_a?(Oga::XML::Element) }

    domain    = nodes[0].text.strip.force_encoding('UTF-8')
    price     = nodes[1].text.strip
    renewal   = nodes[2].text.strip
    transfer  = nodes[3].text.strip

    price     = get_cost(price)
    renewal   = get_cost(renewal)
    transfer  = get_cost(transfer)

    data = [
      domain,
      {
        #:raw      => nodes.to_s,
        :domain   => domain,
        :price    => price,
        :renewal  => renewal,
        :transfer => transfer
      }
    ]
  end

  return Hash[domains]
end # get_domains


def get_cost(entry)
  parts = entry.split(" ")
  cost = parts.shift
  sale = parts.pop
  type = sale ? parts.join(" ") : nil

  cost = cost.to_cash
  sale = sale ? sale.to_cash : nil

  {
    #:raw  => entry,
    :cost => cost,
    :sale => sale,
    :type => type
  }
end # get_cost

body = get_html(PORKBUN_DOMAINS)
domains = get_domains(body)
json = JSON.generate(domains)

File.open(ARGV[0] || 'domains.json', 'wb') do |f|
  f.write(json)
end
