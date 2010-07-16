module TTV

  class Alert
    attr_accessor :type, :objects, :message, :options, :choice, :default_option 
    
    def initialize(options = {})
      @type = options[:type]
      @objects = options[:objects]
      @message = options[:message]
      @message ||= "Alert message not defined"
      @options = options[:options]
      @choice = options[:choice]
      @default_option = options[:default_option]
    end
    
    def to_s
      @message
    end
  end
  
end