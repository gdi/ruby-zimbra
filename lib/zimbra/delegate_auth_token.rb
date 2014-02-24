# http://files.zimbra.com/docs/soap_api/8.0.4/soap-docs-804/api-reference/zimbraAdmin/DelegateAuth.html

module Zimbra
  class DelegateAuthToken
    class << self
      def for_account_name(account_name)
        DelegateAuthTokenService.get_by_account_name(account_name)
      end
    end

    attr_accessor :account_name, :token, :lifetime

    def initialize(args = {})
      self.account_name = args[:account_name]
      self.token = args[:token]
      self.lifetime = args[:lifetime]
    end
  end
  
  class DelegateAuthTokenService < HandsoapService
    def get_by_account_name(account_name)
      xml = invoke("n2:DelegateAuthRequest") do |message|
        Builder.get_by_account_name(message, account_name)
      end
      return nil unless xml
      Parser.delegate_auth_token_response(account_name, xml)
    end
    
    class Builder
      class << self
        def get_by_account_name(message, account_name)
          message.add 'account', account_name do |c|
            c.set_attr 'by', 'name'
          end
        end
      end
    end
    class Parser
      class << self
        def delegate_auth_token_response(account_name, response)
          auth_token = (response/'//n2:authToken').to_s
          lifetime = (response/'//n2:lifetime').to_i
          
          Zimbra::DelegateAuthToken.new(account_name: account_name, token: auth_token, lifetime: lifetime) 
        end
      end
    end
  end
end
