# 
# Support for standard TTV Data Layer Files
#
module TTV
  class DataLayer
     def self.audit_header_dummy
        @audit_header_hash = {
            "file_id" => "9F023408009B11DF924800163E3DE33F",
            "create_date" => DateTime.now,
            "type" => "jurisdiction_slate",
            "operator" => "Pito Salas",
            "hardware" => "TTV Tabulator TAB02",
            "software" => "TTV Election Management System 0.1 JAN-1-2010"
        }
        @audit_header_hash
      end
  end
end