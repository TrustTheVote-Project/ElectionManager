module TTV
  module Prawn
    
    class Reader

      attr_accessor :pdf_hash
      attr_accessor :producer, :creator, :title, :text
      
      def initialize(pdf)
        raise ArgumentError, "pdf argument is not a Prawn::Document instance" unless pdf.is_a? ::Prawn::Document
        @pdf_contents = pdf.render
        output = StringIO.new(@pdf_contents, 'r+')
        @hash = PDF::Hash.new(output)
        producer = @hash.values.map {|obj| obj[:Producer] if obj.is_a?(Hash) && obj[:Producer]}.first
        creator = @hash.values.map {|obj| obj[:Creator] if obj.is_a?(Hash) && obj[:Creator] }.first
        title = @hash.values.map {|obj| obj[:Title] if obj.is_a?(Hash) && obj[:Title] }.first
        text = @hash.values.find {|obj|obj.unfiltered_data if obj.is_a?(PDF::Reader::Stream) }
      end

      def render_file(filename)
        Kernel.const_defined?("Encoding") ? mode = "wb:ASCII-8BIT" : mode = "wb"
        File.open(filename,mode) { |f| f << @pdf_contents }
      end
    
      def catalog
       @catalog || @hash.values.find {|obj| obj.is_a?(Hash) && obj[:Type] == :Catalog}
      end

      def pages_ref
        @pages_ref || ref_to_str(catalog[:Pages])
      end

      def pages
        @pages || obj(catalog[:Pages])
      end
      
      def page(page_num)
        obj(pages[:Kids][page_num - 1])
      end
      
      def fields
        acroform = obj(catalog[:AcroForm] )
        @fields || acroform[:Fields].map do |field_ref|
          obj(field_ref)
        end
      end
      
      def page_annotations(page_num)
        annot_refs = obj(page(page_num)[:Annots])
        annot_refs.map{ |ref|  obj(ref) }
      end
      
      def obj(ref)
        ref_id = case ref.class.name
                 when 'PDF::Reader::Reference'
                   ref.id
                 when 'Fixnum'
                   ref
                 else
                   raise ArgumentError, "reference must be an Fixnum or PDF::Reader::Reference"
                 end
        
        @hash.each do |ref, obj|
          return obj if ref.id == ref_id
        end
        
      end
      
      def ref_to_str(ref)
        # raise ArgumentError, "reference must be a PDF::Reader::Reference" unless ref.is_a? PDF::Reader::Reference 
        if ref.is_a? Array
          ref.inject("[") do |str, pdf_ref|
            str << (str == "[" ? "" : ", ") << ref_to_str(pdf_ref)

          end << "]"
        elsif ref.is_a? PDF::Reader::Reference 
          "#{ref.id} #{ref.gen} R"
        else
          raise ArgumentError, "reference must be an Array or PDF::Reader::Reference"
        end

      end
    end
    
  end
end
