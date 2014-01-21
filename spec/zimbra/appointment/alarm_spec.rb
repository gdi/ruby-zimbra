require 'spec_helper'

describe Zimbra::Appointment::Alarm do
  before do
    @xml_api_responses_path = File.join(@fixture_path, 'xml_api_responses', 'alarms')
  end
  
  describe ".new_from_zimbra_attributes" do
    @sample_attribute_files = {
      '15_minutes_before.xml' => {
        :duration_negative=>true, :weeks=>nil, :days=>nil, :hours=>nil, :minutes=>15, :seconds=>nil, :when=>:start, :repeat_count=>nil
      },
      'using_all_intervals.xml' => {
        :duration_negative=>false, :weeks=>1, :days=>2, :hours=>3, :minutes=>15, :seconds=>25, :when=>:end, :repeat_count=>2
      }
    }
  
    @sample_attribute_files.each do |file_name, expected_attributes|
      context file_name do
        before do
          @attributes = Zimbra::Hash.from_xml(File.read(File.join(@xml_api_responses_path, file_name)))
          @attributes = @attributes[:appt][:inv][:comp][:alarm]
          @alarm = Zimbra::Appointment::Alarm.new_from_zimbra_attributes(@attributes)
        end
        
        it "should match the expected attributes" do
          @alarm.to_hash.should == expected_attributes
        end
      end
    end
  end
end

