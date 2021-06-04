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

      whois = JSON.parse(response.body)
      Log.debug { whois }
      data = whois["WhoisRecord"]["registryData"]
      # todo - should probably replace this with proper JSON mapping
      fields = {
        "createdDate":                  whois["WhoisRecord"]["createdDate"],
        "updatedDate":                  whois["WhoisRecord"]["updatedDate"],
        "expiresDate":                  whois["WhoisRecord"]["expiresDate"],
        "domainName":                   whois["WhoisRecord"]["domainName"],
        "nameServers":                  whois["WhoisRecord"]["nameServers"],
        "status":                       whois["WhoisRecord"]["status"],
        "parseCode":                    whois["WhoisRecord"]["parseCode"],
        "customField1Name":             whois["WhoisRecord"]["customField1Name"],
        "customField1Value":            whois["WhoisRecord"]["customField1Value"],
        "registrarName":                whois["WhoisRecord"]["registrarName"],
        "registrarIANAID":              whois["WhoisRecord"]["registrarIANAID"],
        "createdDateNormalized":        whois["WhoisRecord"]["createdDateNormalized"],
        "updatedDateNormalized":        whois["WhoisRecord"]["updatedDateNormalized"],
        "expiresDateNormalized":        whois["WhoisRecord"]["expiresDateNormalized"],
        "customField2Name":             whois["WhoisRecord"]["customField2Name"],
        "customField3Name":             whois["WhoisRecord"]["customField3Name"],
        "customField2Value":            whois["WhoisRecord"]["customField2Value"],
        "customField3Value":            whois["WhoisRecord"]["customField3Value"],
        "whoisServer":                  whois["WhoisRecord"]["whoisServer"]
      }

      record = fields.to_pretty_json

      # generate MD5 hash to compare against previous requests
      hash = Digest::MD5.base64digest(record)

      # return the body + hash
      return record, hash
    end # lookup
  end # Whois
end # Watchmain
