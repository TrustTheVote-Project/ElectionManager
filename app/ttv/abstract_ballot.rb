require 'prawn'

module AbstractBallot
    
  def self.create(election, precinct, style='default', lang='en', instruction_text='none', state_seal = 'none', state_signature = 'none')
#      Prawn.debug = true
    scanner = TTV::Scanner.new()
    config = PDFBallotStyle.get_ballot_config(style, lang, election, scanner, instruction_text, state_seal, state_signature)
    renderer = Renderer.new(election, precinct, config)
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
    config = TTV::PDFBallotStyle.get_ballot_config('default', 'en', election, scanner, instruction_text, state_seal, state_signature)
    election.district_set.precincts.each do | precinct |
      renderer = Renderer.new(election, precinct, config)
      renderer.render
    end
    config.et.save
    TTV::Translate.translate_file(election.translation_path('en'), election.translation_path(lang), 'en', lang)
  end

  class Rect
    attr_accessor :top, :left, :bottom, :right

    def initialize(top, left, bottom, right)
      @top, @left, @bottom , @right = top, left, bottom, right
      @original_top = @top
    end

    def width
      right - left
    end

    def height
      top - bottom
    end

    def to_s
      "#{full_height? ? 'empty' : ''  }T:#{@top} L:#{@left} B:#{@bottom} R:#{@right} W:#{self.width} H:#{self.height}"
    end

    def inset(horiz, vertical)
      @top -= vertical
      @bottom += vertical
      @left += horiz
      @right -= horiz
    end

    def first
      self
    end

    def full_height?
      @original_top == @top
    end

    def self.create(top, left, bottom, right)
      return new(top, left, bottom, right)
    end

    def self.create_wh(top, left, width, height)
      return new(top, left, top - height, left + width)
    end

    def self.create_bound_box(bb)
      return self.create(bb.top, bb.left, bb.bottom, bb.right)
    end
  end

  # WideColumn is used in layout to group columns together
  # its boundaries are leftmost/rightmost/lowest top/highest bottom
  class WideColumn
    def initialize (rects)
      @rects = rects
      @original_top = top
    end

    def initialize_copy(old)
      @rects =  @rects.map { |r| r.clone }
    end

    def top
      @rects.map { |r| r.top}.min
    end
    def top=(x)
      @rects.each { |r| r.top = x }
    end        
    def bottom
      @rects.map { |r| r.bottom}.max
    end
    def bottom=(x)
      @rects.each { |r| r.bottom = x} 
    end
    def left
      @rects.map { |r| r.left}.min
    end
    def right
      @rects.map { |r| r.right}.max
    end

    def width
      right - left
    end

    def height
      top - bottom
    end

    def index(r)
      @rects.index(r)
    end

    def first
      @rects.first
    end

    def full_height?
      @original_top == top
    end

    def to_s
      s = "T:#{top} L:#{left} B:#{bottom} R:#{right} W:#{width} H#{height}\n\n"
      @rects.each do |r| 
        s += "Combo: #{r.to_s}\n" 
      end
      s
    end        
  end

  # encapsulates columns for rendering
  class Columns
    def initialize(col_count, flow_rect)
      @column_rects = []
      column_width = flow_rect.width / ( col_count * 1.0)
      col_count.times do |x|
        @column_rects.push Rect.create_wh(flow_rect.top, flow_rect.left + column_width *x,
        column_width, flow_rect.height)
      end
      @next = @column_rects.first
    end

    def to_s
      s = ""
      @column_rects.each do |c|
        s += "#{c}\n"
      end
      s
    end

    def next
      retval = @next
      @next = @column_rects[@column_rects.index(@next) + 1] if @next
      retval
    end

    def first
      @column_rects.first
    end

    def last
      @column_rects.last
    end

    def current=(r)
      @next = @column_rects[@column_rects.index(r) + 1]
    end

    def empty?
      @column_rects.select{ |r| r.full_height? }.size == @column_rects.size
    end
    
    def make_wide(column, width)
      return nil if column == nil # not an error case
      cols = [column]
      i = @column_rects.index(column) + 1
      total = column.width
      while (total < width && i < @column_rects.size)
        new_col = @column_rects[i]
        @next = @column_rects[i+1]
        total += new_col.width
        cols.push new_col
        i += 1
      end
      return WideColumn.new(cols) if total >= width
      nil
    end      
  end

  class Renderer

    def initialize(election, precinct, config)
      @election = election
      @precinct = precinct
      @c = config
    end

    def to_s
      @pdf.render
    end

    def init_flow_items
      @flow_items = []
      @precinct.districts(@election.district_set).each do |district|
        header_item = @c.create_flow_item @c.et.get(district, :display_name)
        #        @flow_items.push(@c.create_flow_item(district.display_name))
        contest_list = district.contestsForElection(@election)
        contest_list.sort { |a,b| a.order <=> b.order}.each do |contest|
          if header_item
            @flow_items.push(@c.create_flow_item( [header_item, @c.create_flow_item(contest)] ))
            header_item = nil
          else
            @flow_items.push(@c.create_flow_item(contest))
          end
        end
        district.questionsForElection(@election).each do |question|
          if header_item
            @flow_items.push(@c.create_flow_item( [header_item, @c.create_flow_item(question)] ))
            header_item = nil
          else
            @flow_items.push(@c.create_flow_item(question))
          end
        end
      end       
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

      init_flow_items
      render_everything
    end

    # initializes everything outside of the flow rect on a new page
    def start_page
      end_page(false) if @page
      @pagenum += 1
      @pdf.start_new_page
      

      flow_rect = Rect.create_bound_box(@pdf.bounds)
      @c.render_frame flow_rect
      @c.render_header flow_rect

      columns = @c.create_columns(flow_rect)
      # make space for continuation box
      continuation_box = @c.create_continuation_box
      columns.last.bottom += continuation_box.height(@c, columns.last, true)
      @c.render_column_instructions(columns, @pagenum)
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
        if ! (continuation_col.class == WideColumn && continuation_col.index(columns.last))
          continuation_col = columns.last
        end
      end
      continuation_box.draw(@c, continuation_col, last_page)
      @c.page_complete(@pagenum, last_page)
      @page = nil
      if last_page
        puts @c.scanner.to_json
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
      elsif curr_column.class == WideColumn # fit narrow items in wide column
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
        flow_rect, columns, curr_column = start_page if curr_column == nil
        item = @flow_items.first
        curr_column = fit_width(item, flow_rect, curr_column, columns)
        
        if curr_column == nil # item too wide for current page, start a new one
          if columns.empty? # too wide for empty page, that's an error
            @flow_items.shift
            render_error "ERROR Item #{item.to_s} is too wide to fit onto page."
          end
          next
        end
        
        if item.fits @c, curr_column
          @page[:last_column] = curr_column
          item = @flow_items.shift
          item.draw @c, curr_column
          @c.scanner.append_ballot_marks(item.ballot_marks)
        elsif curr_column.full_height? # item is taller than a single column, need to break it up
          if curr_column.first != columns.first # split items go on a brand new page for now
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
        end
      end
      end_page(true)
    end

  end
  
end
