module Zimbra
  class ACL
    class TargetObjectNotFound < StandardError; end

    TARGET_CLASSES = [Zimbra::Domain, Zimbra::DistributionList, Zimbra::Cos, Zimbra::Account]
    TARGET_MAPPINGS = TARGET_CLASSES.inject({}) do |hsh, klass|
      hsh[klass.acl_name] = klass
      hsh[klass] = klass.acl_name
      hsh
    end

    class << self
      def delete_all(xmldoc)
        A.inject(xmldoc, 'zimbraACE', '', 'c' => '1')
      end

      def read(node)
        list = A.read(node, 'zimbraACE')
        return nil if list.nil?
        list = [list] unless list.respond_to?(:map)
        acls = list.map do |ace|
          from_s(ace)
        end
      end

      def from_zimbra(node)
        from_s(node.to_s)
      end

      def from_s(value)
        target_id, target_name, name = value.split(' ')
        target_class = TARGET_MAPPINGS[target_name]
        raise TargetObjectNotFound, "Target object not found for acl #{acl_string}" if target_class.nil?
        new(:target_id => target_id, :target_class => target_class, :name => name)
      end
    end

    attr_accessor :target_id, :target_class, :name

    def initialize(options = {})
      if options[:target]
        self.target_id = options[:target].id
        self.target_class = options[:target].class
      else
        self.target_id = options[:target_id]
        self.target_class = options[:target_class]
      end
      self.name = options[:name]
    end

    def to_zimbra_acl_value
      id = target_id
      type = target_class.acl_name
      "#{id} #{type} #{name}"
    end

    def apply(xmldoc)
      A.inject(xmldoc, 'zimbraACE', to_zimbra_acl_value, 'c' => '1')
    end
  end
end
