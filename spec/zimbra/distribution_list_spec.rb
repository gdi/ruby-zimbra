require File.join(File.dirname(__FILE__),'../spec_helper')

describe Zimbra::DistributionList do
  describe 'members' do
    it 'should be an empty array by default' do
      dl = Zimbra::DistributionList.new
      dl.members.should be_empty
    end
    it 'should be assigned an array of email addresses' do
      dl = Zimbra::DistributionList.new(:members => ['a@b.com','b@c.com'])
      dl.members.should == ['a@b.com','b@c.com']
      dl.members = ['c@d.com']
      dl.members.should == ['c@d.com']
    end
  end
  describe 'new_members' do
    it 'should only list members that were added' do
      dl = Zimbra::DistributionList.new(:members => ['a@b.com','b@c.com'])
      dl.members << 'd@e.com'
      dl.new_members.should == ['d@e.com']
    end
    it 'should list all members added to a list that originally had no members' do
      dl = Zimbra::DistributionList.new
      dl.members << 'a@b.com' << 'b@c.com'
      dl.new_members.should == ['a@b.com','b@c.com']
    end
    it 'should not list deleted members' do
      dl = Zimbra::DistributionList.new(:members => ['a@b.com','b@c.com'])
      dl.members.shift
      dl.members << 'c@d.com'
      dl.new_members.should == ['c@d.com']
    end
  end
  describe 'removed_members' do
    it 'should only list members that were removed' do
      dl = Zimbra::DistributionList.new(:members => ['a@b.com','b@c.com'])
      dl.members.shift
      dl.removed_members.should == ['a@b.com']
    end
    it 'should not list added members' do
      dl = Zimbra::DistributionList.new(:members => ['a@b.com','b@c.com'])
      dl.members.shift
      dl.members << 'c@d.com'
      dl.removed_members.should == ['a@b.com']
    end
    it 'should always report empty if a record was created without any members' do
      dl = Zimbra::DistributionList.new()
      dl.members = ['a@b.com','b@c.com']
      dl.members.shift
      dl.members << 'c@d.com'
      dl.removed_members.should be_empty
    end
  end
end
