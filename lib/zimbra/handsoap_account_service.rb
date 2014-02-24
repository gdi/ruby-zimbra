require 'handsoap'

module Zimbra
  module HandsoapAccountNamespaces
    def request_namespaces(doc)
      doc.alias 'n1', "urn:zimbra"
      doc.alias 'n2', "urn:zimbraMail"
      doc.alias 'env', 'http://schemas.xmlsoap.org/soap/envelope/'
    end
    def response_namespaces(doc)
      doc.add_namespace 'n2', "urn:zimbraMail"
    end
  end
  
  module HandsoapAccountUriOverrides
    def uri
      Zimbra.account_api_url
    end
    def envelope_namespace
      'http://www.w3.org/2003/05/soap-envelope'
    end
    def request_content_type
      "application/soap+xml"
    end
  end

  class HandsoapAccountService < Handsoap::Service
    include HandsoapErrors
    include HandsoapAccountNamespaces
    extend HandsoapAccountUriOverrides

    def on_create_document(doc)
      request_namespaces(doc)
      header = doc.find("Header")
      header.add "n1:context" do |s|
        s.set_attr "env:mustUnderstand", "0"
        s.add "n1:authToken", Zimbra.account_auth_token
      end
    end
    def on_response_document(doc)
      response_namespaces(doc)
    end
  end
end
