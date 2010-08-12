module TTV
  module Translate
    
    # from http://ruby.geraldbauer.ca/google-translation-api.html
    # for a list of languages, see http://code.google.com/apis/ajaxlanguage/documentation/reference.html#LangNameArray
    def self.translate(text, from, to)
      raise "#{text} is not a string, cannot translate" unless text.class == String
      if text.count("\n") > 0 # line splits, and google chews them up, must separate manually
        puts "translating #{text.length} '#{text}'"
        translation = ""
        text.split("\n").each do |t|
          translation += self.translate(t, from, to) + "\n"
        end
        puts "translated ", translation
        return translation
      end
      
      return "" unless text =~ /\w+/

      base = 'http://ajax.googleapis.com/ajax/services/language/translate' 

      # assemble query params
      params = {
        :langpair => "#{from}|#{to}", 
        :q => text,
        :v => 1.0  
      }

      query = params.map{ |k,v| "#{k}=#{CGI.escape(v.to_s)}" }.join('&')

      response = Net::HTTP.get_response( URI.parse( "#{base}?#{query}" ) )
      json = ActiveSupport::JSON.decode( response.body )

      if json['responseStatus'] == 200
        json['responseData']['translatedText']
      else
        raise StandardError, response['responseDetails']
      end
    end

    def self.translate_file(src_path, dest_path, from, to)
      if src_path =~ /.yml$/
        yaml = YAML::load_file(src_path)
        translation = {}
        yaml.each do |a, b|
          translation[a] = self.translate(b, from, to)
        end
        File.open dest_path, 'w' do |out|
          YAML.dump(translation, out )
        end
      else
        text = IO.read src_path
        translation = self.translate text, from, to
        out = File.open dest_path, "w" do |f|
          f.write translation
        end
      end
    end
    
    # use from a command line to translate ballot directories
    # load "lib/ttv/translate.rb"
    # TTV::Translate.translate_directory("ballots/default/lang/en", "ballots/default/lang/zh", "en", "zh")
    def self.translate_directory(src_dir, dest_dir, from, to)
      Dir.foreach src_dir do |f|
        next unless f =~ /txt|yml/
        self.translate_file "#{src_dir}/#{f}", "#{dest_dir}/#{f}", from, to
      end
    end
    
    def self.human_language(code)
      case code
      when 'en'; "English"
      when 'es'; "Spanish"
      when 'zh'; "Chinese"
      else code
      end
    end
    
    class YamlTranslation
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
      
      def dirty?
        @dirty
      end

    end

    # for english (default_language)
    #   recreate the file every time
    # for other languages
    #   recreate the file if needed
    class ElectionTranslation

      DEFAULT_LANGUAGE = 'en'
      
      def initialize(election, lang)
        @election = election
        @filename = election.translation_path(lang)
        @lang = lang
        @dirty = false
        begin
          @yaml = YAML::load_file(@filename)
        rescue => ex
          @yaml = {}
          @ex = ex
        end
      end
      
      def get(object, property)
        key = "#{object.class.name}-#{object.object_id}.#{property}"
        return @yaml[key] if @yaml.has_key? key
        if @lang == DEFAULT_LANGUAGE
          @yaml[key] = object.send property
          @yaml[key]
        else
          return @yaml[key] if @yaml.has_key? key
          @dirty = true
          @yaml[key] = "NEEDSTRANSLATION"
          "NEEDSTRANSLATION"
        end
      end

      def dirty?
         @dirty
       end

# look at this for solutions
# http://www.artweb-design.de/2008/7/18/the-ruby-on-rails-i18n-core-api    
# http://guides.rubyonrails.org/i18n.html
      def ordinalize(n)
        n.ordinalize # FIXME, need international support, might come with rails for free in future releases
      end
      
      def strftime(date, format)
        I18n.localize date, :locale => @lang, :format => format
        # date.strftime(format)
      end
      
      def save
        File.open( @filename, 'w' ) do |out|
          YAML.dump( @yaml, out )
        end
      end

    end
        
  end
end
