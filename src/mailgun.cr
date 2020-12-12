module Watchmain
  class Mailgun
    MAILGUN_HOST = "api.mailgun.net"

    @message_url : String
    def initialize(@domain : String, @api_key : String)
      Log.info { "Initializing Mailgun for #{@domain}" }
      Log.debug { "Initializing Mailgun for #{@domain}:#{@api_key}" }

      # configure the HTTP client for the mailgun requests
      # mailgun uses basic auth with api as the user and the api key as the password
      @client = HTTP::Client.new(MAILGUN_HOST, 443, true)
      @client.basic_auth(username: "api", password: @api_key)

      # configure the email message path based on the domain
      @message_url = "/v3/#{@domain}/messages"
    end # initialize


    def send(message)
      Log.info { "Sending #{message} to #{@message_url}" }
      response = @client.post(@message_url, form: message)
      Log.info { "Mailgun request: #{response}" }
      Log.debug { response.body }

      return true
    end # send


    struct Message
      property from, to, subject, text
      def initialize(@from : String, @to : String, @subject : String, @text : String)
      end # initialize

      def to_hash
        hash = {
          "from"    => @from,
          "to"      => @to,
          "subject" => @subject,
          "text"    => @text
        }
        return hash
      end # to_hash
    end # Message
  end # Mailgun
end # Watchmain
