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
        
        data = store.root.data
        data[:AcroForm] = store.ref(:Fields => (@fields || fields),
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
      
      def draw_radio_group(name, opts={}, &block)
        options = { :width => 10, :height => 10}.merge(opts)
        x,y = map_to_absolute(options[:at])
        
        field_dict = {
          :FT => :Btn, # type of field is a button
          :T => ::Prawn::LiteralString.new(name),
          :V => :Off, # Name of default state for each radio button.
          :Ff => 32768, # Set of radio buttons
          # references to widget annotations that represent each radio button
          :Kids => []  
        }

        # fills the :Kids array with a set of annotations, each
        # annotaton represents one radio button
        yield field_dict if block_given?
        
        # get a reference to this radio button group
        radio_button_ref = ref!(field_dict)

        # create a reference in each radio button annotaton back to
        # this radio button group
        field_dict[:Kids].each do |annotation_ref|
          annotation_ref.data.merge!(:Parent => radio_button_ref)
        end

        # add this radio button group to the list of this document's fields
        @fields << radio_button_ref
      end
      
      def deref(obj)
        obj.is_a?(Prawn::Core::Reference) ? obj.data : obj
      end
      
      def get_obj(ref)
        obj = store[ref.identifier]
        deref(obj)
      end
      
      def draw_radiobutton(name, opts={}, &block)
        options = { :width => 10, :height => 10, :selected => false}.merge(opts)
        x,y = map_to_absolute(options[:at])
        
        #def radio_button(name, width, height, selected= true)
        selected_button_ref = radio_button(name, options[:width], options[:height])
        un_selected_button_ref = radio_button(name, options[:width], options[:height], false)
        
        # name of the xobject used to draw the on/selected state
        selected_xobj_name = name.capitalize.to_sym
        
        annotation_dict = {
          # NOTE: This breaks the iText RUPS parser when it's
          # included!!
          # Guess we don't need to point to this annotation's parent
          # :P => page.dictionary.data[:Annots],
          :Type => :Annot,
          :Subtype => :Widget,
          # Rectangle, defining the location of the annotation on
          # the page in default userspace units.
          :Rect => [x, y, x + options[:width] , y + options[:height]],
          # Annotation Flag. see 8.4.2 Annotation Flags
          # not invisible, not hidden, print annotation when page is printed,...
          :F => 4,
          # MK is the appearance character dictionary
          # BC is the widget annotation's border color, (DeviceRGB)
          :MK => {:BC =>[0.0], :BG=>[1.0]},
          # BS is the border style dictionary,(width and dash pattern)
          # :W => 1 (width 1 point), :S => :S (solid), 
          #:BS => {:Type => :Border, :W => 1, :S => :S},
           # default state for button
          :AS => options[:selected] ? selected_xobj_name : :Off,
          # Appearance stream
          :AP => { :N => { selected_xobj_name => selected_button_ref, :Off => un_selected_button_ref}}
        }
        # Add this annotation to the current page's set of annotatations

        annotate_redirect(annotation_dict)
      end
      
      def draw_checkbox(name, opts={}, &block)
        options = { :width => 10, :height => 10}.merge(opts)
        x,y = map_to_absolute(options[:at])

        unchecked_box_ref = check_box(options[:width], options[:height], false)
        checked_box_ref = check_box(options[:width], options[:height])

        field_dict = {
          # type of field is a text field
          :FT => :Btn,
          :T => ::Prawn::LiteralString.new(name),
          # TODO: Make not be required?
          :V => :Off, # the name used in the appearance stream (AP),
          :Ff => 0
        }

        annotation_dict = {
          # NOTE: This breaks the iText RUPS parser when it's
          # included!!
          # Guess we don't need to point to this annotation's parent
          # :P => page.dictionary.data[:Annots],
          :Type => :Annot,
          :Subtype => :Widget,
          # Rectangle, defining the location of the annotation on
          # the page in default userspace units.
          :Rect => [x, y, x + options[:width] , y + options[:height]],
          # Annotation Flag. see 8.4.2 Annotation Flags
          # not invisible, not hidden, print annotation when page is printed,...
          :F => 4,
          # MK is the appearance character dictionary
          # BC is the widget annotation's border color, (DeviceRGB)
          :MK => {:BC =>[0.0], :BG=>[1.0]},
          # BS is the border style dictionary,(width and dash pattern)
          # :W => 1 (width 1 point), :S => :S (solid), 
          #:BS => {:Type => :Border, :W => 1, :S => :S},
          :AS => :Off, # default state for button
          # Appearance stream
          :AP => { :N => { :Yes => checked_box_ref, :Off => unchecked_box_ref}}
        }
        
        # We can have one dictionary for both the field and the widget annotation
        dict = field_dict.merge(annotation_dict)

        # allow one to add to the dictionary in the block
        yield dict  if block_given?
        
        # Add this annotation to the current page's set of annotatations
        # Add this field to this document's set of fields
        @fields << annotate_redirect(dict)
      end
      
      
      def draw_text_field(name, opts={}, &block )
        options = { :width => 100, :height => font.height+font.line_gap}.merge(opts)
        x,y = map_to_absolute(options[:at])
        
        field_dict = {
          # type of field is a text field
          :FT => :Tx,
          # (partial) field name
          :T => ::Prawn::LiteralString.new(name),
          # default appearance, font, size, color, and so forth
          # :DA => ::Prawn::LiteralString.new("/Helv 0 Tf 0 g"),
          # field flag: not read only, not required, can be exported
          :Ff => 0,
        }
        
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
        
        # Add this annotation to the current page's set of annotatations
        # Add this field to this document's set of fields
        @fields << annotate_redirect(dict)
        
      end # text_field

      
      def show_obj_store()
        out = ""
        out << "Prawn::Core::ObjectStore\n"
        out << "\nIdentifiers: #{store.instance_variable_get(:@identifiers).inspect}"
        out << "\nRoot/Catalog: #{store.root}"
        out << "\nInfo:  #{store.info}"
        out << "\nPages:  #{store.pages}"
        out << "\n  -------------"
        # show me the all the objects in the store
        store.each do |obj|
          out << "\n"
          out << "Object Reference = #{obj}\n"
          out << "#{obj.object}\n"
          out << "\n  -------------"
        end
        out
      end
      
      # TODO: refactor abs_xxx methods into own module, something like canvas?
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
      
      def abs_circle_at(point, options)
        x,y = point
        abs_ellipse_at [x, y], options[:radius]
      end

      KAPPA = 4.0 * ((Math.sqrt(2) - 1.0) / 3.0)      
      def abs_ellipse_at(point, r1, r2 = r1)
        x, y = point
        l1 = r1 * KAPPA
        l2 = r2 * KAPPA
        
        abs_move_to(x + r1, y)
        
        # Upper right hand corner
        abs_curve_to [x,  y + r2],
        :bounds => [[x + r1, y + l1], [x + l2, y + r2]]
        
        # Upper left hand corner
        abs_curve_to [x - r1, y],
        :bounds => [[x - l2, y + r2], [x - r1, y + l1]]
        
        # Lower left hand corner
        abs_curve_to [x, y - r2],
        :bounds => [[x - r1, y - l1], [x - l2, y - r2]]
        
        # Lower right hand corner
        abs_curve_to [x + r1, y],
        :bounds => [[x + l2, y - r2], [x + r1, y - l1]]
        
        abs_move_to(x, y)
      end

      def abs_curve_to(dest, options={ })
        options[:bounds] or raise Prawn::Errors::InvalidGraphicsPath,
        "Bounding points for bezier curve must be specified "+
          "as :bounds => [[x1,y1],[x2,y2]]"

        curve_points = (options[:bounds] << dest).map { |e| e }
        add_content("%.3f %.3f %.3f %.3f %.3f %.3f c" %
                    curve_points.flatten )
      end
      # TODO: refactor out into an XObject Form module
      def create_xobject_stamp(name, options = {}, &block)
        
        xobject_form_ref = create_xobject_form(options)
        page.stamp_stream(xobject_form_ref, &block)
        #page.xobjects.merge!(name => xobject_form_ref)
        xobject_form_ref

      end
      
      def create_xobject_form(options={ })
        opts  = { :x => 0, :y => 0, :width => 20, :height => 20}.merge(options)
        xobject_form = ref!(:Type    => :XObject,
                            :Subtype => :Form,
                            :BBox    => [ opts[:x], opts[:y], opts[:width], opts[:height]])
      end

      def radio_button(name,width, height, selected=true)
        button = nil
        radius = width/2
        selected_radius = width/2-2
        if selected
          button = create_xobject_stamp("#{name}_radio_selected",:x => 0, :y => 0, :width => width, :height => height) do
            
            abs_circle_at([width/2, height/2], :radius => radius)
            stroke
            abs_circle_at([width/2, height/2], :radius => selected_radius)
            fill
          end
        else
          button = create_xobject_stamp("#{name}_radio_unselected",:x => 0, :y => 0, :width => width, :height => height) do
            abs_circle_at([width/2, height/2],:radius => radius)
            stroke
            end
        end
        button
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
