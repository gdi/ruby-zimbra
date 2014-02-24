$:.unshift(File.join(File.dirname(__FILE__)))
require 'zimbra/handsoap_service'
require 'zimbra/handsoap_account_service'
require 'zimbra/auth'
require 'zimbra/cos'
require 'zimbra/domain'
require 'zimbra/distribution_list'
require 'zimbra/account'
require 'zimbra/acl'
require 'zimbra/common_elements'
require 'zimbra/delegate_auth_token'
require 'zimbra/folder'
require 'zimbra/calendar'
require 'zimbra/appointment'
require 'zimbra/ext/hash'
require 'zimbra/extra/date_helpers'

# Manages a Zimbra SOAP session.  Offers ability to set the endpoint URL, log in, and enable debugging.
module Zimbra
  class << self

    # The URL that will be used to contact the Zimbra SOAP service
    def admin_api_url
      @@admin_api_url
    end
    # Sets the URL of the Zimbra SOAP service
    def admin_api_url=(url)
      @@admin_api_url = url
    end
    
    def account_api_url
      @@account_api_url
    end
    
    def account_api_url=(url)
      @@account_api_url = url
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
    
    def account_auth_token
      @@account_auth_token
    end

    # Log into the zimbra SOAP service.  This is required before any other action is performed
    # If a login has already been performed, another login will not be attempted
    def login(username, password)
      return @@auth_token if defined?(@@auth_token) && @@auth_token
      reset_login(username, password)
    end

    # re-log into the zimbra SOAP service
    def reset_login(username, password)
      @@auth_token = Auth.login(username, password)
    end
    
    def account_login(username)
      delegate_auth_token = DelegateAuthToken.for_account_name(username)
      return false unless delegate_auth_token
      @@account_auth_token = delegate_auth_token.token
      true
    end
  end
end
