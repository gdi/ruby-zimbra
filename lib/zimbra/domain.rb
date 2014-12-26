module Zimbra
  class Domain
    class << self
      def all
        DomainService.all
      end

      def find_by_id(id)
        DomainService.get_by_id(id)
      end

      def find_by_name(name)
        DomainService.get_by_name(name)
      end

      def create(name, attributes = {})
        DomainService.create(name, attributes)
      end

      def acl_name
        'domain'
      end
    end

    attr_accessor :id, :name, :acls

    def initialize(id, name, acls = [])
      self.id = id
      self.name = name
      self.acls = acls || []
    end

    def save
      DomainService.modify(self)
    end

    def delete
      DomainService.delete(self)
    end
  end

  class DomainService < HandsoapService
    def all
      xml = invoke("n2:GetAllDomainsRequest")
      Parser.get_all_response(xml)
    end

    def create(name, attributes = {})
      xml = invoke("n2:CreateDomainRequest") do |message|
        Builder.create(message, name, attributes)
      end
      Parser.domain_response(xml/"//n2:domain")
    end

    def get_by_id(id)
      xml = invoke("n2:GetDomainRequest") do |message|
        Builder.get_by_id(message, id)
      end
      return nil if soap_fault_not_found?
      Parser.domain_response(xml/"//n2:domain")
    end

    def get_by_name(name)
      xml = invoke("n2:GetDomainRequest") do |message|
        Builder.get_by_name(message, name)
      end
      return nil if soap_fault_not_found?
      Parser.domain_response(xml/"//n2:domain")
    end

    def modify(domain)
      xml = invoke("n2:ModifyDomainRequest") do |message|
        Builder.modify(message, domain)
      end
      Parser.domain_response(xml/'//n2:domain')
    end

    def delete(dist)
      xml = invoke("n2:DeleteDomainRequest") do |message|
        Builder.delete(message, dist.id)
      end
    end

    class Builder
      class << self
        def create(message, name, attributes = {})
          message.add 'name', name
          attributes.each do |k,v|
            A.inject(message, k, v)
          end
        end

        def get_by_id(message, id)
          message.add 'domain', id do |c|
            c.set_attr 'by', 'id'
          end
        end

        def get_by_name(message, name)
          message.add 'domain', name do |c|
            c.set_attr 'by', 'name'
          end
        end

        def modify(message, domain)
          message.add 'id', domain.id
          modify_attributes(message, domain)
        end
        def modify_attributes(message, domain)
          if domain.acls.empty?
            ACL.delete_all(message)
          else
            domain.acls.each do |acl|
              acl.apply(message)
            end
          end
        end

        def delete(message, id)
          message.add 'id', id
        end
      end
    end
    class Parser
      class << self
        def get_all_response(response)
          (response/"//n2:domain").map do |node|
            domain_response(node)
          end
        end

        def domain_response(node)
          id = (node/'@id').to_s
          name = (node/'@name').to_s
          acls = Zimbra::ACL.read(node)
          Zimbra::Domain.new(id, name, acls)
        end
      end
    end
  end
end
