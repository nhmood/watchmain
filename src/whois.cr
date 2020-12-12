module Watchmain
  class Whois
    WHOIS_HOST = "whoisxmlapi.com"
    DOMAIN_URL = "/whoisserver/WhoisService?"

    @base_url : String
    def initialize(@api_key : String)
      puts "Initializing WhoisXMLAPI for #{@api_key}"

      @client = HTTP::Client.new(WHOIS_HOST, 443, true)
      @base_url = DOMAIN_URL + "outputFormat=JSON&apiKey=#{@api_key}"
    end # initialize


    def lookup(domain : String)
      puts "Performing Whois lookup for #{domain}"
      path = @base_url + "&domainName=#{domain}"

      response = @client.get(path)
      puts response
      puts response.body

      hash = Digest::MD5.base64digest(response.body)
      return hash
    end # lookup
  end # Whois
end # Watchmain
