# zmsoap -z -m mail03@greenviewdata.com SearchRequest @types="appointment" @query="inid:10"
# http://files.zimbra.com/docs/soap_api/8.0.4/soap-docs-804/api-reference/zimbraMail/Search.html
# GetRecurRequest

module Zimbra
  class Appointment
    class << self
      def find_all_by_calendar_id(calendar_id)
        AppointmentService.find_all_by_calendar_id(calendar_id)
      end
      
      def find(appointment_id)
        AppointmentService.find(appointment_id)
      end
    end
    
    ATTRS = [
      :id, :uid, :name, :tag_names, :attendees_never_notified, :revision,
      :is_organizer, :modified_date, :computed_free_busy_status, :free_busy_setting,
      :flags, :date, :invite_status, :all_day, :modified_sequence, :visibility,
      :location, :calendar_id, :component_number, :changes_not_sent_to_attendees,
      :has_alarm, :x_uid, :size,  :transparency, :participation_status
    ] unless const_defined?(:ATTRS)
    
    attr_accessor *ATTRS
    
    def initialize(args = {})
      self.attributes = args
    end
    
    def attributes=(args = {})
      ATTRS.each do |attr_name|
        self.send(:"#{attr_name}=", (args[attr_name] || args[attr_name.to_s])) if args.has_key?(attr_name) || args.has_key?(attr_name.to_s)
      end
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
      Parser.appointment_response(xml)
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
      # These attributes, I'm not sure about
      # invId="" sf="" dur="" cm=""
      
      ATTRIBUTE_MAPPING = {
        :id => :id,
        :uid => :uid,
        :name => :name,
        :tn => :tag_names,
        :neverSent => :attendees_never_notified,
        :rev => :revision,
        :isOrg => :is_organizer,
        :md => :modified_date,
        :fba => :computed_free_busy_status,
        :fb => :free_busy_setting,
        :f => :flags,
        :d => :date,
        :status => :invite_status,
        :allDay => :all_day,
        :ms => :modified_sequence,
        :class => :visibility,
        :loc => :location,
        :l => :calendar_id,
        :compNum => :component_number,
        :draft => :changes_not_sent_to_attendees,
        :alarm => :has_alarm,
        :x_uid => :x_uid,
        :s => :size,
        :transp => :transparency,
        :ptst => :participation_status
      }
      
      class << self
        def get_search_response(response)
          (response/"//n2:appt").map do |node|
            appointment_response(node)
          end
        end

        def appointment_response(node)
          appointment_attributes = ATTRIBUTE_MAPPING.inject({}) do |attrs, (xml_name, attr_name)|
            attrs[attr_name] = (node/"@#{xml_name}").to_s
            attrs
          end
          # TODO: Parse alarms, invites, etc
          Zimbra::Appointment.new(appointment_attributes) 
        end
      end
    end
  end
end
