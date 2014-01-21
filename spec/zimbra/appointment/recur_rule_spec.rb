require 'spec_helper'

describe Zimbra::Appointment::RecurRule do
  before do
    @xml_api_responses_path = File.join(@fixture_path, 'xml_api_responses', 'recur_rules')
  end
  
  describe ".new" do
    @sample_attribute_files = {
      'second_wednesday_of_every_month.xml' => {
        :frequency => :monthly,
        :interval => 1,
        :by_day => [
          { :day => :wednesday, :week_number => 2 }
        ]
      },
      'day_27_of_every_2_months.xml' => {
        frequency: :monthly,
        interval: 2,
        by_month_day: [27]
      },
      'every_2_days.xml' => {
        frequency: :daily,
        interval: 2
      },
      'every_3_weeks_on_tuesday_and_friday.xml' => {
        :frequency=>:weekly, 
        :interval=>3, 
        :by_day => [
          { :day => :tuesday },
          { :day => :friday }
        ]
      },
      'every_day_50_instances.xml' => {
        :frequency => :daily, 
        :interval => 1,
        :count => 50
      },
      'every_monday_wednesday_friday.xml' => {
        :frequency => :weekly, 
        :interval => 1, 
        :by_day => [
          {:day=> :monday},
          {:day=> :wednesday},
          {:day=> :friday}
        ]
      },
      'every_tuesday.xml' => {
        :frequency=>:weekly, 
        :interval=>1, 
        :by_day=>[
          {:day=>:tuesday}
        ]
      },
      'every_weekday_with_end_date.xml' => {
        :frequency=>:daily, 
        :until_date=>Time.parse("20131220T045959Z"), 
        :interval=>1, 
        :by_day=>[
          {:day=>:monday}, 
          {:day=>:tuesday}, 
          {:day=>:wednesday}, 
          {:day=>:thursday}, 
          {:day=>:friday}
        ]
      },
      'every_year_on_february_2.xml' => {
        :frequency=>:yearly, 
        :interval=>1, 
        :by_month_day=>[2],
        :by_month => [2]
      },
      'first_day_of_every_month.xml' => {
        :frequency=>:monthly, 
        :interval=>1, 
        :by_day=>[
          {:day=>:sunday}, 
          {:day=>:monday}, 
          {:day=>:tuesday}, 
          {:day=>:wednesday}, 
          {:day=>:thursday}, 
          {:day=>:friday},
          {:day=>:saturday}
        ],
        :by_set_position => [1]
      },
      'first_monday_of_every_february.xml' => {
        :frequency=>:yearly, 
        :interval=>1, 
        :by_set_position=>[1], 
        :by_day=>[
          {:day=>:monday}
        ], 
        :by_month=>[2]
      },
      'first_weekend_day_of_every_month.xml' => {
        :frequency=>:monthly, 
        :interval=>1, 
        :by_set_position=>[1], 
        :by_day=>[
          {:day=>:sunday}, 
          {:day=>:saturday}
        ]
      },
      'last_day_of_every_month.xml' => {
        :frequency=>:monthly, 
        :interval=>1, 
        :by_set_position=>[-1], 
        :by_day=>[
          {:day=>:sunday}, 
          {:day=>:monday}, 
          {:day=>:tuesday}, 
          {:day=>:wednesday}, 
          {:day=>:thursday}, 
          {:day=>:friday},
          {:day=>:saturday}
        ]
      },
      'second_day_of_every_2_months.xml' => {
        :frequency=>:monthly, 
        :interval=>2, 
        :by_set_position=>[2], 
        :by_day=>[
          {:day=>:sunday}, 
          {:day=>:monday}, 
          {:day=>:tuesday}, 
          {:day=>:wednesday}, 
          {:day=>:thursday}, 
          {:day=>:friday},
          {:day=>:saturday}
        ]
      }
      #'weekly_with_an_exception.xml' => {}
    }
    
    @sample_attribute_files.each do |file_name, expected_attributes|
      context file_name do
        before do
          @attributes = Zimbra::Hash.from_xml(File.read(File.join(@xml_api_responses_path, file_name)))
          @attributes = @attributes[:appt][:inv][:comp][:recur]
          @recur_rule = Zimbra::Appointment::RecurRule.new_from_zimbra_attributes(@attributes)
        end
        
        it "should match the expected attributes" do
          @recur_rule.to_hash.should == expected_attributes
        end
      end
    end
  end
  
  describe ".parse_zimbra_attributes" do

    @sample_attribute_files = {
      'second_wednesday_of_every_month.xml' => {
        :frequency => "MON",
        :interval => 1,
        :by_day => [
          { :day => 'WE', :week_number => 2 }
        ]
      },
      'day_27_of_every_2_months.xml' => {
        frequency: "MON",
        interval: 2,
        by_month_day: [27]
      },
      'every_2_days.xml' => {
        frequency: 'DAI',
        interval: 2
      },
      'every_3_weeks_on_tuesday_and_friday.xml' => {
        :frequency=>"WEE", 
        :interval=>3, 
        :by_day => [
          {:day=>"TU"},
          {:day=>"FR"}
        ]
      },
      'every_day_50_instances.xml' => {
        :frequency => "DAI", 
        :interval => 1,
        :count => 50
      },
      'every_monday_wednesday_friday.xml' => {
        :frequency => "WEE", 
        :interval => 1, 
        :by_day => [
          {:day=>"MO"},
          {:day=>"WE"},
          {:day=>"FR"}
        ]
      },
      'every_tuesday.xml' => {
        :frequency=>"WEE", 
        :interval=>1, 
        :by_day=>[
          {:day=>"TU"}
        ]
      },
      'every_weekday_with_end_date.xml' => {
        :frequency=>"DAI", 
        :until_date=>"20131220T045959Z", 
        :interval=>1, 
        :by_day=>[
          {:day=>"MO"}, 
          {:day=>"TU"}, 
          {:day=>"WE"}, 
          {:day=>"TH"}, 
          {:day=>"FR"}
        ]
      },
      'every_year_on_february_2.xml' => {
        :frequency=>"YEA", 
        :interval=>1, 
        :by_month_day=>[2],
        :by_month => [2]
      },
      'first_day_of_every_month.xml' => {
        :frequency=>"MON", 
        :interval=>1, 
        :by_day=>[
          {:day=>"SU"}, {:day=>"MO"}, {:day=>"TU"}, {:day=>"WE"}, {:day=>"TH"}, {:day=>"FR"}, {:day=>"SA"}
        ],
        :by_set_position => [1]
      },
      'first_monday_of_every_february.xml' => {
        :frequency=>"YEA", 
        :interval=>1, 
        :by_set_position=>[1], 
        :by_day=>[{:day=>"MO"}], 
        :by_month=>[2]
      },
      'first_weekend_day_of_every_month.xml' => {
        :frequency=>"MON", 
        :interval=>1, 
        :by_set_position=>[1], 
        :by_day=>[{:day=>"SU"}, {:day=>"SA"}]
      },
      'last_day_of_every_month.xml' => {
        :frequency=>"MON", 
        :interval=>1, 
        :by_set_position=>[-1], 
        :by_day=>[{:day=>"SU"}, {:day=>"MO"}, {:day=>"TU"}, {:day=>"WE"}, {:day=>"TH"}, {:day=>"FR"}, {:day=>"SA"}]
      },
      'second_day_of_every_2_months.xml' => {
        :frequency=>"MON", 
        :interval=>2, 
        :by_set_position=>[2], 
        :by_day=>[{:day=>"SU"}, {:day=>"MO"}, {:day=>"TU"}, {:day=>"WE"}, {:day=>"TH"}, {:day=>"FR"}, {:day=>"SA"}]
      }
      #'weekly_with_an_exception.xml' => {}
    }
    
    @sample_attribute_files.each do |file_name, expected_attributes|
      context file_name do
        before do
          @attributes = Zimbra::Hash.from_xml(File.read(File.join(@xml_api_responses_path, file_name)))
          @attributes = @attributes[:appt][:inv][:comp][:recur]
        end
        
        it "should match the expected attributes" do
          Zimbra::Appointment::RecurRule.parse_zimbra_attributes(@attributes).should == expected_attributes
        end
      end
    end
  end
end
