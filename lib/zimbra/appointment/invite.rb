module Zimbra
  class Appointment
    class Invite
      ATTRS = [
        :id, :recurrence_id, :sequence_number, 
        
        :start_date_time, :end_date_time,
        :name, :fragment, :description, :alarm, :recurrence_rule, :attendees, 
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
            :fragment                  => zimbra_attributes[:fr],
            :description               => zimbra_attributes[:desc],
            :comment                   => zimbra_attributes[:comment],
            :alarm                     => zimbra_attributes[:alarm],
            :recurrence_rule           => zimbra_attributes[:recur],
            :attendees                 => zimbra_attributes[:at]
            })
      
          if zimbra_attributes[:s]
            attrs[:start_date_time] = zimbra_attributes[:s][:u]
          end
        
          if zimbra_attributes[:e]
            attrs[:end_date_time] = zimbra_attributes[:e][:u]
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
      
      def exception=(exception_attributes)
        return @exception = nil unless exception_attributes
        
        @exception = Zimbra::Appointment::RecurException.new_from_zimbra_attributes(exception_attributes)
      end
    
      def recurrence_rule=(recur_rule_attributes)
        @recurrence_rule = Zimbra::Appointment::RecurRule.new_from_zimbra_attributes(recur_rule_attributes)
      end
    
      def attendees=(attendees_attributes)
        return @attendees = [] unless attendees_attributes
      
        attendees_attributes = attendees_attributes.is_a?(Array) ? attendees_attributes : [attendees_attributes]
        @attendees = attendees_attributes.collect { |attrs| Zimbra::Appointment::Attendee.new_from_zimbra_attributes(attrs[:attributes]) }
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
    
      def invite_status=(val)
        @invite_status = parse_invite_status(val)
      end
    
      def visibility=(val)
        @visibility = parse_visibility_status(val)
      end
    
      def transparency=(val)
        @transparency = parse_transparency_status(val)
      end
    
      def all_day=(val)
        @all_day = parse_all_day(val)
      end
      
      def start_date_time(val)
        @start_date_time = parse_date_in_seconds(val)
      end
      
      def end_date_time(val)
        @end_date_time = parse_date_in_seconds(val)
      end
        
      private
    
      def parse_date_in_seconds(seconds)
        Time.at(seconds / 1000)
      end
      
      def parse_all_day(val)
        possible_values = {
          0 => false,
          1 => true,
          '0' => false,
          '1' => true
        }
        possible_values[val] || val
      end
    
      def parse_free_busy_status(fb_status)
        possible_values = {
          'F' => :free,
          'B' => :busy,
          'T' => :busy_tentative,
          'U' => :busy_unavailable
        }
        possible_values[fb_status] || fb_status
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
  end
end
