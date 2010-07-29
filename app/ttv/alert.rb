module TTV

  class Alert
    attr_accessor :type, :objects, :message, :options, :choice, :default_option 
    
    #
    # Initialize an alert object.
    #<tt>options</tt>::hash of various alert objects
    #<tt>type</tt>::symbol representing what type of alert this is
    #<tt>objects</tt>::array of objects this alert is referencing, may perform operations on
    #<tt>message</tt>::textual message explaining alert to user
    #<tt>options</tt>::hash with symbol key and string to display to user as value
    #<tt>choice</tt>::symbol representing a user's option choice
    #<tt>default_option</tt>::symbol representing the default option for form generation  
    #
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