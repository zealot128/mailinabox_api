# MailinaboxApi


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mailinabox_api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mailinabox_api

## Usage

```ruby
api = MailinaboxApi::Client.new(
  email: Rails.application.secrets.mailinabox_admin_username,
  password: Rails.application.secrets.mailinabox_admin_password,
  domain: 'mail.example.com'
)

api.user_exists?(email)

# all users
api.users

# all aliases
api.aliases

# adds one email to an (maybe) existing alias
api.add_to_alias(email, alias_list)

# Creates new alias with full list of recipients
api.create_alias('support@example.com', ['abc@cde', 'bdd@aaa.com'])

api.update_password(email, password)

api.create_email(email, password, privileges: nil)

## NOT IMPLEMENTED
# POST /mail/aliases/remove
api.remove_alias
# POST /mail/users/remove
api.remove_user
# GET /mail/users/privileges
api.user_privileges
# POST /mail/users/privileges/add
api.add_user_privilege
# POST /mail/users/privileges/add
api.remove_user_privilege

# DNS Stuff, SSL Stuff, ...
```

