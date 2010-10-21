require 'prawn'
require 'ballots/dc/ballot_config'
require 'ttv/ballot/wide_column'
require 'ttv/ballot/rect'
require 'ttv/ballot/columns'

module AbstractBallot
  
  # TODO: remove method , code moved into Ballot#render_pdf
  def self.create(election, precinct, template,destination = nil)
#      Prawn.debug = true
    scanner = TTV::Scanner.new()
    config = PDFBallotStyle.get_ballot_config(election,template)
    renderer = Renderer.new(election, precinct, config, destination)
    renderer.render
    raise ArgumentError, "Translation to #{TTV::Translate.human_language(lang)} has not been done. Translate, then try again." if config.et.dirty?
#      config.bt.save
    renderer.to_s
  end

  # no rebuild is used in testing to prevent continuous rebuilds
  def self.translate(election, lang, no_rebuild = false)
    return if no_rebuild && File.exists?(election.translation_path(lang))

    # generate english yaml file by generating ballots for all precincts
    # 
    scanner = Scanner.new()
    config = TTV::PDFBallotStyle.get_ballot_config('default', 'en', election, scanner, instruction_text_url)
    election.district_set.precincts.each do | precinct |
      renderer = Renderer.new(election, precinct, config)
      renderer.render
    end
    config.et.save
    TTV::Translate.translate_file(election.translation_path('en'), election.translation_path(lang), 'en', lang)
  end

  class Renderer

    def initialize(election, precinct, config, destination)
      @election = election
      @precinct = precinct
      @destination = destination
      @c = config
    end

    def to_s
      @pdf.render
    end

    def render
      
      @pdf = Prawn::Document.new(
      :page_layout => @c.page_layout,
      :page_size => @c.page_size, 
      :left_margin => @c.left_margin,
      :right_margin => @c.right_margin,
      :top_margin => @c.top_margin,
      :bottom_margin => @c.bottom_margin,
      :skip_page_creation => true,
      :info => { :Creator => "TrustTheVote",
        :Title => "#{@election.display_name} #{@precinct.display_name} ballot"
      }
      )
      @c.setup(@pdf, @precinct)

      @flow_items = ::DefaultBallot::FlowItem.init_flow_items(@pdf, @election, @precinct, @c.template)
      render_everything
    end

    # initializes everything outside of the flow rect on a new page
    def start_page
      
      end_page(false) if @page
      @pagenum += 1
      @pdf.start_new_page

      # remember for a ballot the
      # page surrounds frame, fram surrounds contents,
      # contents has 3 areas, (header, body and footer)
      
      #TTV::Prawn::Util.show_bounds_coordinates(@pdf.bounds)
      #TTV::Prawn::Util.show_abs_bounds_coordinates(@pdf.bounds)
      
      # given a page,  @pdf.bounds, create a Rectangle that will
      # be used as the flow rectangle.
      # flow rectangle will be used to enclose the flow items
      # such as the question, contest flows.
      
      # create a Rect from the bounding box "732.0, 576.0, 0, 0"
      # Bounds coordinates "t, r, b, l" = "732.0, 576.0, 0, 0"
      # Absolute Bounds coordinates "t, r, b, l" = "762.0, 594.0, 30.0, 18"
      flow_rect = TTV::Ballot::Rect.create_bound_box(@pdf.bounds)

      # draw the frame of the ballot on the page
      @c.render_frame flow_rect

      # set the flow rectangle to be same as 
      if @c.is_a? ::DcBallot::BallotConfig
        # resets the flow rect to be under header, above footer,
        # inside page frame.
        flow_rect = @c.render_contents flow_rect
      else
        @c.render_header flow_rect        
      end
      
 
      columns = @c.create_columns(flow_rect)
      # puts "TGD: start_page: created the columns for the flow rectangle"
      
      # make space for continuation box
      continuation_box = @c.create_continuation_box
      columns.last.bottom += continuation_box.height(@c, columns.last, true)
      
      @c.render_column_instructions(columns, @pagenum) if @c.instructions?
      curr_column = columns.next

      @page = { :continuation_box => continuation_box, :columns => columns, :last_column => curr_column }

      [flow_rect, columns, curr_column]
    end

    def end_page(last_page)
      return if @page == nil
      continuation_col = @page[:last_column]
      return if continuation_col == nil
      continuation_box = @page[:continuation_box]
      columns = @page[:columns]
      if (continuation_col.height < 
        continuation_box.height(@c, continuation_col, @flow_items.size != 0) )
        if ! (continuation_col.class == TTV::Ballot::WideColumn && continuation_col.index(columns.last))
          continuation_col = columns.last
        end
      end
      continuation_box.draw(@c, continuation_col, last_page)
      @c.page_complete(@pagenum, last_page)
      @page = nil
      if last_page
#        puts @c.scanner.to_json
      end
    end

    # tries to fit current item into any columns on the current page
    # returns nil if item does not fit
    #
    def fit_width(item, flow_rect, curr_column, columns)
      return nil if curr_column == nil
      if item.min_width != 0 # if width >= narrow column
        if item.min_width > curr_column.width
          if curr_column.full_height?
            curr_column = columns.make_wide curr_column, item.min_width # widen the current column
          else
            curr_column = columns.make_wide columns.next, item.min_width # 
          end
        end
      elsif curr_column.class == TTV::Ballot::WideColumn # fit narrow items in wide column
        if @c.wide_style == :continue
          curr_column = curr_column.first
          columns.current = curr_column
        else
          curr_column = columns.next
        end
      end
      curr_column
    end

    def render_error(text)
      @pdf.fill_color "FF0000"
      @pdf.font "Helvetica", :size => 18, :style => :bold
      @pdf.text_box text, :at => [50, @pdf.bounds.top - 100], :width    => 300, :height => 1000
    end
    
    def render_everything
      
      @pagenum = 0
      @page =  nil
      curr_column = nil   # used as a flag that we need a new page

      while @flow_items.size > 0
        # start a new page if curr_column is nil, we've run out
        # of columns on this page.
        if curr_column == nil
          flow_rect, columns, curr_column = start_page
        end
        
        item = @flow_items.first
        
        # puts "TGD: page #{@pdf.page_number}, processing a #{item.class.name} named #{item.display_name}"
        
        curr_column = fit_width(item, flow_rect, curr_column, columns)

        if curr_column == nil # item too wide for current page, start a new one
          if columns.empty? # too wide for empty page, that's an error
            @flow_items.shift
            render_error "ERROR Item #{item.to_s} is too wide to fit onto page."
          end
          next
        end

        # puts "curr_column = #{curr_column.inspect}"
        # This will go to next column if we have a header, which means
        # a new district
        if item.is_a?(::DefaultBallot::FlowItem::Combo) && curr_column.header?
          # puts "TGD: go to the next column as this is a combo and the current colum has a header"
          curr_column = columns.next
          # puts "TGD: curr_column = #{curr_column.inspect},there are #{@flow_items.size} flow items left to process"
        end
        
        unless curr_column # end of page, no more columns
          # puts "TGD: end of page #{@pdf.page_number}, no more columns, there are #{@flow_items.size} flow items left to process"
          next
        end
        
        # puts "TGD: check if this item fits in the current column"
        if item.fits @c, curr_column
          @page[:last_column] = curr_column
          item = @flow_items.shift
          # puts "TGD: page #{@pdf.page_number}, drawing a #{item.class.name} named #{item.display_name}"

          item.draw @c, curr_column

          # this column has a header item now
          curr_column.header = true if item.is_a?(::DefaultBallot::FlowItem::Combo)
          
          @c.scanner.append_ballot_marks(item.ballot_marks) 
        elsif curr_column.full_height? # item is taller than a single
          # column, need to break it up
          # puts "TGD: item doesn't it's longer than column height"
          if curr_column.first != columns.first # split items go on a
            # brand new page for now
            curr_column = nil
            next
          else
            @page[:last_column] = curr_column
            @flow_items.shift
            item.draw @c, curr_column do
              # returns new columns for item to draw in
              curr_column = columns.next
              curr_column = fit_width(item, flow_rect, curr_column, columns)
              if (curr_column == nil)
                flow_rect, columns, curr_column = start_page
                curr_column = fit_width(item, flow_rect, curr_column, columns)
                if (curr_column == nil) # cannot fit on a single blank page, error
                  render_error "ERROR, item #{item.to_s} too wide to fit onto page"
                end
              end
              @page[:last_column] = curr_column if curr_column
              curr_column
            end # block
            @c.scanner.append_ballot_marks(item.ballot_marks)
          end
        else
          curr_column = columns.next
          # if columns.next is nil then we are at the end of the
          # page!. Need a new page
          if curr_column
            # puts "TGD: item doesn't fit, make the next column current"
          else
            # puts "TGD: item doesn't fit, out of columns on page #{@pdf.page_number}, draw on a new page "
          end
        end

      end
      end_page(true)
    end

  end
  
end
