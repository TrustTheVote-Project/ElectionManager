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
      
      def draw_checkbox(name, opts={}, &block)
        options = { :width => 100, :height => font.height+font.line_gap}.merge(opts)
        x,y = map_to_absolute(options[:at])

        field_dict = {
          # type of field is a text field
          :FT => :Btn,
          :V => :Yes, # the name used in the appearance stream (AP),
          # AP is located in this field's annotation
          :Ff => 0
        }
        
        # get the annotations for the current page
        annots = nil
        if !page.dictionary.data[:Annots]
          # create a reference to an empty annotation dictionary if
          # one doesn't exist
          page.dictionary.data[:Annots] = state.store.ref([])
        end

        # page annotations
        annots = self.deref(page.dictionary.data[:Annots])
        
        annotation_dict = {
          # Indirect Object Reference to the page's annotations
          # not sure if this is required?
          # NOTE: This breaks the iText RUPS parser when it's included!!
          # :P => page.dictionary.data[:Annots],
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
          :MK => {},
          # BS is the border style dictionary,(width and dash pattern)
          # :W => 1 (width 1 point), :S => :S (solid), 
          :BS => {:Type => :Border, :W => 1, :S => :S},
          #
          :AS => :Yes,
          # Appearance stream
          #:AP => { :N => { :Yes => cs_on, :Off => cs_off}}
        }

        dict = field_dict.merge(annotation_dict)

        # allow one to add to the dictionary in the block
        yield dict  if block_given?
        
        #   puts "TGD: state.store.ref(dict).to_s = #{state.store.ref(dict).to_s.inspect}"
        dict_ref = state.store.ref(dict)
        @fields << dict_ref

        # save this field/annotation in this current page's annotation dictionary
        annots << dict_ref
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
          # :DA => ::Prawn::Core::LiteralString.new("/Helv 0 Tf 0 g"),
          # field flag: not read only, not required, can be exported
          :Ff => 0,
        }
        
        if options[:default]
          # field's value
          field_dict[:V] = ::Prawn::Core::LiteralString.new(options[:default])
        end
        
        # get the annotations for the current page
        annots = nil
        if !page.dictionary.data[:Annots]
          # create a reference to an empty annotation dictionary if
          # one doesn't exist
          page.dictionary.data[:Annots] = state.store.ref([])
        end

        # page annotations
        annots = self.deref(page.dictionary.data[:Annots])
        
        # The PDF object for this text box can also be used as
        # Annotation dictionary.
        # If any form field only has one annotation then it can be
        # used to represent both a field and and annotation      
        # sect 8.4.5 Widget Annotations
        annotation_dict = {
          # Indirect Object Reference to the page's annotations
          # not sure if this is required?
          # NOTE: This breaks the iText RUPS parser when it's included!!
          #:P => page.dictionary.data[:Annots],
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
          :MK => {},
          # BS is the border style dictionary,(width and dash pattern)
          # :W => 1 (width 1 point), :S => :S (solid), 
          :BS => {:Type => :Border, :W => 1, :S => :S},
        }

        dict = field_dict.merge(annotation_dict)

        # allow one to add to the dictionary in the block
        yield dict  if block_given?
        
        #   puts "TGD: state.store.ref(dict).to_s = #{state.store.ref(dict).to_s.inspect}"
        dict_ref = state.store.ref(dict)
        @fields << dict_ref

        # save this field/annotation in this current page's annotation dictionary
        annots << dict_ref

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
