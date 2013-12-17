# http://files.zimbra.com/docs/soap_api/8.0.4/soap-docs-804/api-reference/zimbraMail/GetFolder.html
module Zimbra
  class Folder
    class << self
      def all
        FolderService.all
      end

      def find_all_by_view(view)
        FolderService.find_all_by_view(view)
      end
    end

    attr_accessor :id, :uuid, :name, :absolute_folder_path
    
    def initialize(args = {})
      self.id = args[:id]
      self.uuid = args[:uuid]
      self.name = args[:name]
      self.absolute_folder_path = args[:absolute_folder_path]
    end
  end
  
  class FolderService < HandsoapAccountService
    def all
      xml = invoke("n2:GetFolderRequest")
      Parser.get_all_response(xml)
    end
    
    def find_all_by_view(view)
      xml = invoke("n2:GetFolderRequest") do |message|
        Builder.find_all_by_view(message, view)
      end
      Parser.get_all_response(xml)
    end

    class Builder
      class << self
        def find_all_by_view(message, view)
          message.set_attr 'view', view
        end
      end
    end
    
    class Parser
      class << self
        def get_all_response(response)
          (response/"//n2:folder").map do |node|
            folder_response(node)
          end
        end

        def folder_response(node)
          id = (node/'@id').to_s
          uuid = (node/'@uuid').to_s
          name = (node/'@name').to_s
          absolute_folder_path = (node/'@absFolderPath').to_s
          Zimbra::Folder.new(id: id, uuid: uuid, name: name, absolute_folder_path: absolute_folder_path) 
        end
      end
    end
  end
end
