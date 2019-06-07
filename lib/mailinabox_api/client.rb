module MailinaboxApi
  class Client
    def initialize(email:, password:, domain:, insecure: false)
      @email = email
      @password = password
      @domain = domain
      @insecure = insecure
    end

    def users
      get '/admin/mail/users?format=json'
    end

    def user_exists?(email)
      domain = email.split('@').last
      users.find { |i| i['domain'] == domain }['users'].find { |i| i['email'] == email } != nil
    end

    def aliases
      get '/admin/mail/aliases?format=json'
    end

    def update_password(email, password)
      request do |http|
        http.
          headers('Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8').
          post('/admin/mail/users/password',
               form: {
                 email: email,
                 password: password
               })
      end
    end

    def add_to_alias(email, alias_list)
      domain = alias_list.split('@').last
      al = aliases.find { |i| i['domain'] == domain }['aliases'].find { |i| i['address'] == alias_list }
      return false if al['forwards_to'].include?(email)

      request do |http|
        http.
          headers('Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8').
          post('/admin/mail/aliases/add',
               form: {
                 address: alias_list,
                 forwards_to: (al['forwards_to'] + [email]).join("\n"),
                 permitted_senders: '',
                 update_if_exists: '1'
               })
      end
    end

    # Creates new alias
    # from: E-Mail
    # to: List of
    def create_alias(address, list_of_recipients, permitted_senders: '')
      domain = address.split('@').last
      al = aliases.find { |i| i['domain'] == domain }['aliases'].find { |i| i['address'] == address }
      return false if al

      request do |http|
        http.
          headers('Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8').
          post('/admin/mail/aliases/add',
               form: {
                 address: address,
                 forwards_to: list_of_recipients,
                 permitted_senders: permitted_senders,
               })
      end
    end

    def create_email(email, password, privileges: nil)
      request do |http|
        http.
          headers('Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8').
          post('/admin/mail/users/add', form: { email: email, password: password, privileges: privileges })
      end
    end

    private

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

        raise StandardError, "#{@response.status} Request failed to #{full_url}"
      end
      if @response.headers['Content-Type'] == 'application/json'
        JSON.parse(@response.body.to_s)
      else
        @response.body.to_s
      end
    end
  end
end
