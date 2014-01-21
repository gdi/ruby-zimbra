module Zimbra
  class Appointment
    class Alarm
      class << self
        def new_from_zimbra_attributes(zimbra_attributes)
          new(parse_zimbra_attributes(zimbra_attributes))
        end
        
        # <alarm action="DISPLAY">
        #   <trigger>
        #     <rel neg="1" m="5" related="START"/>
        #   </trigger>
        #   <desc/>
        # </alarm>
        def parse_zimbra_attributes(zimbra_attributes)
          zimbra_attributes = Zimbra::Hash.symbolize_keys(zimbra_attributes.dup, true)
          zimbra_attributes = zimbra_attributes[:trigger][:rel][:attributes]
          
          duration_negative = (zimbra_attributes[:neg] && zimbra_attributes[:neg] == 1) ? true : false
          
          {
            duration_negative: duration_negative, 
            weeks: zimbra_attributes[:w], 
            days: zimbra_attributes[:d], 
            hours: zimbra_attributes[:h], 
            minutes: zimbra_attributes[:m], 
            seconds: zimbra_attributes[:s], 
            when: zimbra_attributes[:related] == "START" ? :start : :end, 
            repeat_count: zimbra_attributes[:count]
          }
        end
      end
      
      ATTRS = [:duration_negative, :weeks, :days, :hours, :minutes, :seconds, :when, :repeat_count] unless const_defined?(:ATTRS)
      
      attr_accessor *ATTRS
    
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
      
      def to_hash(options = {})
        hash = ATTRS.inject({}) do |attr_hash, attr_name|
          attr_hash[attr_name] = self.send(:"#{attr_name}")
          attr_hash
        end
        hash.reject! { |key, value| options[:except].include?(key.to_sym) || options[:except].include?(key.to_s) } if options[:except]
        hash.reject! { |key, value| !options[:only].include?(key.to_sym) && !options[:only].include?(key.to_s) } if options[:only]
        hash
      end
    end
  end
end
