module Prawn
  class Document
    module Snapshot
#       alias_method take_snapshot_old, take_snapshot
#       alias_method take_snapshot, take_snapshot_fields
      
#       # monkey patch, OUCH, prawn snapshot restore the documents
#       # fields.
#       def take_snapshot_fields
#         fields = @store.pages.data[:Fields].map{ |field| field.indentifier}
#         take_snapshot_old.merge!({:fields => fields})
#       end
      
#       alias_method restore_snapshot_old, restore_snapshot
#       alias_method restore_snapshot, restore_snapshot_fields
      
#       def restore_snapshot(shot)
#         @store.pages.data[:Fields] = shot[:fields].map{|id| @store[id]}
#         restore_snapshot_old
#       end
      
    end
  end
end
