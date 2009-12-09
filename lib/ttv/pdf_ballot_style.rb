module TTV
  module PDFBallotStyle
    
    class Translation
      def initialize(filename)
        @filename = filename
        @dirty = false
        begin
          @yaml = YAML::load_file(@filename)
        rescue => ex
          @dirty = true
          @yaml = {}
          @ex = ex
        end
      end
      
      def [](val)
        return @yaml[val] if @yaml.has_key? val
        @dirty = true
        @yaml[val] = "NEEDSTRANSLATION"
        "NEEDSTRANSLATION"
      end

      def save
        File.open( @filename, 'w' ) do |out|
            YAML.dump( @yaml, out )
        end unless !@dirty    
      end
    end

    BALLOT_DIR = "#{RAILS_ROOT}/ballots"
    def self.list
      styles = ['default']
      dir = Dir.open BALLOT_DIR
      dir.each do |f|
        next if f =~ /\..*/ || ! File.directory?("#{BALLOT_DIR}/#{f}") || f == "default"
        styles.push f
      end
      styles
    end
  

    def self.get_file(style, name)
      name = "#{BALLOT_DIR}/#{style}/#{name}"
      begin
        IO.read(name)
      rescue
        Rails.logger.warn "No such file #{name} " 
        "-"
      end
    end

    def self.get_ballot_translation(style, lang)
      return Translation.new("#{BALLOT_DIR}/#{style}/lang/#{lang}/ballot.yml")
    end
    
    def self.get_election_translation(style, lang, election)
    end

    def self.get_ballot_config(style, lang)
      style ||= "default"
      translation = get_ballot_translation(style, lang)
      return TTV::PDFBallot::BallotConfig.new(style, lang, translation) if style == "default"
      name = "#{BALLOT_DIR}/#{style}/ballot_config.rb"
      if File.exists? name
        begin
          load name
          c = TTV::PDFBallot.const_get(style.camelize).const_get("BallotConfig")
          c.new(style, lang)
        rescue
          raise "File #{name} has not defined TTV::PDFBallot::#{style.camelize}::BallotConfig "
        end
      else
        raise "Illegal ballot style: file #{name} does not exist."
      end
    end

  end
end