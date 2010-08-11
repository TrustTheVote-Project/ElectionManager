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
        options = { :width => 10, :height => 10}.merge(opts)
        x,y = map_to_absolute(options[:at])

        unchecked_box_ref = check_box(options[:width], options[:height], false)
        checked_box_ref = check_box(options[:width], options[:height])

        #puts "TGD: unchecked_box_ref is #{unchecked_box_ref}"
        #puts "TGD: checked_box_ref is #{checked_box_ref}"

        field_dict = {
          # type of field is a text field
          :FT => :Btn,
          :T => ::Prawn::Core::LiteralString.new(name),
          :V => :Off, # the name used in the appearance stream (AP),
          # AP is located in this field's annotation
          :Ff => 0
        }

        # TODO: use prawn annotate method
        
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
          :MK => {:BC =>[0.0], :BG=>[1.0]},
          # BS is the border style dictionary,(width and dash pattern)
          # :W => 1 (width 1 point), :S => :S (solid), 
          #:BS => {:Type => :Border, :W => 1, :S => :S},
          #
          :AS => :Off,
          # Appearance stream
          :AP => { :N => { :Yes => checked_box_ref, :Off => unchecked_box_ref}}
        }

        dict = field_dict.merge(annotation_dict)

        # allow one to add to the dictionary in the block
        yield dict  if block_given?
        
        dict_ref = state.store.ref(dict)
        # The COS object, PDF object, reference. ex: 9 0 R
        # puts "dict_ref = #{dict_ref}"
        
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

      def abs_rectangle(point, width, height)
        # Prawn::Graphics.rectangle((point, width, height)
        # maps the x and y, which I don't want!!
        #x,y = map_to_absolute(point)
        x, y = point.flatten
        add_content("%.3f %.3f %.3f %.3f re" % [ x, y, width, height ])
      end
      
      #   pdf.abs_line [100,100], [200,250]
      #   pdf.abs_line(100,100,200,250)      
      def abs_line(*points)
        x0, y0, x1, y1 = points.flatten
        abs_move_to(x0, y0)
        abs_line_to(x1, y1)
      end
      
      #   pdf.abs_move_to [100,50]
      #   pdf.abs_move_to(100,50)
      def abs_move_to(*point)
        x,y = point.flatten
        add_content("%.3f %.3f m" % [ x, y ])  
      end
      
      #   pdf.abs_line_to [50,50]
      #   pdf.line_to(50,50)
      def abs_line_to(*point)
        x, y = point.flatten
        add_content("%.3f %.3f l" % [ x, y ])
      end

      def create_xobject_stamp(name, options = {}, &block)
        
        xobject_form_ref = create_xobject_form(options)
        state.page.stamp_stream(xobject_form_ref, &block)
        state.page.xobjects.merge!(name => xobject_form_ref)
        xobject_form_ref

      end
      
      def create_xobject_form(options={ })
        opts  = { :x => 0, :y => 0, :width => 20, :height => 20}.merge(options)
        xobject_form = ref!(:Type    => :XObject,
                            :Subtype => :Form,
                            :BBox    => [ opts[:x], opts[:y], opts[:width], opts[:height]])
      end
      
      def check_box(width, height, checked = true)
        box = if checked
                # create_stamp makes the with and height the same of the page
                # width and height. Not right for this.
                #create_stamp("checked_box") do
                checked_box_ref = create_xobject_stamp("checked_box",:x => 0, :y => 0, :width => width, :height => height) do        
            abs_rectangle([0, 0], width, height)          
            stroke
            abs_line(0,0,width,height)
            stroke
            abs_line(0,height,width,0)
            stroke
            #abs_rectangle([5, 5], 10, 10)          
            #fill
            # canvas has a different coordinate system, origin is at
            # top left not bottom left
            #           canvas do
            #             box_width = box_height = 20
            #             rectangle([0, 0+box_height], box_width, box_height)
            #             stroke
            #             box_width = box_height = 10
            #             rectangle([5, 5+box_height], box_width, box_height)
            #             fill
            #           end
          end

              else
                create_xobject_stamp("unchecked_box",:x => 0, :y => 0, :width => width, :height => height) do
            # this draws a rect at x = 18 and y = 10?
            #rectangle([0, 0], 20, 20)
            abs_rectangle([0, 0], width, height)
            stroke
          end
              end
      end
      
      
    end # Form
  end # Prawn
end # TTV
