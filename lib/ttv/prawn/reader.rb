module TTV
  module Prawn
    
    class Reader

      attr_accessor :pdf_hash, :pdf_contents
      attr_accessor :producer, :creator, :title, :text
      
      def initialize(pdf)
        raise ArgumentError, "pdf argument is not a Prawn::Document instance" unless pdf.is_a? ::Prawn::Document
        @pdf_contents = pdf.render
        @output = StringIO.new(@pdf_contents, 'r+')
        @hash = PDF::Hash.new(@output)
        # Debugger for PDFMalformedException, narrow downs problem        
        # @hash.each do |ref1, ref2 |
        #   puts "READER: ref1 = #{ref1.id.inspect}"
        #   puts "READER: ref2 = #{ref2.inspect}"
        # end
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
      
      def page_contents(page_num)
        # Contents is a PDF::Reader::Stream
        obj(page(page_num)[:Contents]).data
      end

      def form?
        !!catalog[:AcroForm] 
      end

      def fields?
        !!obj(catalog[:AcroForm] )[:Fields]
      end
      
      def fields
        acroform = obj(catalog[:AcroForm])
        @fields || acroform[:Fields].map do |field_ref|
          obj(field_ref)
        end
      end
      
      def page_annotations(page_num)
        return false unless page(page_num)[:Annots]
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
                   raise ArgumentError, "reference must be an Fixnum or PDF::Reader::Reference not a #{ref.class.name}"
                 end
        
        @hash.each do |ref, obj|
          return obj if ref.id == ref_id
        end
        
      end
      
      def ref_to_str(ref)
        self.class.ref_to_str(ref)
      end
      
      def self.list_callbacks(filename)
        receiver = PDF::Reader::RegisterReceiver.new
        pdf = PDF::Reader.file(filename, receiver)
        receiver.callbacks
        #receiver.callbacks.each do |cb|
        #cb.class.name
        #end

      end
      
      def self.ref_to_str(ref)
        # raise ArgumentError, "reference must be a PDF::Reader::Reference" unless ref.is_a? PDF::Reader::Reference 
        if ref.is_a? Array
          ref.inject("[") do |str, pdf_ref|
            str << (str == "[" ? "" : ", ") << ref_to_str(pdf_ref)

          end << "]"
        elsif ref.is_a? ::PDF::Reader::Reference 
          "#{ref.id} #{ref.gen} R"
        elsif ref.is_a? ::Prawn::Reference 
          "#{ref.identifier} #{ref.gen} R"
        else
          raise ArgumentError, "reference must be an Array or PDF::Reader::Reference"
        end

      end
    end
    
  end
end
