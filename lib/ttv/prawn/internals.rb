# module Prawn
#   class Document
#     module GraphicsState
      
#       def restore_graphics_state
#         puts "In graphics state"
#         add_content "Q"
#       end

#     end
#   end
# end

module Prawn
  class Document     
    module Internals
      # Monkey patch to remove multiple 'Q', restore graphic state
      # command, from page content stream
      def finalize_all_page_contents
        (1..page_count).each do |i|
          go_to_page i
          repeaters.each { |r| r.run(i) }
          # TODO: 
          # Hacky, should check for matching save/restore graphics
          # states in stream
          restore_graphics_state unless "Q\n" == page.content.stream[-2..-1]
          # puts "XXXXpage content = #{page.content.stream.inspect}"
          page.content.compress_stream if compression_enabled?
          page.content.data[:Length] = page.content.stream.size
        end
      end

    end
  end
end
