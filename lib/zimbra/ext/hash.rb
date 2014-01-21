module Zimbra
  class Hash < ::Hash
    # Thanks to https://gist.github.com/dimus/335286 for this code
    
    class << self
      def symbolize_keys(hash, recursive = false)
        hash.keys.each do |key|
          value = hash.delete(key)
          key = key.respond_to?(:to_sym) ? key.to_sym : key
          hash[key] = (recursive && value.is_a?(::Hash)) ? symbolize_keys(value.dup, recursive) : value
        end
        hash
      end
      
      def from_xml(xml_io) 
        begin
          result = Nokogiri::XML(xml_io)
          return { result.root.name.to_sym => xml_node_to_hash(result.root)} 
        rescue Exception => e
          # raise your custom exception here
        end
      end 
 
      def xml_node_to_hash(node) 
        # If we are at the root of the document, start the hash 
        if node.element?
          result_hash = {}
          if node.attributes != {}
            result_hash[:attributes] = {}
            node.attributes.keys.each do |key|
              result_hash[:attributes][node.attributes[key].name.to_sym] = prepare(node.attributes[key].value)
            end
          end
          if node.children.size > 0
            node.children.each do |child| 
              result = xml_node_to_hash(child) 
 
              if child.name == "text"
                unless child.next_sibling || child.previous_sibling
                  if result_hash[:attributes]
                    result_hash['value'] = prepare(result)
                    return result_hash
                  else 
                    return prepare(result)
                  end 
                end
              elsif result_hash[child.name.to_sym]
                if result_hash[child.name.to_sym].is_a?(Object::Array)
                  result_hash[child.name.to_sym] << prepare(result)
                else
                  result_hash[child.name.to_sym] = [result_hash[child.name.to_sym]] << prepare(result)
                end
              else 
                result_hash[child.name.to_sym] = prepare(result)
              end
            end
 
            return result_hash 
          else 
            return result_hash
          end 
        else 
          return prepare(node.content.to_s) 
        end 
      end          
 
      def prepare(data)
        (data.class == String && data.to_i.to_s == data) ? data.to_i : data
      end
    end
  end
end
