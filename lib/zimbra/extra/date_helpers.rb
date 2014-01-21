module Zimbra
  class DateHelpers
    class Frequency
      FREQUENCIES = [
        { name: :secondly, zimbra_name: 'SEC', abbreviations: [] },
        { name: :minutely, zimbra_name: 'MIN', abbreviations: [] },
        { name: :hourly,   zimbra_name: 'HOU', abbreviations: [] },
        { name: :daily,    zimbra_name: 'DAI', abbreviations: [] },
        { name: :weekly,   zimbra_name: 'WEE', abbreviations: [] },
        { name: :monthly,  zimbra_name: 'MON', abbreviations: [] },
        { name: :yearly,   zimbra_name: 'YEA', abbreviations: [] }
      ]
      
      class << self
        def all
          @all ||= FREQUENCIES.inject([]) do |frequencies, data|
            frequencies << new(data)
          end
        end
        
        def find(name_or_abbreviation)
          all.find { |frequency| frequency.match?(name_or_abbreviation) }
        end
      end
      
      attr_accessor :name, :zimbra_name, :abbreviations
      
      def initialize(args = {})
        @name = args[:name]
        @zimbra_name = args[:zimbra_name]
        @abbreviations = args[:abbreviations]
      end
      
      def match?(name_or_abbreviation)
        downcased_matcher = name_or_abbreviation.to_s.downcase
        ([name.to_s, zimbra_name.to_s] + abbreviations).map(&:downcase).include?(downcased_matcher)
      end
      
      def to_sym
        name.downcase.to_sym
      end
    end
    
    class WeekDay
      WEEK_DAYS = [
        {
          id: 1, name: :Sunday, zimbra_name: 'SU',
          abbreviations: ['su', 'sun']
        },
        {
          id: 2, name: :Monday, zimbra_name: 'MO', 
          abbreviations: ['mo', 'mon']
        },
        {
          id: 3, name: :Tuesday, zimbra_name: 'TU', 
          abbreviations: ['tu', 'tue']
        },
        {
          id: 4, name: :Wednesday, zimbra_name: 'WE', 
          abbreviations: ['we', 'wed']
        },
        {
          id: 5, name: :Thursday, zimbra_name: 'TH', 
          abbreviations: ['th', 'thu', 'thur', 'thurs']
        },
        {
          id: 6, name: :Friday, zimbra_name: 'FR', 
          abbreviations: ['fr', 'fri']
        },
        {
          id: 7, name: :Saturday, zimbra_name: 'SA', 
          abbreviations: ['sa', 'sat']
        }
      ] unless const_defined?(:WEEK_DAYS)
      
      class << self
        def all
          @all ||= WEEK_DAYS.inject([]) do |week_days, data|
            week_days << new(data)
          end
        end
        
        def find(id_name_or_abbreviation)
          all.find { |week_day| week_day.match?(id_name_or_abbreviation) }
        end
      end
      
      attr_accessor :id, :name, :abbreviations, :zimbra_name
      
      def initialize(args = {})
        @id = args[:id]
        @name = args[:name]
        @zimbra_name = args[:zimbra_name]
        @abbreviations = args[:abbreviations]
      end
      
      def match?(id_name_or_abbreviation)
        if id_name_or_abbreviation.is_a?(Fixnum)
          id_name_or_abbreviation == id
        else
          downcased_matcher = id_name_or_abbreviation.to_s.downcase
          ([name.to_s, zimbra_name.to_s] + abbreviations).map(&:downcase).include?(downcased_matcher)
        end
      end
      
      def to_sym
        name.downcase.to_sym
      end
    end
  end
end