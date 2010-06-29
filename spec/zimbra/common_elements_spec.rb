require File.join(File.dirname(__FILE__),'../spec_helper')

describe Zimbra::A do
  describe 'read' do
    it 'should read a single attribute and return its value' do
      doc = zimbra_soap_doc(<<XML)
<n2:item>
  <n2:a n="foobar">44</n2:a>
  <n2:a n="testAttr">23</n2:a>
</n2:item>
XML
      a = Zimbra::A.read(doc, 'testAttr')
      a.should =~ /23/
      a.should_not =~ /44/
    end
    it 'should read multiple attributes and return an array of values' do
      thritytwofootsteps = zimbra_soap_doc(<<XML)
<n2:item>
<n2:a n="foobar">44</n2:a>
<n2:a n="testAttr">28</n2:a>
<n2:a n="testAttr">29</n2:a>
<n2:a n="testAttr">30</n2:a>
<n2:a n="testAttr">31</n2:a>
</n2:item>
XML
      attrs = Zimbra::A.read(thritytwofootsteps, 'testAttr')
      attrs.should_not be_empty
      attrs = attrs.join('')
      attrs.should =~ /28.*29.*30.*31/
      attrs.should_not =~ /44/
    end
  end
end
