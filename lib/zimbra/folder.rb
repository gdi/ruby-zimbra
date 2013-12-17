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
    
    ATTRS = [
      :id, :uuid, :name, :view, :absolute_folder_path,
      :parent_folder_id, :parent_folder_uuid,
      :non_folder_item_count, :non_folder_item_size,
      :revision, :imap_next_uid, :imap_modified_sequence, :modified_sequence, :activesync_disabled,
      :modified_date
    ] unless const_defined?(:ATTRS)
    
    attr_accessor *ATTRS
    
    def initialize(args = {})
      self.attributes = args
    end
    
    def attributes=(args = {})
      ATTRS.each do |attr_name|
        self.send(:"#{attr_name}=", (args[attr_name] || args[attr_name.to_s])) if args.has_key?(attr_name) || args.has_key?(attr_name.to_s)
      end
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
      ATTRIBUTE_MAPPING = {
        :id => :id, 
        :uuid => :uuid, 
        :name => :name, 
        :view => :view, 
        :absFolderPath => :absolute_folder_path, 
        :l => :parent_folder_id, 
        :luuid => :parent_folder_uuid, 
        :n => :non_folder_item_count, 
        :s => :non_folder_item_size, 
        :rev => :revision, 
        :i4next => :imap_next_uid, 
        :i4ms => :imap_modified_sequence, 
        :ms => :modified_sequence, 
        :activesyncdisabled => :activesync_disabled, 
        :md => :modified_date
      }
      
      class << self
        def get_all_response(response)
          (response/"//n2:folder").map do |node|
            folder_response(node)
          end
        end

        def folder_response(node)
          folder_attributes = ATTRIBUTE_MAPPING.inject({}) do |attrs, (xml_name, attr_name)|
            attrs[attr_name] = (node/"@#{xml_name}").to_s
            attrs
          end
          Zimbra::Folder.new(folder_attributes) 
        end
      end
    end
  end
end
