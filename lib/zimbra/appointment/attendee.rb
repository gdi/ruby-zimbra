module Zimbra
  class Appointment
    class Attendee
      ATTRS = [
        :email_address, :friendly_name, :rsvp, :role, :participation_status
      ] unless const_defined?(:ATTRS)
      
      attr_accessor *ATTRS
      
      class << self
        def new_from_zimbra_attributes(zimbra_attributes)
          new(parse_zimbra_attributes(zimbra_attributes))
        end
        
        def parse_zimbra_attributes(zimbra_attributes)
          zimbra_attributes = Zimbra::Hash.symbolize_keys(zimbra_attributes.dup, true)
          
          {
            :email_address        => zimbra_attributes[:a],
            :friendly_name        => zimbra_attributes[:d],
            :rsvp                 => zimbra_attributes[:rsvp],
            :role                 => zimbra_attributes[:role],
            :participation_status => zimbra_attributes[:ptst]
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
      
      def to_hash(options = {})
        hash = {
          :email_address => email_address,
          :friendly_name => friendly_name,
          :rsvp => rsvp,
          :role => role,
          :participation_status => participation_status
        }
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
    
    end
  end
end
