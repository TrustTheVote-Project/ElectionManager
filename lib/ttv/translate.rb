module TTV
  module Translate
    
    # from http://ruby.geraldbauer.ca/google-translation-api.html
    # for a list of languages, see http://code.google.com/apis/ajaxlanguage/documentation/reference.html#LangNameArray
    def self.translate(text, from, to)
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
  end
end