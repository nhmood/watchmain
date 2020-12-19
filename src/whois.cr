module Watchmain
  class Whois
    WHOIS_HOST = "whoisxmlapi.com"
    DOMAIN_URL = "/whoisserver/WhoisService?"

    @base_url : String
    def initialize(@api_key : String)
      Log.debug { "Initializing WhoisXMLAPI" }
      Log.debug { "Initializing WhoisXMLAPI for #{@api_key}" }

      @client = HTTP::Client.new(WHOIS_HOST, 443, true)
      @base_url = DOMAIN_URL + "outputFormat=JSON&apiKey=#{@api_key}"
    end # initialize


    def lookup(domain : String)
      Log.info { "Whois#lookup called for #{domain}" }
      path = @base_url + "&domainName=#{domain}"
      Log.debug { "WhoisXMLAPI query address: #{path}" }

      response = @client.get(path)
      Log.info { "WhoisXMLAPI request: #{response}" }
      Log.debug { response.body }

      # generate MD5 hash to compare against previous requests
      hash = Digest::MD5.base64digest(response.body)

      # return the body + hash
      return response.body, hash
    end # lookup
  end # Whois
end # Watchmain
