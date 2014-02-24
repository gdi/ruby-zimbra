module Zimbra
  class Calendar < Folder
    class << self
      def all
        CalendarService.find_all_by_view('appointment').reject { |c| c.view.nil? || c.view != 'appointment' }
      end
    end
    
    def appointments
      Zimbra::Appointment.find_all_by_calendar_id(id)
    end
  end
  
  class CalendarService < FolderService
    def parse_xml_responses(xml)
      Parser.get_all_response(xml)
    end
    
    class Parser < Zimbra::FolderService::Parser
      class << self
        def initialize_from_attributes(folder_attributes)
          Zimbra::Calendar.new(folder_attributes)
        end
      end
    end
  end
end
