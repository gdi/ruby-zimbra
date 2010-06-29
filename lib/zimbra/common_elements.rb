module Zimbra
  class A
    class << self
      def inject(xmldoc, name, value, extra_attributes = {})
        new(name, value, extra_attributes).inject(xmldoc)
      end
      
      def read(xmldoc, name)
        nodes = (xmldoc/"//n2:a[@n='#{name}']")
        return nil if nodes.nil?
        if nodes.size > 1
          nodes.map { |n| from_node(n, name).value }
        else
          from_node(nodes, name).value
        end
      end

      def from_node(node, name)
        new(name, node.to_s)
      end
    end

    attr_accessor :name, :value, :extra_attributes

    def initialize(name, value, extra_attributes = {})
      self.name = name
      self.value = value
      self.extra_attributes = extra_attributes || {}
    end

    def inject(xmldoc)
      xmldoc.add 'a', value do |a|
        a.set_attr 'n', name
        extra_attributes.each do |eaname, eavalue|
          a.set_attr eaname, eavalue
        end
      end
    end
  end

  class Boolean
    def self.read(value)
      case value
      when 'TRUE' then true
      when 'FALSE' then false
      when true then true
      else false
      end
    end
  end
end
