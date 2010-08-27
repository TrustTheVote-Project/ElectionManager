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
         #  puts "fields = #{@store.root.data[:AcroForm].data[:Fields].inspect}"
          fields = @store.root.data[:AcroForm].data[:Fields].clone
          shot.merge!(:fields => fields)
        end
        if page.dictionary.data[:Annots]
          annots = page.dictionary.data[:Annots].data.clone
          shot.merge!(:annots => annots)          
        end
        #puts "TGD: taking snapshot = #{shot.inspect}"
        shot
      end
      
      alias_method :restore_snapshot_old, :restore_snapshot
      
      
      def restore_snapshot(shot)
        if shot[:fields]
          @store.root.data[:AcroForm].data[:Fields] = shot[:fields]
        end
        if shot[:annots]
          page.dictionary.data[:Annots].data = shot[:annots]
        end
        
        #puts "TGD: restoring shot = #{shot.inspect}"
        restore_snapshot_old(shot)
      end
      
    end
  end
end
