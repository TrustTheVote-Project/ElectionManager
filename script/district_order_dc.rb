%w{ FEDERAL COLUMBIA WARD CONGRESSIONAL SMD}.each_index do |i,ident|
  District.all.map{ |d| d.position = i; d.save! if d.ident =~ /ident/ }.compact  
end
