#require 'lib/ttv/prawn/form_xobject'

module TTV
  module Prawn
    module Form
      
      # This module redefines some drawing primitives, such as rectangle,
      # circle_at and move_to. Prawn::Graphics builds in offsets to these.
      include TTV::Prawn::Graphics
      
      attr_reader :resources, :fields
      attr_accessor :form_enabled

      def form?
        @form_enabled
      end
      
      def form(options={}, &block )
        
        @form_enabled = true
        
        @fields = []
        data = store.root.data
        data[:AcroForm] = store.ref(:Fields => (@fields || fields),
                                          :DR => (@resources || resources)
                                    )
        
        if block_given?
          # if the block param has no arguments then eval it with the
          # scope of this Prawn::Document object.
          # otherwise yield, block.call(..), with the arg this
          # Prawn::Document object.
          block.arity < 1 ? instance_eval(&block) : block.call(self)
        end
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
          
          # add this radio button to the list of this document's fields
          # store.root.data[:AcroForm].data[:Fields] << annotation_ref
        end

        # add this radio button group to the list of this document's fields
        store.root.data[:AcroForm].data[:Fields] << radio_button_ref
        
        # add this radio button group to the list of this page's fields
        # store[page.dictionary.data[:Annots].identifier].data << radio_button_ref
      end
      
      def draw_radiobutton(name, opts={}, &block)
        options = { :width => 10, :height => 10, :selected => false}.merge(opts)
        x,y = map_to_absolute(options[:at])
        
        #def radio_button(name, width, height, selected= true)
        selected_button_ref = radio_button(name, options[:width], options[:height])
        un_selected_button_ref = radio_button(name, options[:width], options[:height], false)
        
        # name of the xobject used to draw the on/selected state
        selected_xobj_name = name.capitalize.to_sym
        puts "TGD: page = #{page_number.inspect}"
        #puts "TGD: pages = #{pages[0].inspect}"
        #puts "TGD: pages = #{pages[0].dictionary.indentifier.inspect}"
        annotation_dict = {
          # NOTE: This breaks the iText RUPS parser when it's
          # included!!
          # Guess we don't need to point to this annotation's parent
          :P => pages[page_number-1].dictionary,
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
        #puts "TTV::Prawn::Form#draw_checkbox"
        #TTV::Prawn::Util.show_bounds_coordinates(bounds)    
        #TTV::Prawn::Util.show_abs_bounds_coordinates(bounds)
        # puts "TGD: annot t, l, w, h = #{[y,x, x + options[:width] , y + options[:height]].inspect}"
        # stroke_color("00FF00") #"FFFFFF"
#         stroke_line([x, y], [x+ options[:width], y])
#         stroke_line([x, y], [x, y+ options[:height]])
        
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
        puts "TGD: page = #{page_number}"        
        annotation_dict = {
          # NOTE: This breaks the iText RUPS parser when it's
          # included!!
          # Guess we don't need to point to this annotation's parent
          :P => pages[page_number-1].dictionary,
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
        # @fields << annotate_redirect(dict)
        annot =  annotate_redirect(dict)
        store.root.data[:AcroForm].data[:Fields] << annot
        # puts "TGD: form field size =  #{store.root.data[:AcroForm].data[:Fields].length.inspect}"
        annot
        
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

        puts "TGD: page = #{page_number.inspect}"
        
        # The PDF object for this text box can also be used as
        # Annotation dictionary.
        # If any form field only has one annotation then it can be
        # used to represent both a field and and annotation      
        # sect 8.4.5 Widget Annotations
        annotation_dict = {
          # Indirect Object Reference to the page's annotations
          # not sure if this is required?
          # NOTE: This breaks the iText RUPS parser when it's included!!
          :P => pages[page_number-1].dictionary,
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
        annot =  annotate_redirect(dict)
        store.root.data[:AcroForm].data[:Fields] << annot
        
      end # text_field
      
      # TODO: pass two code blocks containing PDF path contstructor
      # operators.
      # Ex:
      # lambda { |x,y, w,h| rectangle([0, 0], width, height); stroke }
      def radio_button(name,width, height, selected=true)
        button = nil
        radius = width/2
        selected_radius = width/2-2
        if selected
          button = form_xobject("#{name}_radio_selected",:x => 0, :y => 0, :width => width, :height => height) do
            ttv_circle_at([width/2, height/2], :radius => radius)
            stroke
            ttv_circle_at([width/2, height/2], :radius => selected_radius)
            fill
          end
        else
          button = form_xobject("#{name}_radio_unselected",:x => 0, :y => 0, :width => width, :height => height) do
            ttv_circle_at([width/2, height/2],:radius => radius)
            stroke
            end
        end
        button
      end

      def check_box(width, height, checked = true)
        box = nil
        if checked
          # create_stamp makes the with and height the same of the page
          # width and height. Not right for this.
          #create_stamp("checked_box") do
          box = form_xobject("checked_box",:x => 0, :y => 0, :width => width, :height => height) do
            ttv_rectangle([0, 0], width, height)          
            stroke
            ttv_line(0,0,width,height)
            stroke

            ttv_line(0,height,width,0)
            stroke
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
          box = form_xobject("unchecked_box",:x => 0, :y => 0, :width => width, :height => height) do
            # this draws a rect at x = 18 and y = 10?
            ttv_rectangle([0, 0], width, height)
            stroke
          end
        end
        box 
      end

      
    end # Form
  end # Prawn
end # TTV
