module TTV
  module Prawn
    class Util
      
      def initialize(pdf)
        @store = pdf.store
        @pdf = pdf
      end
      
      def deref(obj)
        obj.is_a?(::Prawn::Reference) ? obj.data : obj
      end
      
      def get_obj(ref)
        if ref.is_a? Fixnum
          ident = ref
        else
          indent = ref.identifier
        end
        obj = @store[ident]
        deref(obj)
      end

      def root
        deref(@store.root)
      end
      
      alias catalog root

      def info
       deref(@store.info)
      end
      
      def pages
        deref(@store.pages)
      end
      
      def page_list
        pages[:Kids].map do |ref|
          deref(ref)
        end
      end
      
      def page_annotations
        return nil unless @pdf.page.dictionary.data[:Annots]
        @pdf.page.dictionary.data[:Annots].data 
      end

      def page_contents
        page_list.map do |page|
          page[:Contents].stream
        end
      end

      def self.bounds_coordinates(bounds)
        ArgumentError unless bounds.is_a? ::Prawn::Document::BoundingBox
        [bounds.top, bounds.right, bounds.bottom, bounds.left]
      end
      
      def self.bounds_abs_coordinates(bounds)
        ArgumentError unless bounds.is_a? ::Prawn::Document::BoundingBox
        [bounds.absolute_top, bounds.absolute_right, bounds.absolute_bottom, bounds.absolute_left]
      end

      def self.show_abs_bounds_coordinates(bounds)
        puts "Absolute Bounds coordinates \"t, r, b, l\" = #{bounds_abs_coordinates(bounds).join(', ').inspect}"
      end
      def self.show_bounds_coordinates(bounds)
        puts "Bounds coordinates \"t, r, b, l\" = #{bounds_coordinates(bounds).join(', ').inspect}"
      end

      def self.show_rect_coordinates(rect)
        puts "Rectangle coordinates \"t, r, b, l\" = #{rect.top}, #{rect.right}, #{rect.bottom},#{rect.left}"
      end

      def self.stroke_rect(pdf, rect, color='ff000')
        pdf.stroke_color(color) #"FFFFFF"
        pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
        pdf.stroke_line([rect.left, rect.top], [rect.left, rect.bottom])
        pdf.stroke_line([rect.left, rect.bottom], [rect.right, rect.bottom])
        pdf.stroke_line([rect.right, rect.bottom], [rect.right, rect.top])
        
        # doesn't pick up stroke color, oh well
        # pdf.rectangle([rect.left, rect.top], rect.width, rect.height)
      end
      
      def show_obj_store()
        out = ""
        out << "Prawn::Core::ObjectStore\n"
        out << "\nIdentifiers: #{@store.instance_variable_get(:@identifiers).inspect}"
        out << "\nRoot Reference: #{@store.root}"
        out << "\nRoot: #{root.inspect}"
        out << "\nCatalog Reference: #{@store.root}"
        out << "\nCatalog: #{catalog.inspect}"
        out << "\nInfo Reference:  #{@store.info}"
        out << "\nInfo:  #{info.inspect}"
        out << "\nPages Reference:  #{@store.pages}"
        out << "\nPages:  #{pages.inspect}"
        out << "\nPage List:  #{page_list.inspect}"
        out << "\nPage Contents:  #{page_contents.inspect}"
        out << "\n  -------------"
        # show me the all the objects in the store
        @store.each do |obj|
          out << "\n"
          out << "Object Reference = #{obj}\n"
          out << "#{obj.object}\n"
          out << "\n  -------------"
        end
        out
      end
      
      
    end
  end
end
