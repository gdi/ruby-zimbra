module Zimbra
  class Appointment
    class Reply
      ATTRS = [
        :sequence_number, :date, :email_address, :participation_status, :sent_by, :recurrence_range_type, :recurrence_id, :timezone, :recurrence_id_utc
      ] unless const_defined?(:ATTRS)
      
      attr_accessor *ATTRS
      
      class << self
        def new_from_zimbra_attributes(zimbra_attributes)
          new(parse_zimbra_attributes(zimbra_attributes))
        end
        
        def parse_zimbra_attributes(zimbra_attributes)
          zimbra_attributes = Zimbra::Hash.symbolize_keys(zimbra_attributes.dup, true)
          
          {
            :sequence_number       => zimbra_attributes[:seq],
            :date                  => zimbra_attributes[:d],
            :email_address         => zimbra_attributes[:at],
            :participation_status  => zimbra_attributes[:ptst],
            :sent_by               => zimbra_attributes[:sentBy],
            :recurrence_range_type => zimbra_attributes[:rangeType],
            :recurrence_id         => zimbra_attributes[:recurId],
            :timezone              => zimbra_attributes[:tz],
            :recurrence_id_utc     => zimbra_attributes[:ridZ]
          }
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
      
      def participation_status=(val)
        @participation_status = parse_participation_status(val)
      end
    
      def date=(val)
        if val.is_a?(Integer)
          @date = parse_date_in_seconds(val)
        else
          @date = val
        end
      end
      
      def to_hash(options = {})
        hash = ATTRS.inject({}) do |hash, attr_name|
          hash[attr_name] = self.send(attr_name)
          hash
        end
        hash.reject! { |key, value| options[:except].include?(key.to_sym) || options[:except].include?(key.to_s) } if options[:except]
        hash.reject! { |key, value| !options[:only].include?(key.to_sym) && !options[:only].include?(key.to_s) } if options[:only]
        hash
      end
    
      private
    
      def parse_participation_status(status)
        possible_values = {
          'NE' => :needs_action,
          'AC' => :accept,
          'TE' => :tentative,
          'DE' => :declined,
          'DG' => :delegated,
          'CO' => :completed,
          'IN' => :in_process,
          'WE' => :waiting, 
          'DF' => :deferred
        }
        possible_values[status] || status
      end

      def parse_date_in_seconds(seconds)
        Time.at(seconds / 1000)
      end
    end
  end
end
