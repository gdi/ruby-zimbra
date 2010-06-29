require File.join(File.dirname(__FILE__),'../spec_helper')

describe Zimbra::ACL do
  describe 'to_zimbra_acl_value' do
    it 'should generate the string to be placed in an acl element' do
      domain = Zimbra::Domain.new('abc123','example.com')
      acl = Zimbra::ACL.new(:target => domain, :name => 'zimbraAdminCosRights')
      acl.to_zimbra_acl_value.should == "abc123 domain zimbraAdminCosRights"
    end
  end
end
