#require 'prawn/document/snapshot'

module Prawn
  class Document
    module Snapshot

      alias_method :take_snapshot_old, :take_snapshot
      
      # monkey patch, OUCH, prawn snapshot restore the documents
      # fields.
      def take_snapshot
        shot = take_snapshot_old
        
        if @store.root.data[:AcroForm]

          #puts "TGD: fields = #{@store.root.data[:AcroForm].data[:Fields].inspect}"
          #puts "TGD: fields.object_id = #{@store.root.data[:AcroForm].data[:Fields].object_id.inspect}"
          fields =  Marshal.load(Marshal.dump(@store.root.data[:AcroForm].data[:Fields]))
          shot.merge!(:fields => fields)
        end
        if page.dictionary.data[:Annots]
          #puts "TGD: snapshot page_number = #{page_number.inspect}"
          #puts "TGD: snapshot annots =#{::TTV::Prawn::Reader.ref_to_str(page.dictionary.data[:Annots].data)}"
          annots = Marshal.load(Marshal.dump(page.dictionary.data[:Annots].data))
          shot.merge!(:annots => {:page_num => page_number, :page_annots => annots})          
        end
        shot
      end
      
      alias_method :restore_snapshot_old, :restore_snapshot
      
      
      def restore_snapshot(shot)
        if shot[:fields]
          #puts "restoring fields = #{shot[:fields].inspect}"
          #puts "restoring fields object_id = #{shot[:fields].object_id.inspect}"
          
          @store.root.data[:AcroForm].data[:Fields] = shot[:fields]
        end
        if shot[:annots] && shot[:annots][:page_num] == page_number
          page.dictionary.data[:Annots].data = shot[:annots][:page_annots]
          store[page.dictionary.data[:Annots].identifier].data = page.dictionary.data[:Annots].data
        end
        restore_snapshot_old(shot)
      end
    end
  end
end
