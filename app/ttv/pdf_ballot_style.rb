require 'ballots/default/ballot_config.rb'
require 'ballots/aiga/ballot_config.rb'
require 'ballots/nh/ballot_config.rb'

class PDFBallotStyle

  BALLOT_DIR = "#{RAILS_ROOT}/app/ballots"

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
    puts BALLOT_DIR
    return TTV::Translate::YamlTranslation.new("#{BALLOT_DIR}/#{style}/lang/#{lang}/ballot.yml")
  end

  def self.get_ballot_config(style, lang, election, scanner, instruction_text, state_seal, state_signature)
    begin
      ballot_defining_module = style.camelize + "Ballot"
      mod = ballot_defining_module.constantize
      mod::BallotConfig.new(style, lang, election, scanner, instruction_text, state_seal, state_signature)
    rescue => ex
      Rails.logger.error(ex)
      raise "Unknown Ballot Style: #{style}"
    end
  end
end

