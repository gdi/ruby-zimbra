# zmsoap -z -m mail03@greenviewdata.com SearchRequest @types="appointment" @query="inid:10"
# http://files.zimbra.com/docs/soap_api/8.0.4/soap-docs-804/api-reference/zimbraMail/Search.html
# GetRecurRequest

module Zimbra
  class Appointment
    autoload :RecurRule, 'zimbra/appointment/recur_rule'
    autoload :Alarm, 'zimbra/appointment/alarm'
    autoload :Attendee, 'zimbra/appointment/attendee'
    autoload :Reply, 'zimbra/appointment/reply'
    autoload :Invite, 'zimbra/appointment/invite'
    autoload :RecurException, 'zimbra/appointment/recur_exception'
    
    class << self
      def find_all_by_calendar_id(calendar_id)
        AppointmentService.find_all_by_calendar_id(calendar_id).collect { |attrs| new_from_zimbra_attributes(attrs.merge(:loaded_from_search => true)) }
      end
      
      def find(appointment_id)
        new_from_zimbra_attributes(AppointmentService.find(appointment_id))
      end
      
      def new_from_zimbra_attributes(zimbra_attributes)
        new(parse_zimbra_attributes(zimbra_attributes))
      end
      
      def parse_zimbra_attributes(zimbra_attributes)
        zimbra_attributes = Zimbra::Hash.symbolize_keys(zimbra_attributes.dup, true)
        
        return {} unless zimbra_attributes.has_key?(:appt) && zimbra_attributes[:appt].has_key?(:attributes)
        
        {
          :id                        => zimbra_attributes[:appt][:attributes][:id],
          :uid                       => zimbra_attributes[:appt][:attributes][:uid],
          :revision                  => zimbra_attributes[:appt][:attributes][:rev],
          :calendar_id               => zimbra_attributes[:appt][:attributes][:l],
          :size                      => zimbra_attributes[:appt][:attributes][:s],
          :replies                   => zimbra_attributes[:appt][:replies],
          :invites_attributes        => zimbra_attributes[:appt][:inv],
          :date                      => zimbra_attributes[:appt][:attributes][:d],
          :loaded_from_search        => zimbra_attributes[:loaded_from_search]
        }
      end
    end
    
    ATTRS = [
      :id, :uid, :date, :revision, :size, :calendar_id, 
      :replies, :invites, :invites_attributes
    ] unless const_defined?(:ATTRS)
    
    attr_accessor *ATTRS
    attr_reader :loaded_from_search
    
    def initialize(args = {})
      self.attributes = args
      @loaded_from_search = args[:loaded_from_search] || false
    end
    
    def attributes=(args = {})
      ATTRS.each do |attr_name|
        self.send(:"#{attr_name}=", args[attr_name]) if args.has_key?(attr_name)
      end
    end
    
    def reload
      self.attributes = Zimbra::Appointment.parse_zimbra_attributes(AppointmentService.find(id))
      @loaded_from_search = false
    end

    def replies
      reload if loaded_from_search
      @replies
    end
    
    def replies=(replies_attributes)
      return @replies = [] unless replies_attributes
      
      replies_attributes = replies_attributes[:reply].is_a?(Array) ? replies_attributes[:reply] : [ replies_attributes[:reply] ]
      @replies = replies_attributes.collect { |attrs| Zimbra::Appointment::Reply.new_from_zimbra_attributes(attrs[:attributes]) }
    end
    
    def invites
      reload if loaded_from_search
      @invites
    end
    
    def invites_attributes=(invites_attributes)
      return @invites = nil unless invites_attributes
      
      invites_attributes = invites_attributes.is_a?(Array) ? invites_attributes : [ invites_attributes ]
      @invites = invites_attributes.collect { |attrs| Zimbra::Appointment::Invite.new_from_zimbra_attributes(attrs.merge( { :appointment => self } )) }
    end
  
    def date=(val)
      if val.is_a?(Integer)
        @date = parse_date_in_seconds(val)
      else
        @date = val
      end
    end
    
    def create_xml(document, invite_id = nil)
      document.add "m" do |mime|
        mime.set_attr "l", calendar_id
        
        invites.each do |invite|
          next unless invite_id.nil? || invite_id == invite.id
          
          mime.add "inv" do |invite_element|
            invite.create_xml(invite_element)
          end
        end
      end
    end

    def destroy
      invites.each do |invite|
        AppointmentService.cancel(self, invite.id)
      end
    end
    
    def save
      if new_record?
        @id = Zimbra::AppointmentService.create(self)
      else
        invites.each do |invite|
          Zimbra::AppointmentService.update(self, invite.id)
        end
      end
    end
    
    def new_record?
      id.nil?
    end
    
    private
    
    def parse_date_in_seconds(seconds)
      Time.at(seconds / 1000)
    end
    
  end
  
  class AppointmentService < HandsoapAccountService
    def find_all_by_calendar_id(calendar_id)
      xml = invoke("n2:SearchRequest") do |message|
        Builder.find_all_with_query(message, "inid:#{calendar_id}")
      end
      Parser.get_search_response(xml)
    end
    
    def find(appointment_id)
      xml = invoke("n2:GetAppointmentRequest") do |message|
        Builder.find_by_id(message, appointment_id)
      end
      Parser.appointment_response(xml/"//n2:appt")
    end

    def create(appointment)
      xml = invoke("n2:CreateAppointmentRequest") do |message|
        Builder.create(message, appointment)
      end
      response_hash = Zimbra::Hash.from_xml(xml.document.to_s)
      id = response_hash[:Envelope][:Body][:CreateAppointmentResponse][:attributes][:apptId] rescue nil
      invite_id = response_hash[:Envelope][:Body][:CreateAppointmentResponse][:attributes][:invId].gsub(/#{id}\-/, '').to_i rescue nil
      { :id => id, :invite_id => invite_id }
    end
    
    def update(appointment, invite_id)
      xml = invoke("n2:ModifyAppointmentRequest") do |message|
        Builder.update(message, appointment, invite_id)
        
        puts message.to_s
      end
    end
    
    def cancel(appointment, invite_id)
      xml = invoke("n2:CancelAppointmentRequest") do |message|
        Builder.cancel(message, appointment.id, invite_id)
      end
    end
    
    class Builder
      class << self
        def find_all_with_query(message, query)
          message.set_attr 'query', query
          message.set_attr 'types', 'appointment'
        end
        
        def find_by_id(message, id)
          message.set_attr 'id', id
        end

        def create(message, appointment)
          appointment.create_xml(message)
        end
        
        def update(message, appointment, invite_id)
          message.set_attr 'id', "#{appointment.id}-#{invite_id}"
          appointment.create_xml(message, invite_id)
        end
        
        def cancel(message, appointment_id, invite_id)
          message.set_attr 'id', "#{appointment_id}-#{invite_id}"
          message.set_attr 'comp', 0
        end
      end
    end
    
    class Parser
      class << self
        def get_search_response(response)
          (response/"//n2:appt").collect do |node|
            Zimbra::Hash.from_xml(node.to_xml)
          end
        end
        
        def appointment_response(node)
          # It's much easier to deal with this as a hash
          Zimbra::Hash.from_xml(node.to_xml)
        end
      end
    end
  end
end
