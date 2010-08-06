module TTV
  module Prawn
    module FormXObject

      attr_accessor :form_xobj
      
      def form_xobject(name, opts={ }, &block)
        options  = { :x => 0, :y => 0, :width => 20, :height => 20}.merge(opts)
        @form_xobj = ref!(:Type    => :XObject,
                            :Subtype => :Form,
                            :BBox    => [ options[:x], options[:y], options[:width], options[:height]])
        
        # this will add the given block to the 
        page.stamp_stream(@form_xobj, &block)
        
        @form_xobj
      end


      def create_xobject_stamp(name, options = {}, &block)
        
        xobject_form_ref = create_xobject_form(options)
        
        #page.xobjects.merge!(name => xobject_form_ref)
        xobject_form_ref

      end
      
    end # end FormXObject
  end
end
