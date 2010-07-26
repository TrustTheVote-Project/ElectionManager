module TTV
  module Prawn
    module Form
      
      attr_reader :resources, :fields
      
      def test_method
        "This worked"
      end
      
      def form(options={}, &block )

        @fields = []
        instance_eval(&block) if block_given?
        
        data = state.store.root.data
        data[:AcroForm] = state.store.ref(:Fields => (@fields || fields),
                                          :DR => (@resources || resources)
                                          )
      end
      
      def resources(options={})
        options = { :Type => :Font,
          :Subtype  => :Type1,
          :BaseFont => :Helvetica,
          :Encoding => :WinAnsiEncoding }.merge(options)
        @resources = ref(options)
      end

      def draw_text_field(name, opts={}, &block )
        options = { :width => 100, :height => font.height+font.line_gap}.merge(opts)
        x,y = map_to_absolute(options[:at])
        
        field_dict = {
          # type of field is a text field
          :FT => :Tx,
          # (partial) field name
          :T => ::Prawn::Core::LiteralString.new(name),
          # default appearance, font, size, color, and so forth
          #:DA => ::Prawn::Core::LiteralString.new("/Helv 0 Tf 0 g"),
          # field flag: not read only, not required, can be exported
          :Ff => 0,
        }
        
        if options[:default]
          # field's value
          field_dict[:V] = ::Prawn::Core::LiteralString.new(options[:default])
        end
        
        # The PDF object for this text box can also be used as
        # Annotation dictionary.
        # If any form field only has one annotation then it can be
        # used to represent both a field and and annotation      
        # sect 8.4.5 Widget Annotations
        annotation_dict = {
          :Type => :Annot,
          # This is a Widget annotation
          :Subtype => :Widget,
          # Rectangle, defining the location of the annotation on
          # the page in default userspace units.
          :Rect => [x, y, x + options[:width] , y + options[:height]],
          # Annotation Flag. see 8.4.2 Annotation Flags
          # not invisible, not hidden, print annotation when page is printed,...
          :F => 4,
          # :Contents => "Some contents here",
          # MK is the appearance character dictionary
          # BC is the widget annotation's border color, (DeviceRGB)
          #:MK => {:BC => [0, 0, 0]},
          # BS is the border style dictionary,(width and dash pattern)
          # :W => 1 (width 1 point), :S => :S (solid), 
          :BS => {:Type => :Border, :W => 1, :S => :S},
        }

        dict = field_dict.merge(annotation_dict)

        # allow one to add to the dictionary in the block
        yield dict  if block_given?
        
#        puts "TGD: state.store.ref(dict).to_s = #{state.store.ref(dict).to_s.inspect}"
        dict_ref = state.store.ref(dict)
        @fields << dict_ref
        
        # add annotations to the current page
        page.dictionary.data[:Annots] ||= []
        page.dictionary.data[:Annots] << dict_ref
        

      end # text_field


      def show_obj_store()
        out = ""
        out << "Prawn::Core::ObjectStore\n"
        out << "\nIdentifiers: #{state.store.instance_variable_get(:@identifiers).inspect}"
        out << "\nRoot/Catalog: #{state.store.root}"
        out << "\nInfo:  #{state.store.info}"
        out << "\nPages:  #{state.store.pages}"
        out << "\n  -------------"
        # show me the all the objects in the store
        state.store.each do |obj|
          out << "\n"
          out << "Object Reference = #{obj}\n"
          out << "#{obj.object}\n"
          out << "\n  -------------"
        end
        out
      end

    end # Form
  end # Prawn
end # TTV
