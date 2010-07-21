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
                                          :DR => (@resources || resources),
                                          :DA => ::Prawn::Core::LiteralString.new("/Helv 0 Tf 0 g")
                                          )
      end
      
      def resources(options={})
        options = { :Type => :Font,
          :Subtype  => :Type1,
          :BaseFont => :Helvetica,
          :Encoding => :WinAnsiEncoding }.merge(options)
        @resources = ref(options)
      end
      
      def fields(&block)
        instance_eval(&block) if block_given?
        @fields ||= []
      end
      
      def text_field(name, x, y, w,h, opts = { })
        field_dict = {:T => ::Prawn::Core::LiteralString.new(name),
          :DA => ::Prawn::Core::LiteralString.new("/Helv 0 Tf 0 g"),
          :F => 4,
          :Ff => 0,
          :BS => {:Type => :Border, :W => 1, :S => :S},
          :MK => {:BC => [0, 0, 0]},
          :Rect => [x, y, x + w, y + h]}
        
        if opts[:default]
          field_dict[:V] = ::Prawn::Core::LiteralString.new(opts[:default])
        end
        
        add_interactive_field(:Tx, field_dict)
      end # text_field

      def text_field2(name, x, y, w,h, opts = { })
        field_dict = {
          # type of field is a text field
          :FT => :Tx,
          # partial field name
          :T => ::Prawn::Core::LiteralString.new(name),
          # default appearance, font, size, color, and so forth
          :DA => ::Prawn::Core::LiteralString.new("/Helv 0 Tf 0 g"),
          # Not sure what this is? Maybe the file specification?
          :F => 4,
          # field flag, not read only, not required, can be exported
          :Ff => 0,
        }
        
        if opts[:default]
          # field's value
          field_dict[:V] = ::Prawn::Core::LiteralString.new(opts[:default])
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
          # MK is the appearance character dictionary
          # BC is the widget annotation's border color, (DeviceRGB)
          :MK => {:BC => [0, 0, 0]},
          # BS is the border style dictionary,(width and dash pattern)
          # :W => 1 (width 1 point), :S => :S (solid), 
          :BS => {:Type => :Border, :W => 1, :S => :S},
          # n rectangle, defining the location of the annotation on
          # the page in default userspace units.
          :Rect => [x, y, x + w, y + h],
        }
        
        @fields << ref(field_dict.merge(annotation_dict))
        #add_interactive_field(:Tx, field_dict)
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

      private
      
      def add_interactive_field(type, opts = {})
        defaults = {:FT => type, :Type => :Annot, :Subtype => :Widget}
        #      annotation = @store.ref(opts.merge(defaults))
        annotation = state.store.ref(opts.merge(defaults))
        acroform.data[:Fields] << annotation
        page.dictionary.data[:Annots] ||= []
        page.dictionary.data[:Annots] << annotation
      end
      
      # The AcroForm dictionary (PDF spec 8.6) for this document. It is
      # lazily initialized, so that documents that do not use interactive
      # forms do not incur the additional overhead.
      def acroform
        state.store.root.data[:AcroForm] ||= state.store.ref({:DR => acroform_resources,:DA => ::Prawn::Core::LiteralString.new("/Helv 0 Tf 0 g"),:Fields => []})
      end
      
      # a resource dictionary for interactive forms. At a minimum,
      # must contain the font we want to use
      def acroform_resources
        helv = ref(:Type     => :Font,
                   :Subtype  => :Type1,
                   :BaseFont => :Helvetica,
                   :Encoding => :WinAnsiEncoding)
        ref(:Font => {:Helv => helv})
      end

    end # Form
  end # Prawn
end # TTV
