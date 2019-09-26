module MailinaboxApi
  module Users
    def users
      get '/admin/mail/users?format=json'
    end

    # POST /mail/users/password
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

    # POST /mail/users/remove
    # archive account
    def remove_user(email)
      request do |http|
        http.
          headers('Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8').
          post('/admin/mail/users/remove', form: { email: email })
      end
    end

    # GET /mail/users/privileges
    def user_privileges
      raise NotImplementedError
    end

    # POST /mail/users/privileges/add
    def add_user_privilege
      raise NotImplementedError
    end

    # POST /mail/users/privileges/add
    def remove_user_privilege
      raise NotImplementedError
    end

    def create_email(email, password, privileges: nil)
      request do |http|
        http.
          headers('Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8').
          post('/admin/mail/users/add', form: { email: email, password: password, privileges: privileges })
      end
    end

    def user_exists?(email)
      domain = email.split('@').last
      users.find { |i| i['domain'] == domain }['users'].find { |i| i['email'] == email } != nil
    end
  end
end
