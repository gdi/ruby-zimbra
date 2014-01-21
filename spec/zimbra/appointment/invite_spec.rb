require 'spec_helper'

describe Zimbra::Appointment::Invite do
  before do
    @xml_api_responses_path = File.join(@fixture_path, 'xml_api_responses', 'multiple_invites')
    @appointment = new_appointment_from_xml(File.join(@xml_api_responses_path, 'recurring_with_exceptions.xml'))
  end
  
  describe "#exception" do
    before do
      @invite = @appointment.invites.find { |i| i.id == 549 }
    end
    it "should be set if this invite is an exception" do
      @invite.exception.to_hash.should == {:recurrence_id=>"20140131T090000", :timezone=>"America/New_York", :range_type=>nil}
    end
  end
  
  describe "basic attributes" do
    it "should set the description" do
      @appointment.invites.first.description.should == "This is a recurring series"
    end
    it "should set the fragment" do
      @appointment.invites.first.fragment.should == "This is a recurring series"
    end
    it "should set the organizer_email_address" do
      @appointment.invites.first.organizer_email_address.should == 'mail03@greenviewdata.com'
    end
    it "should set is_organizer" do
      @appointment.invites.first.is_organizer.should be_true
    end
    it "should set the name" do
      @appointment.invites.first.name.should == 'fdsafdsafdsafdsafdsafdsa'
    end
    it "should set the computed_free_busy_status" do
      @appointment.invites.first.computed_free_busy_status.should == :busy
    end
    it "should set the free_busy_setting" do
      @appointment.invites.first.free_busy_setting.should == :busy
    end
    it "should set the invite_status" do
      @appointment.invites.first.invite_status.should == :confirmed
    end
    it "should set all_day" do
      @appointment.invites.first.all_day.should be_false
    end
    it "should set the visibility" do
      @appointment.invites.first.visibility.should == :public
    end
    it "should set the location" do
      @appointment.invites.first.location.should == 'Conference Room'
    end
    it "should set transparency" do
      @appointment.invites.first.transparency.should == :opaque
    end
    it "should set start_date_time" do
      @appointment.invites.first.start_date_time.should == Time.parse("2013-12-09 09:00:00 -0500")
    end
    it "should set end_date_time" do
      @appointment.invites.first.end_date_time.should == Time.parse("2013-12-09 09:30:00 -0500")
    end
  end
end