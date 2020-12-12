module Watchmain
  class Mailgun
    MAILGUN_HOST = "api.mailgun.net"

    @message_url : String
    def initialize(@domain : String, @api_key : String)
      puts "Initializing Mailgun for #{@domain}:#{@api_key}"

      @client = HTTP::Client.new(MAILGUN_HOST, 443, true)
      @client.basic_auth(username: "api", password: @api_key)

      @message_url = "/v3/#{@domain}/messages"
    end # initialize


    def send(message)
      response = @client.post(@message_url, form: message)
      puts response
      puts response.body
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
