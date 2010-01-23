require "ballots/default/ballot_config.rb"

module TTV
  module PDFBallotStyle

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

    def self.get_election_translation(election, lang)
      return TTV::Translate::ElectionTranslation.new(election, lang)
    end
    
    def self.get_ballot_translation(style, lang)
      return TTV::Translate::YamlTranslation.new("#{BALLOT_DIR}/#{style}/lang/#{lang}/ballot.yml")
    end

    def self.get_ballot_config(style, lang, election)
      name = "#{BALLOT_DIR}/#{style}/ballot_config.rb"
      if File.exists? name
        begin
          require name
          c = TTV::PDFBallot.const_get(style.camelize).const_get("BallotConfig")
          c.new(style, lang, election)
        rescue => ex
          Rails.logger.error(ex)
          raise ex.to_s + ".  Have you defined  TTV::PDFBallot::#{style.camelize}::BallotConfig inside #{name}"
        end
      else
        raise "Illegal ballot style: file #{name} does not exist."
      end
    end
    
  end
end