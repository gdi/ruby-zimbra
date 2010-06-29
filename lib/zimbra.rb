$:.unshift(File.join(File.dirname(__FILE__)))
require 'zimbra/handsoap_service'
require 'zimbra/auth'
require 'zimbra/cos'
require 'zimbra/domain'
require 'zimbra/distribution_list'
require 'zimbra/account'
require 'zimbra/acl'
require 'zimbra/common_elements'

# Manages a Zimbra SOAP session.  Offers ability to set the endpoint URL, log in, and enable debugging.
module Zimbra
  class << self

    # The URL that will be used to contact the Zimbra SOAP service
    def url
      @@url
    end
    # Sets the URL of the Zimbra SOAP service
    def url=(url)
      @@url = url
    end

    # Turn debugging on/off.  Outputs full SOAP conversations to stdout.
    #   Zimbra.debug = true
    #   Zimbra.debug = false
    def debug=(val)
      Handsoap::Service.logger = (val ? $stdout : nil)
      @@debug = val
    end

    # Whether debugging is enabled
    def debug
      @@debug ||= false
    end

    # Authorization token - obtained after successful login
    def auth_token
      @@auth_token
    end

    # Log into the zimbra SOAP service.  This is required before any other action is performed
    # If a login has already been performed, another login will not be attempted
    def login(username, password)
      return @@auth_token if defined?(@@auth_token) && @@auth_token
      reset_login(username, password)
    end

    # re-log into the zimbra SOAP service
    def reset_login(username, password)
      puts "Logging into zimbra as #{username}"
      @@auth_token = Auth.login(username, password)
    end
  end
end
