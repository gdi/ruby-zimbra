# zmsoap -z -m mail03@greenviewdata.com SearchRequest @types="appointment" @query="inid:10"
# http://files.zimbra.com/docs/soap_api/8.0.4/soap-docs-804/api-reference/zimbraMail/Search.html
# GetRecurRequest

module Zimbra
  class Appointment
    autoload :RecurRule, 'zimbra/appointment/recur_rule'
    autoload :Alarm, 'zimbra/appointment/alarm'
    autoload :Attendee, 'zimbra/appointment/attendee'
    autoload :Reply, 'zimbra/appointment/reply'
    
    class << self
      def find_all_by_calendar_id(calendar_id)
        AppointmentService.find_all_by_calendar_id(calendar_id).collect { |attrs| new(attrs) }
      end
      
      def find(appointment_id)
        new_from_zimbra_attributes(AppointmentService.find(appointment_id))
      end
      
      def new_from_zimbra_attributes(zimbra_attributes)
        new(parse_zimbra_attributes(zimbra_attributes))
      end
      
      def parse_zimbra_attributes(zimbra_attributes)
        zimbra_attributes = Zimbra::Hash.symbolize_keys(zimbra_attributes.dup, true)
      
        {
          :id                        => zimbra_attributes[:appt][:attributes][:id],
          :uid                       => zimbra_attributes[:appt][:attributes][:uid],
          :name                      => zimbra_attributes[:appt][:inv][:comp][:attributes][:name],
          :fragment                  => zimbra_attributes[:appt][:inv][:comp][:fr],
          :description               => zimbra_attributes[:appt][:inv][:comp][:desc],
          :alarm                     => zimbra_attributes[:appt][:inv][:comp][:alarm],
          :recurrence_rule           => zimbra_attributes[:appt][:inv][:comp][:recur],
          :attendees                 => zimbra_attributes[:appt][:inv][:comp][:at],
          :organizer_email_address   => zimbra_attributes[:appt][:inv][:comp][:or][:attributes][:a],
          :is_organizer              => zimbra_attributes[:appt][:inv][:comp][:attributes][:isOrg],
          :revision                  => zimbra_attributes[:appt][:attributes][:rev],
          :computed_free_busy_status => zimbra_attributes[:appt][:inv][:comp][:attributes][:fba],
          :free_busy_setting         => zimbra_attributes[:appt][:inv][:comp][:attributes][:fb],
          :date                      => zimbra_attributes[:appt][:inv][:comp][:attributes][:d],
          :invite_status             => zimbra_attributes[:appt][:inv][:comp][:attributes][:status],
          :all_day                   => zimbra_attributes[:appt][:inv][:comp][:attributes][:allDay] && zimbra_attributes[:appt][:inv][:comp][:attributes][:allDay] == 1 ? true : false,
          :visibility                => zimbra_attributes[:appt][:inv][:comp][:attributes][:class],
          :location                  => zimbra_attributes[:appt][:inv][:comp][:attributes][:loc],
          :calendar_id               => zimbra_attributes[:appt][:attributes][:l],
          :size                      => zimbra_attributes[:appt][:attributes][:s],
          :transparency              => zimbra_attributes[:appt][:inv][:comp][:attributes][:transp],
          :replies                   => zimbra_attributes[:appt][:replies]
        }
      end
    end
    
    ATTRS = [
      :id, :uid, :name, :fragment, :description, :alarm, :recurrence_rule, :attendees, 
      :organizer_email_address, :is_organizer, :revision, :computed_free_busy_status,
      :free_busy_setting, :date, :invite_status, :all_day, :visibility, :location, 
      :calendar_id, :size, :transparency, :replies
    ] unless const_defined?(:ATTRS)
    
    attr_accessor *ATTRS
    
    def initialize(args = {})
      self.attributes = args
    end
    
    def attributes=(args = {})
      ATTRS.each do |attr_name|
        self.send(:"#{attr_name}=", args[attr_name]) if args.has_key?(attr_name)
      end
    end
    
    def destroy
      # zmsoap -vv -z -m mail03@greenviewdata.com CancelAppointmentRequest @id="498-497" @comp=0
    end
    
    def recurrence_rule=(recur_rule_attributes)
      @recurrence_rule = Zimbra::Appointment::RecurRule.new_from_zimbra_attributes(recur_rule_attributes)
    end
    
    def attendees=(attendees_attributes)
      return @attendees = [] unless attendees_attributes
      
      attendees_attributes = attendees_attributes.is_a?(Array) ? attendees_attributes : [attendees_attributes]
      @attendees = attendees_attributes.collect { |attrs| Zimbra::Appointment::Attendee.new_from_zimbra_attributes(attrs[:attributes]) }
    end
    
    def replies=(replies_attributes)
      return @replies = [] unless replies_attributes
      
      replies_attributes = replies_attributes[:reply].is_a?(Array) ? replies_attributes[:reply] : [ replies_attributes[:reply] ]
      @replies = replies_attributes.collect { |attrs| Zimbra::Appointment::Reply.new_from_zimbra_attributes(attrs[:attributes]) }
    end
    
    def alarm=(alarm_attributes)
      @alarm = alarm_attributes ? Zimbra::Appointment::Alarm.new_from_zimbra_attributes(alarm_attributes) : nil
    end
    
    def computed_free_busy_status=(val)
      @computed_free_busy_status = parse_free_busy_status(val)
    end
    
    def free_busy_setting=(val)
      @free_busy_setting = parse_free_busy_status(val)
    end
    
    def date=(val)
      if val.is_a?(Integer)
        @date = parse_date_in_seconds(val)
      else
        @date = val
      end
    end
    
    def invite_status=(val)
      @invite_status = parse_invite_status(val)
    end
    
    def visibility=(val)
      @visibility = parse_visibility_status(val)
    end
    
    def transparency=(val)
      @transparency = parse_transparency_status(val)
    end
    
    private
    
    def parse_free_busy_status(fb_status)
      possible_values = {
        'F' => :free,
        'B' => :busy,
        'T' => :busy_tentative,
        'U' => :busy_unavailable
      }
      possible_values[fb_status] || fb_status
    end
    
    def parse_date_in_seconds(seconds)
      Time.at(seconds / 1000)
    end
    
    def parse_invite_status(status)
      possible_values = {
        'TENT' => :tentative,
        'CONF' => :confirmed,
        'CANC' => :canceled,
        'NEED' => :need, # Not sure about this one, it's not documented
        'COMP' => :completed,
        'INPR' => :in_progress,
        'WAITING' => :waiting,
        'DEFERRED' => :deferred
      }
      
      possible_values[status] || status
    end
    
    def parse_visibility_status(status)
      possible_values = {
        'PUB' => :public,
        'PRI' => :private,
        'CON' => :confidential
      }
      
      possible_values[status] || status
    end
    
    def parse_transparency_status(status)
      possible_values = {
        'O' => :opaque,
        'T' => :transparent
      }
      
      possible_values[status] || status
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
