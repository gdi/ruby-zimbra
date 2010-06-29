require 'handsoap'

module Zimbra
  module HandsoapErrors
    class SOAPFault < StandardError; end

    @@response = nil

    def on_http_error(response)
      @@response = response
      return nil if soap_fault_not_found?
      report_error(response) if http_error?
    end
    def report_error(response)
      message = response.body.scan(/<soap:faultstring>(.*)<\/soap:faultstring>/).first
      raise SOAPFault, message
    end
    def on_after_create_http_request(request)
      @@response = nil
    end

    def soap_fault_not_found?
      @@response && @@response.body =~ /no such/
    end
    def http_error?
      @@response && (500..599).include?(@@response.status)
    end
    def http_not_found?
      @@response && (400..499).include?(@@response.status)
    end
  end

  module HandsoapNamespaces
    def request_namespaces(doc)
      doc.alias 'n1', "urn:zimbra"
      doc.alias 'n2', "urn:zimbraAdmin"
      doc.alias 'env', 'http://schemas.xmlsoap.org/soap/envelope/'
    end
    def response_namespaces(doc)
      doc.add_namespace 'n2', "urn:zimbraAdmin"
    end
  end
  
  module HandsoapUriOverrides
    def uri
      Zimbra.url
    end
    def envelope_namespace
      'http://www.w3.org/2003/05/soap-envelope'
    end
    def request_content_type
      "application/soap+xml"
    end
  end

  class HandsoapService < Handsoap::Service
    include HandsoapErrors
    include HandsoapNamespaces
    extend HandsoapUriOverrides

    def on_create_document(doc)
      request_namespaces(doc)
      header = doc.find("Header")
      header.add "n1:context" do |s|
        s.set_attr "env:mustUnderstand", "0"
        s.add "n1:authToken", Zimbra.auth_token
      end
    end
    def on_response_document(doc)
      response_namespaces(doc)
    end
  end
end
