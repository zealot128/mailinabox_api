module MailinaboxApi
  module Aliases
    def aliases
      get '/admin/mail/aliases?format=json'
    end

    # Creates new alias
    # from: E-Mail
    # to: List of
    # POST /mail/aliases/add
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

    # adds one email to an (maybe) existing alias
    # POST /mail/aliases/add
    def add_to_alias(email, alias_list)
      domain = alias_list.split('@').last
      al = aliases.find { |i| i['domain'] == domain }['aliases'].find { |i| i['address'] == alias_list } || []
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
    
    # remove specific mail from an alias
    # STRING email: E-mail to remove from,
    # STRING mail_alias: mail alias email
    def remove_from_alias(email, mail_alias:, aliases: self.aliases)
      domain = mail_alias.split('@').last
      al = aliases.find { |i| i['domain'] == domain }['aliases'].find { |i| i['address'] == mail_alias }
      return false unless al['forwards_to'].include?(email)

      request do |http|
        http.
          headers('Content-Type' => 'application/x-www-form-urlencoded; charset=UTF-8').
          post('/admin/mail/aliases/add', form: {
            address: verteiler,
            forwards_to: (al['forwards_to'] - [email]).join("\n"),
            permitted_senders: '',
            update_if_exists: '1'
          })
      end
    end
    # POST /mail/aliases/remove
    def remove_alias
      raise NotImplementedError
    end
  end
end
