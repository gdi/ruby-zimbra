module Zimbra
  class Appointment
    class Invite
      ATTRS = [
        :appointment, 
        :id, :recurrence_id, :sequence_number, 
        
        :start_date_time, :end_date_time, :date,
        :name, :fragment, :description, :alarm, :alarm_attributes, :recurrence_rule, :recurrence_rule_attributes, :attendees, 
        :organizer_email_address, :is_organizer, :computed_free_busy_status,
        :free_busy_setting, :invite_status, :all_day, :visibility, :location, 
        :transparency, :replies,
        
        :comment, :recurrence_id_utc, :exception
      ] unless const_defined?(:ATTRS)
      
      attr_accessor *ATTRS
      
      class << self
        def new_from_zimbra_attributes(zimbra_attributes)
          new(parse_zimbra_attributes(zimbra_attributes))
        end
      
        def parse_zimbra_attributes(zimbra_attributes)
          zimbra_attributes = Zimbra::Hash.symbolize_keys(zimbra_attributes.dup, true)
      
          attrs = {}
          
          attrs[:appointment] = zimbra_attributes[:appointment] if zimbra_attributes.has_key?(:appointment)
          
          if zimbra_attributes.has_key?(:attributes)
            attrs.merge!({
              :id              => zimbra_attributes[:attributes][:id],
              :recurrence_id   => zimbra_attributes[:attributes][:recurId],
              :sequence_number => zimbra_attributes[:attributes][:seq],
              })
          end
          
          zimbra_attributes = zimbra_attributes[:comp]
          return attrs unless zimbra_attributes
          
          attrs.merge!({
            :fragment                   => zimbra_attributes[:fr],
            :description                => zimbra_attributes[:desc],
            :comment                    => zimbra_attributes[:comment],
            :alarm_attributes           => zimbra_attributes[:alarm],
            :recurrence_rule_attributes => zimbra_attributes[:recur],
            :attendees                  => zimbra_attributes[:at]
            })
      
          if zimbra_attributes[:s]
            attrs[:start_date_time] = zimbra_attributes[:s][:attributes][:u]
          else
          
          end
        
          if zimbra_attributes[:e]
            attrs[:end_date_time] = zimbra_attributes[:e][:attributes][:u]
          end
          
          if zimbra_attributes[:exceptId] && zimbra_attributes[:exceptId][:attributes]
            attrs[:exception] = zimbra_attributes[:exceptId][:attributes]
          end
          
          attrs[:organizer_email_address] = zimbra_attributes[:or][:attributes][:a] rescue nil
        
          return attrs unless zimbra_attributes.has_key?(:attributes)
        
          attrs.merge!({
            :name                      => zimbra_attributes[:attributes][:name],
            :computed_free_busy_status => zimbra_attributes[:attributes][:fba],
            :free_busy_setting         => zimbra_attributes[:attributes][:fb],
            :date                      => zimbra_attributes[:attributes][:d],
            :invite_status             => zimbra_attributes[:attributes][:status],
            :all_day                   => zimbra_attributes[:attributes][:allDay],
            :visibility                => zimbra_attributes[:attributes][:class],
            :location                  => zimbra_attributes[:attributes][:loc],
            :date                      => zimbra_attributes[:attributes][:d],
            :transparency              => zimbra_attributes[:attributes][:transp],
            :is_organizer              => zimbra_attributes[:attributes][:isOrg],
            :recurrence_id_utc         => zimbra_attributes[:attributes][:ridZ]
            })
          
          attrs
        end
      end
    
      def initialize(args = {})
        self.attributes = args
      end
    
      # take attributes by the xml name or our more descriptive name
      def attributes=(args = {})
        ATTRS.each do |attr_name|
          if args.has_key?(attr_name)
            self.send(:"#{attr_name}=", args[attr_name])
          elsif args.has_key?(attr_name.to_s)
            self.send(:"#{attr_name}=", args[attr_name.to_s])
          end
        end
      end
      
      def save
        return false unless appointment
        
        if appointment.new_record?
          appointment.save
        else
          Zimbra::AppointmentService.update(appointment, id)
        end
      end
      
      def cancel
        return false unless appointment
        return false if appointment.new_record?
        
        Zimbra::AppointmentService.cancel(appointment, id)
      end
      
      def exception=(exception_attributes)
        return @exception = nil unless exception_attributes
        
        @exception = Zimbra::Appointment::RecurException.new_from_zimbra_attributes(exception_attributes)
      end
    
      def recurrence_rule_attributes=(recur_rule_attributes)
        @recurrence_rule = Zimbra::Appointment::RecurRule.new_from_zimbra_attributes(recur_rule_attributes)
      end
    
      def attendees=(attendees_attributes)
        return @attendees = [] unless attendees_attributes
      
        attendees_attributes = attendees_attributes.is_a?(Array) ? attendees_attributes : [attendees_attributes]
        @attendees = attendees_attributes.collect { |attrs| Zimbra::Appointment::Attendee.new_from_zimbra_attributes(attrs[:attributes]) }
      end
    
      def alarm_attributes=(alarm_attributes)
        @alarm = alarm_attributes ? Zimbra::Appointment::Alarm.new_from_zimbra_attributes(alarm_attributes) : nil
      end
    
      def computed_free_busy_status=(val)
        @computed_free_busy_status = parse_free_busy_status(val)
      end
      
      def free_busy_setting_to_zimbra
        possible_free_busy_status_values.find { |k ,v| v == free_busy_setting }.first rescue free_busy_setting
      end
    
      def free_busy_setting=(val)
        @free_busy_setting = parse_free_busy_status(val)
      end
    
      def invite_status=(val)
        @invite_status = parse_invite_status(val)
      end
      
      def invite_status_to_zimbra
        possible_invite_status_values.find { |k, v| v == invite_status }.first rescue invite_status
      end
    
      def visibility=(val)
        @visibility = parse_visibility_status(val)
      end
      
      def visibility_to_zimbra
        possible_visibility_values.find { |k, v| v == visibility }.first rescue visibility
      end
      
      def transparency_to_zimbra
        possible_transparency_status_values.find { |k, v| v == transparency }.first rescue transparency
      end
    
      def transparency=(val)
        @transparency = parse_transparency_status(val)
      end
    
      def all_day=(val)
        @all_day = parse_all_day(val)
      end
      
      def start_date_time=(val)
        @start_date_time = val.is_a?(Integer) ? parse_date_in_seconds(val) : val
      end
      
      def end_date_time=(val)
        @end_date_time = val.is_a?(Integer) ? parse_date_in_seconds(val) : val
      end
      
      def date=(val)
        @date = val.is_a?(Integer) ? parse_date_in_seconds(val) : val
      end
      
      def create_xml(document)
        document.set_attr "id", id if id
        document.set_attr "allDay", all_day ? 1 : 0
        document.set_attr "loc", location if location
        document.set_attr "status", invite_status_to_zimbra if invite_status
        #document.set_attr "d", date.to_i * 1000 if date
        
        document.add "comp" do |comp|
          comp.set_attr "class", visibility_to_zimbra if visibility
          comp.set_attr "fb", free_busy_setting_to_zimbra if free_busy_setting
          comp.set_attr "isOrg", is_organizer ? 1 : 0
          comp.set_attr "name", name
          comp.set_attr "transp", transparency_to_zimbra if transparency
          comp.set_attr "d", date.to_i * 1000 if date
          
          if description && !description.empty?
            comp.add "description", description
          end
          
          if comment && !comment.empty?
            comp.add "comment", comment
          end
          
          comp.add "s" do |s_element|
            s_element.set_attr "u", start_date_time.to_i * 1000
            s_element.set_attr "d", start_date_time.utc.strftime("%Y%m%dT%H%M%SZ")
          end
          
          comp.add "e" do |e_element|
            e_element.set_attr "u", end_date_time.to_i * 1000
            e_element.set_attr "d", end_date_time.utc.strftime("%Y%m%dT%H%M%SZ")
          end
          
          if alarm
            comp.add "alarm" do |alarm_element|
              alarm_element.set_attr "action", "DISPLAY"
              
              alarm.create_xml(alarm_element)
            end
          end
          
          if recurrence_rule
            comp.add "recur" do |recur_element|
              recur_element.add "add" do |add_element|
                recurrence_rule.create_xml(add_element)
              end
            end
          end
          
          if attendees && attendees.count > 0
            attendees.each do |attendee|
              attendee.create_xml(comp)
            end
          end
          
          if organizer_email_address
            comp.add "or" do |or_element|
              or_element.set_attr "a", organizer_email_address
            end
          end
          
          if exception
            exception.create_xml(comp)
          end
        end
        # 
        # ATTRS = [
        #  :recurrence_id, :sequence_number, :replies,
        # 
        #   :, :recurrence_id_utc, 
      end
        
      private
    
      def parse_date_in_seconds(seconds)
        Time.at(seconds / 1000)
      end
      
      def possible_all_day_values
        @possible_all_day_values ||= {
          0 => false,
          1 => true
        }
      end
      
      def parse_all_day(val)
        possible_all_day_values[val.to_i] || val
      end
    
      def possible_free_busy_status_values
        @possible_free_busy_status_values ||= {
          'F' => :free,
          'B' => :busy,
          'T' => :busy_tentative,
          'U' => :busy_unavailable
        }
      end
    
      def parse_free_busy_status(fb_status)
        possible_free_busy_status_values[fb_status] || fb_status
      end
      
      def possible_invite_status_values
        @possible_invite_status_values ||= {
          'TENT' => :tentative,
          'CONF' => :confirmed,
          'CANC' => :canceled,
          'NEED' => :need, # Not sure about this one, it's not documented
          'COMP' => :completed,
          'INPR' => :in_progress,
          'WAITING' => :waiting,
          'DEFERRED' => :deferred
        }
      end
    
      def parse_invite_status(status)
        possible_invite_status_values[status] || status
      end
      
      def possible_visibility_values
        @possible_visibility_values ||= {
          'PUB' => :public,
          'PRI' => :private,
          'CON' => :confidential
        }
      end
      
      def parse_visibility_status(status)
        possible_visibility_values[status] || status
      end
    
      def possible_transparency_status_values
        @possible_transparency_status_values ||= {
          'O' => :opaque,
          'T' => :transparent
        }
      end
    
      def parse_transparency_status(status)
        possible_transparency_status_values[status] || status
      end
      
    end
  end
end
