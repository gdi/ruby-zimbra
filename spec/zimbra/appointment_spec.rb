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
      Zimbra::Appointment.parse_zimbra_attributes(@appointment_hash).should == {:id=>518, :uid=>"1c71d474-5c1f-4048-84e3-9725c0825a44", :revision=>27656, :calendar_id=>10, :size=>0, :replies=>nil, :invites=>{:attributes=>{:id=>517, :seq=>4, :compNum=>0, :type=>"appt"}, :tz=>{:attributes=>{:id=>"America/New_York", :stdoff=>-300, :stdname=>"EST", :dayoff=>-240, :dayname=>"EDT"}, :standard=>{:attributes=>{:wkday=>1, :min=>0, :sec=>0, :mon=>11, :hour=>2, :week=>1}}, :daylight=>{:attributes=>{:wkday=>1, :min=>0, :sec=>0, :mon=>3, :hour=>2, :week=>2}}}, :comp=>{:attributes=>{:uid=>"1c71d474-5c1f-4048-84e3-9725c0825a44", :d=>1387571704000, :status=>"CONF", :noBlob=>1, :ciFolder=>10, :isOrg=>1, :class=>"PUB", :loc=>"", :compNum=>0, :apptId=>518, :url=>"", :fb=>"B", :calItemId=>518, :x_uid=>"1c71d474-5c1f-4048-84e3-9725c0825a44", :name=>"Test2222", :seq=>4, :rsvp=>0, :fba=>"B", :method=>"PUBLISH", :transp=>"O"}, :alarm=>{:attributes=>{:action=>"DISPLAY"}, :trigger=>{:rel=>{:attributes=>{:neg=>1, :m=>5, :related=>"START"}}}, :desc=>{}}, :or=>{:attributes=>{:d=>"Mail03", :a=>"mail03@greenviewdata.com", :url=>"mail03@greenviewdata.com"}}, :recur=>{:add=>{:rule=>{:attributes=>{:freq=>"MON"}, :interval=>{:attributes=>{:ival=>1}}, :byday=>{:wkday=>{:attributes=>{:ordwk=>2, :day=>"WE"}}}}}}, :s=>{:attributes=>{:u=>1355340600000, :d=>"20121212T143000", :tz=>"America/New_York"}}, :e=>{:attributes=>{:u=>1355344200000, :d=>"20121212T153000", :tz=>"America/New_York"}}}}, :date=>1387571704000}
    end
  end
  
  describe "#recurrence_rule" do
    before do
      @xml_api_responses_path = File.join(@fixture_path, 'xml_api_responses', 'recur_rules')
      @appointment = new_appointment_from_xml(File.join(@xml_api_responses_path, 'second_wednesday_of_every_month.xml'))
    end
  
    it "should set the recurrence rule" do
      @appointment.invites.first.recurrence_rule.to_hash.should == {:frequency=>:monthly, :interval=>1, :by_day=>[{:day=>:wednesday, :week_number=>2}]}
    end
  end
  
  context "from recurring_with_exceptions.xml" do
    before do
      @xml_api_responses_path = File.join(@fixture_path, 'xml_api_responses', 'multiple_invites')
      @appointment = new_appointment_from_xml(File.join(@xml_api_responses_path, 'recurring_with_exceptions.xml'))
    end
    
    describe "#invites" do
      it "should initialize 5 invites" do
        @appointment.invites.count.should == 5
      end
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
        @appointment.invites.first.attendees.map(&:to_hash).should == [
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
        @appointment.invites.first.attendees.count.should == 3
      end
    
      it "should set the attendee attributes" do
        @appointment.invites.first.attendees.map(&:to_hash).should == [
          {:email_address=>"mail03@greenviewdata.com", :friendly_name=>"Mail03", :rsvp=>1, :role=>"REQ", :participation_status=>:tentative}, 
          {:email_address=>"mail04@greenviewdata.com", :friendly_name=>"Test", :rsvp=>1, :role=>"REQ", :participation_status=>:needs_action}, 
          {:email_address=>"mail01b@greenviewdata.com", :friendly_name=>"Test", :rsvp=>1, :role=>"REQ", :participation_status=>:needs_action}
        ]
      end
    end
    
    describe "#alarm" do
      it "should set the alarm" do
        @appointment.invites.first.alarm.to_hash.should == {
          :duration_negative=>true, :weeks=>nil, :days=>nil, :hours=>nil, :minutes=>5, :seconds=>nil, :when=>:start, :repeat_count=>nil
        }
      end
    end
    
    describe "basic asttributes" do
      it "should set the id" do
        @appointment.id.should == 261
      end
      it "should set the uid" do
        @appointment.uid.should == '8c62a78e-f48d-4f5e-8cc8-ba5f621d7ae8'
      end
      it "should set the revision" do
        @appointment.revision.should == 4425
      end
      it "should set the date" do
        @appointment.date.should == Time.parse("2014-01-21 09:04:13 -0500")
      end
      it "should set the calendar_id" do
        @appointment.calendar_id.should == 10
      end
      it "should set the size" do
        @appointment.size.should == 0
      end
    end
  end
end
