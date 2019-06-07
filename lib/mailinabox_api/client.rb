require 'http'
require 'mailinabox_api/resources/users'
require 'mailinabox_api/resources/aliases'

module MailinaboxApi
  class Client
    def initialize(email:, password:, domain:, insecure: false)
      @email = email
      @password = password
      @domain = domain
      @insecure = insecure
    end

    include MailinaboxApi::Users
    include MailinaboxApi::Aliases

    protected

    def get(url)
      request do |request|
        request.
          accept(:json).
          get(url)
      end
    end

    def request(options = {}, &block)
      HTTP.persistent("https://#{@domain}") do |http|
        if @insecure
          ctx = OpenSSL::SSL::SSLContext.new
          ctx.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.default_options = http.default_options.with_ssl_context(ctx)
        end
        @request = http
          .basic_auth(user: @email, pass: @password)
          .timeout(connect: 15, read: 30)
        @response = yield(@request)
      end
      unless @response.status.success?
        Kernel.warn @response.body.to_s

        raise MailinaboxApi::Error.new("#{@response.status} Request failed", response: @response)
      end
      if @response.headers['Content-Type'] == 'application/json'
        JSON.parse(@response.body.to_s)
      else
        @response.body.to_s
      end
    end
  end
end
