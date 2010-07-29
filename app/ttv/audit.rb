require 'yaml'

module TTV
  # Import Yaml-based election using standard formats, and convert as needed to Election and related objects.
  class Audit
    attr_reader :hash, :alerts, :ready_for_import

    # <tt>hash::</tt> Hash containing ElectionManager data.
    def initialize(hash, alerts, current_jurisdiction)
      @hash = hash
      @alerts = alerts
      @jurisdiction = current_jurisdiction
      @ready_for_import = false
      
      apply_alerts
      audit
      
      if @alerts.size == 0
        @ready_for_import = true
      end
    end
    
    # Applies transforms to @hash based on alerts
    def apply_alerts
      @alerts.each{ |alert|
        if alert.type == :no_jurisdiction && alert.choice == :use_current
          @hash["ballot_info"]["jurisdiction_display_name"] = @jurisdiction.display_name
          @alerts.delete(alert)
        end
      }
    end

    # Audits @hash (without touching it), producing more @alerts
    def audit
      if not @hash["ballot_info"]["jurisdiction_display_name"]
        if @jurisdiction
          @alerts << TTV::Alert.new({:message => "No jurisdiction name specified.", :type => :no_jurisdiction, :options => 
            {:use_current => "Use current jurisdiction #{@jurisdiction.display_name}", :abort => "Abort import"}, :default_option => :use_current})
        else
          raise "No current jurisdiction and no jurisdiction in YAML file. Choose a jurisdiction before importing."
        end
      end
    end
  end
end