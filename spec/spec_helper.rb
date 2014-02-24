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

def new_appointment_from_xml(xml_path)
  xml = File.read(xml_path)
  appointment_hash = Zimbra::Hash.from_xml(xml)
  Zimbra::Appointment.new_from_zimbra_attributes(appointment_hash)
end

RSpec.configure do |config|

  config.before(:each) do
    @fixture_path = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures')
  end
  
end

