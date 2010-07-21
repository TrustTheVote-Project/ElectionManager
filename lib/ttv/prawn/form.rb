module TTV
  module Prawn
    module Form
      
      def test_method
        "This worked"
      end
      
      def form(options={} )
        # state.store.root.data[:AcroForm] ||= state.store.ref({:DR => acroform_resources,:DA => Prawn::Core::LiteralString.new("/Helv 0 Tf 0 g"),:Fields => []})
        data = state.store.root.data
        data[:AcroForm] = state.store.ref({:Fields => []})
        
        data[:AcroForm][:DA] = ::Prawn::Core::LiteralString.new("/Helv 0 Tf 0 g") unless data[:AcroForm][:DA]
        
        resources unless data[:AcroForm][:DR]
      end
      
      def resources(options={})
        options = { :Type => :Font,
          :Subtype  => :Type1,
          :BaseFont => :Helvetica,
          :Encoding => :WinAnsiEncoding }.merge(options)
        helv = ref(options)
        state.store.root.data[:AcroForm][:DR] = ref(:Font => {:Helv => helv})
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
