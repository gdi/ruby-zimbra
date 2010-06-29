$:.unshift(File.join(File.dirname(__FILE__),'../lib'))
require 'zimbra'
require 'nokogiri'

def zimbra_soap_doc(xml)
  Nokogiri::XML.parse(<<XML)
<?xml version="1.0" encoding="UTF-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:n2="http://foo.bar/baz">
  <soap:Header>
    <context xmlns="urn:zimbra"/>
  </soap:Header>
  <soap:Body>
#{xml}
  </soap:Body>
</soap:Envelope>
XML
end
