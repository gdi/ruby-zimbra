module Zimbra
  class Cos
    class << self
      def find_by_id(id)
        CosService.get_by_id(id)
      end

      def find_by_name(name)
        CosService.get_by_name(name)
      end

      def create(name)
        CosService.create(name)
      end

      def acl_name
        'cos'
      end
    end

    attr_accessor :id, :name, :acls

    def initialize(id, name, acls = [])
      self.id = id
      self.name = name
      self.acls = acls || []
    end

    def save
      CosService.modify(self)
    end
    
    def delete
      CosService.delete(self)
    end
  end

  class CosService < HandsoapService
    def get_by_id(id)
      response = invoke("n2:GetCosRequest") do |message|
        Builder.get_by_id(message, id)
      end
      return nil if soap_fault_not_found?
      Parser.cos_response(response/"//n2:cos")
    end 

    def get_by_name(name)
      response = invoke("n2:GetCosRequest") do |message|
        Builder.get_by_name(message, name)
      end
      return nil if soap_fault_not_found?
      Parser.cos_response(response/"//n2:cos")
    end 

    def create(name)
      response = invoke("n2:CreateCosRequest") do |message|
        Builder.create(message, name)
      end
      Parser.cos_response(response/"//n2:cos")
    end

    def modify(cos)
      xml = invoke("n2:ModifyCosRequest") do |message|
        Builder.modify(message, cos)
      end
      Parser.cos_response(xml/'//n2:cos')
    end 

    def delete(cos)
      xml = invoke("n2:DeleteCosRequest") do |message|
        Builder.delete(message, cos)
      end
    end

    class Builder
      class << self
        def get_by_id(message, id)
          message.add 'cos', id do |c|
            c.set_attr 'by', 'id'
          end
        end

        def get_by_name(message, name)
          message.add 'cos', name do |c|
            c.set_attr "by", 'name'
          end
        end

        def create(message, name)
          message.add 'name', name
        end

        def modify(message, cos)
          message.add 'id', cos.id
          modify_attributes(message, cos)
        end
        def modify_attributes(message, cos)
          if cos.acls.empty?
            ACL.delete_all(message)
          else
            cos.acls.each do |acl|
              acl.apply(message)
            end
          end
        end

        def delete(message, cos)
          message.add 'id', cos.id
        end
      end
    end

    class Parser
      class << self
        def cos_response(node)
          id = (node/'@id').to_s
          name = (node/'@name').to_s
          acls = Zimbra::ACL.read(node)
          Zimbra::Cos.new(id, name, acls) 
        end
      end
    end
  end
end
