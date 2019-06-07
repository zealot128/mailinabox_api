require "mailinabox_api/version"

module MailinaboxApi
  class Error < StandardError
    attr_reader :response
    def initialize(message, response = nil)
      @response = response
      super(message)
    end
  end
end

require 'mailinabox_api/client'
