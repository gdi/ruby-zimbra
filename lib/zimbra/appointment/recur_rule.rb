module Zimbra
  class Appointment
    class RecurRule
      class << self
        def new_from_zimbra_attributes(zimbra_attributes)
          return nil unless zimbra_attributes
          new(parse_zimbra_attributes(zimbra_attributes))
        end
        
        def parse_zimbra_attributes(zimbra_attributes)
          attrs = {}
          
          zimbra_attributes = Zimbra::Hash.symbolize_keys(zimbra_attributes.dup, true)
          zimbra_attributes = zimbra_attributes[:add][:rule]
          
          attrs[:frequency] = zimbra_attributes[:attributes][:freq] if zimbra_attributes[:attributes]
          attrs[:until_date] = zimbra_attributes[:until][:attributes][:d] if zimbra_attributes[:until]
          attrs[:interval] = zimbra_attributes[:interval][:attributes][:ival] if zimbra_attributes[:interval]
          attrs[:count] = zimbra_attributes[:count][:attributes][:num] if zimbra_attributes[:count]
          
          if zimbra_attributes[:bysetpos]
            attrs[:by_set_position] = zimbra_attributes[:bysetpos][:attributes][:poslist]
            attrs[:by_set_position] = [attrs[:by_set_position]] unless attrs[:by_set_position].is_a?(Array)
          end
          
          if zimbra_attributes[:byday] && zimbra_attributes[:byday][:wkday] && zimbra_attributes[:byday][:wkday].is_a?(Array)
            attrs[:by_day] = zimbra_attributes[:byday][:wkday].collect do |wkday|
              wkday = Zimbra::Hash.symbolize_keys(wkday, true)
              wkday_hash = { day: wkday[:attributes][:day] }
              wkday_hash[:week_number] = wkday[:attributes][:ordwk] if wkday[:attributes][:ordwk]
              wkday_hash
            end
          elsif zimbra_attributes[:byday] && zimbra_attributes[:byday][:wkday]
            day_hash = { day: zimbra_attributes[:byday][:wkday][:attributes][:day] }
            day_hash[:week_number] = zimbra_attributes[:byday][:wkday][:attributes][:ordwk] if zimbra_attributes[:byday][:wkday][:attributes][:ordwk]
            attrs[:by_day] = [day_hash]
          end

          if zimbra_attributes[:bymonth]
            attrs[:by_month] = zimbra_attributes[:bymonth][:attributes][:molist]
            attrs[:by_month] = [attrs[:by_month]] unless attrs[:by_month].is_a?(Array)
          end
          
          if zimbra_attributes[:bymonthday]
            attrs[:by_month_day] = zimbra_attributes[:bymonthday][:attributes][:modaylist]
            attrs[:by_month_day] = [attrs[:by_month_day]] unless attrs[:by_month_day].is_a?(Array)
          end
          
          attrs
        end
      end
      
      ATTRS = [
        :frequency,
        :interval,
        :by_day,
        :by_month,
        :by_month_day,
        :count,
        :until_date,
        :by_set_position
      ] unless const_defined?(:ATTRS)
      
      attr_accessor *ATTRS
    
      def initialize(args = {})
        self.attributes = args
      end
    
      # take attributes by the xml name or our more descriptive name
      def attributes=(args = {})
        ATTRS.each do |attr_name|
          self.send(:"#{attr_name}=", (args[attr_name] || args[attr_name.to_s]))
        end
      end
      
      def frequency=(val)
        frequency = Zimbra::DateHelpers::Frequency.find(val)
        @frequency = frequency || val
      end
      
      def until_date=(val)
        @until_date = Time.parse(val) rescue val
      end
      
      def by_day=(val)
        @by_day = if val.is_a?(Array)
          val.collect do |day_specification|
            day_specification[:day] = Zimbra::DateHelpers::WeekDay.find(day_specification[:day]) || day_specification[:day]
            day_specification
          end
        else
          val
        end
      end
      
      def to_hash(options = {})
        hash = {
          :frequency => frequency ? frequency.to_sym : nil,
          :interval => interval,
          :by_month => by_month,
          :by_month_day => by_month_day,
          :count => count,
          :until_date => until_date,
          :by_set_position => by_set_position
        }
        hash[:by_day] = by_day.collect do |day_specification|
          day_specification[:day] = day_specification[:day].to_sym if day_specification[:day]
          day_specification
        end if by_day
        hash.reject! { |key, value| value.nil? }
        hash.reject! { |key, value| options[:except].include?(key.to_sym) || options[:except].include?(key.to_s) } if options[:except]
        hash.reject! { |key, value| !options[:only].include?(key.to_sym) && !options[:only].include?(key.to_s) } if options[:only]
        hash
      end
    end
  end
end
