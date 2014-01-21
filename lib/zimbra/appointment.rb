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
          :invites                   => zimbra_attributes[:appt][:inv],
          :date                      => zimbra_attributes[:appt][:attributes][:d],
          :loaded_from_search        => zimbra_attributes[:loaded_from_search]
        }
      end
    end
    
    ATTRS = [
      :id, :uid, :date, :revision, :size, :calendar_id, 
      :replies, :invites
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
    
    def destroy
      # zmsoap -vv -z -m mail03@greenviewdata.com CancelAppointmentRequest @id="498-497" @comp=0
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
    
    def invites=(invites_attributes)
      return @invites = nil unless invites_attributes
      
      invites_attributes = invites_attributes.is_a?(Array) ? invites_attributes : [ invites_attributes ]
      @invites = invites_attributes.collect { |attrs| Zimbra::Appointment::Invite.new_from_zimbra_attributes(attrs) }
    end
  
    def date=(val)
      if val.is_a?(Integer)
        @date = parse_date_in_seconds(val)
      else
        @date = val
      end
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

    class Builder
      class << self
        def find_all_with_query(message, query)
          message.set_attr 'query', query
          message.set_attr 'types', 'appointment'
        end
        
        def find_by_id(message, id)
          message.set_attr 'id', id
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
