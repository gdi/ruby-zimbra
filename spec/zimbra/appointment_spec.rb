require File.join(File.dirname(__FILE__),'../spec_helper')
require 'json'

describe Zimbra::Appointment do
  describe ".parse_zimbra_attributes" do
    before do
      @xml_api_responses_path = File.join(@fixture_path, 'xml_api_responses', 'recur_rules')
      xml = File.read(File.join(@xml_api_responses_path, 'second_wednesday_of_every_month.xml'))
      @appointment_hash = Zimbra::Hash.from_xml(xml)
    end
    
    it "should return all the attributes" do
      Zimbra::Appointment.parse_zimbra_attributes(@appointment_hash).should == {:id=>518, :uid=>"1c71d474-5c1f-4048-84e3-9725c0825a44", :revision=>27656, :calendar_id=>10, :size=>0, :fragment=>nil, :description=>nil, :alarm=>{:attributes=>{:action=>"DISPLAY"}, :trigger=>{:rel=>{:attributes=>{:neg=>1, :m=>5, :related=>"START"}}}, :desc=>{}}, :recurrence_rule=>{:add=>{:rule=>{:attributes=>{:freq=>"MON"}, :interval=>{:attributes=>{:ival=>1}}, :byday=>{:wkday=>{:attributes=>{:ordwk=>2, :day=>"WE"}}}}}}, :attendees=>nil, :organizer_email_address=>"mail03@greenviewdata.com", :name=>"Test2222", :computed_free_busy_status=>"B", :free_busy_setting=>"B", :date=>1387571704000, :invite_status=>"CONF", :all_day=>nil, :visibility=>"PUB", :location=>"", :transparency=>"O", :is_organizer=>1}
    end
  end
  
  describe "#recurrence_rule" do
    before do
      @xml_api_responses_path = File.join(@fixture_path, 'xml_api_responses', 'recur_rules')
      @appointment = new_appointment_from_xml(File.join(@xml_api_responses_path, 'second_wednesday_of_every_month.xml'))
    end
  
    it "should set the recurrence rule" do
      @appointment.recurrence_rule.to_hash.should == {:frequency=>:monthly, :interval=>1, :by_day=>[{:day=>:wednesday, :week_number=>2}]}
    end
  end
  
  context "from one_attendee_and_one_reply.xml" do
    before do
      @xml_api_responses_path = File.join(@fixture_path, 'xml_api_responses', 'attendees')
      @appointment = new_appointment_from_xml(File.join(@xml_api_responses_path, 'one_attendee_and_one_reply.xml'))
    end
    
    describe "#replies" do
      it "should load one reply" do
        @appointment.replies.map(&:to_hash).should == [
          {
            :sequence_number=>1, 
            :date=>Time.parse("2014-01-21 09:33:56 -0500"), 
            :email_address=>"mail03@greenviewdata.com", 
            :participation_status=>:tentative, 
            :sent_by=>nil, 
            :recurrence_range_type=>nil, 
            :recurrence_id=>nil, 
            :timezone=>nil, 
            :recurrence_id_utc=>nil
          }
        ]
      end
    end
    
    describe "#attendees" do
      it "should load one attendee" do
        @appointment.attendees.map(&:to_hash).should == [
          {:email_address=>"mail03@greenviewdata.com", :friendly_name=>"Mail03", :rsvp=>1, :role=>"REQ", :participation_status=>:tentative}
        ]
      end
    end
  end
  
  context "from three_attendees_response_1.xml appointment" do
    before do
      @xml_api_responses_path = File.join(@fixture_path, 'xml_api_responses', 'attendees')
      @appointment = new_appointment_from_xml(File.join(@xml_api_responses_path, 'three_attendees_response_1.xml'))
    end
    
    describe "#replies" do
      it "should set two replies" do
        @appointment.replies.count.should == 2
      end
      
      it "should set the reply attributes" do
        @appointment.replies.map(&:to_hash).should == [
          {
            :sequence_number=>1, 
            :date=>Time.parse("2014-01-21 09:33:56 -0500"), 
            :email_address=>"mail03@greenviewdata.com", 
            :participation_status=>:tentative, 
            :sent_by=>nil, 
            :recurrence_range_type=>nil, 
            :recurrence_id=>nil, 
            :timezone=>nil, 
            :recurrence_id_utc=>nil
          }, 
          {
            :sequence_number=>1, 
            :date=>Time.parse("2014-01-21 09:33:56 -0500"), 
            :email_address=>"mail04@greenviewdata.com", 
            :participation_status=>:tentative, 
            :sent_by=>nil, 
            :recurrence_range_type=>nil, 
            :recurrence_id=>nil, 
            :timezone=>nil, 
            :recurrence_id_utc=>nil
          }
        ]
      end
    end
  
    describe "#attendees" do
      it "should make three attendee objects" do
        @appointment.attendees.count.should == 3
      end
    
      it "should set the attendee attributes" do
        @appointment.attendees.map(&:to_hash).should == [
          {:email_address=>"mail03@greenviewdata.com", :friendly_name=>"Mail03", :rsvp=>1, :role=>"REQ", :participation_status=>:tentative}, 
          {:email_address=>"mail04@greenviewdata.com", :friendly_name=>"Test", :rsvp=>1, :role=>"REQ", :participation_status=>:needs_action}, 
          {:email_address=>"mail01b@greenviewdata.com", :friendly_name=>"Test", :rsvp=>1, :role=>"REQ", :participation_status=>:needs_action}
        ]
      end
    end
    
    describe "#alarm" do
      it "should set the alarm" do
        @appointment.alarm.to_hash.should == {
          :duration_negative=>true, :weeks=>nil, :days=>nil, :hours=>nil, :minutes=>5, :seconds=>nil, :when=>:start, :repeat_count=>nil
        }
      end
    end
    
    describe "basic asttributes" do
      it "should set the description" do
        @appointment.description.should == "The following is a new meeting request:\n\nSubject: Test Multiple"
      end
      it "should set the fragment" do
        @appointment.fragment.should == "The following is a new meeting request: Subject: Test Multiple Organizer: \"Test\" <mail03b@greenviewdata.com> Time: Monday, January 20, 2014, 4:30:00 ..."
      end
      it "should set the organizer_email_address" do
        @appointment.organizer_email_address.should == 'mail03b@greenviewdata.com'
      end
      it "should set is_organizer" do
        @appointment.is_organizer.should be_true
      end
      it "should set the id" do
        @appointment.id.should == 261
      end
      it "should set the uid" do
        @appointment.uid.should == '8c62a78e-f48d-4f5e-8cc8-ba5f621d7ae8'
      end
      it "should set the name" do
        @appointment.name.should == 'Test Multiple'
      end
      it "should set the tag_names" do
        pending
      end
      it "should set the attendees_never_notified" do
        pending
      end
      it "should set the revision" do
        @appointment.revision.should == 4425
      end
      it "should set the modified_date" do
        pending
      end
      it "should set the computed_free_busy_status" do
        @appointment.computed_free_busy_status.should == :busy
      end
      it "should set the free_busy_setting" do
        @appointment.free_busy_setting.should == :busy
      end
      it "should set the flags" do
        pending
      end
      it "should set the date" do
        @appointment.date.should == Time.parse("2014-01-21 09:04:13 -0500")
      end
      it "should set the invite_status" do
        @appointment.invite_status.should == :confirmed
      end
      it "should set all_day" do
        @appointment.all_day.should be_false
      end
      it "should set the modified_sequence" do
        pending
      end
      it "should set the visibility" do
        @appointment.visibility.should == :public
      end
      it "should set the location" do
        @appointment.location.should == 'Conference Room'
      end
      it "should set the calendar_id" do
        @appointment.calendar_id.should == 10
      end
      it "should set the component_number" do
        pending
      end
      it "should set changes_not_sent_to_attendees" do
        pending
      end
      it "should set x_uid" do
        pending
      end
      it "should set the size" do
        @appointment.size.should == 0
      end
      it "should set transparency" do
        @appointment.transparency.should == :opaque
      end
      it "should set participation_status" do
        pending
      end
      it "should set next_alarm" do
        pending
      end
    end
  end
end
