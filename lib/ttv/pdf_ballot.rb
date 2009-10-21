require 'PDFlib'

module TTV
  module PDFBallot
    class Rect
      attr_accessor :top, :left, :bottom, :right
      
      def initialize(top, left, bottom, right)
        @top, @left, @bottom , @right = top, left, bottom, right
      end

      def width
        right - left
      end
      
      def height
        top - bottom
      end
      
      def to_s
        "T:#{@top} L:#{@left} B:#{@bottom} R:#{@right} W:#{self.width} H:#{self.height}"
      end
      
      def Rect.create(top, left, bottom, right)
        return new(top, left, bottom, right)
      end

      def Rect.createWH(left, bottom, width, height)
        return new(bottom - height, left, bottom, left + width)
      end

    end

    class FlowItem
      @@bubbleWidth = 22
      @@bubbleHeight = 10

      class HeaderFlowItem < FlowItem
        
        def fits(render, rect)
          rect.height > 16
        end
        
        def drawInto(render, rect)
          render.p.setfont(render.helvetica, 10)
          render.p.fit_textline(@item, rect.left + 2, rect.top - 10 - 2, "")
          render.hline(rect.left, rect.top - 16, rect.width)
          rect.top = rect.top - 16         
        end
      end

      class QuestionItem < FlowItem
        def fits(render, rect)
          rect.height > 20         
        end
        
        def drawInto(render, rect)
          render.p.setfont(render.helvetica, 10)
           render.p.fit_textline("QUESTION", rect.left, rect.top-20, "")
           rect.top = rect.top - 20
           render.hline(rect.left, rect.top, rect.width)
        end
        
      end

      class ContestItem < FlowItem
        @@headerPad = 6
        def fits(render, rect)
          total = 0
          total += render.textHeight(@item.display_name, rect.width - 4, render.helveticaBold, 10)
          total += @@headerPad
          cWidth = rect.width - 14 - @@bubbleWidth 
          @item.candidates.each do |candidate|
            total += render.textHeight(candidate.display_name + "\n" + candidate.party.display_name, cWidth, render.helvetica, 10, "leading=120%")
            total += 6
          end
          total < rect.height
        end
        
        def drawInto(render, rect)
          tf = render.p.add_textflow(-1, @item.display_name, "font=#{render.helveticaBold} fontsize=10")
          rv = render.p.fit_textflow(tf, rect.left + 2, rect.top - 1000, rect.right - 2, rect.top, "")
          Rails.logger.error("fit_textflow returned #{rv}") if rv != "_stop"
          height = render.p.info_textflow(tf, "textheight")
          render.p.delete_textflow(tf)          
          rect.top = rect.top - height - 6
          @item.candidates.each do |candidate|
            render.p.setlinewidth(2)
            render.p.rect(rect.left + 4, rect.top - @@bubbleHeight, @@bubbleWidth, @@bubbleHeight)
            render.p.stroke
            tf = render.p.add_textflow(-1, candidate.display_name + "\n" + candidate.party.display_name, "font=#{render.helvetica} fontsize=10 leading=120%")
            rv = render.p.fit_textflow(tf, rect.left + @@bubbleWidth + 10, rect.top - 1000, rect.right - 2, rect.top + 4, "")
            Rails.logger.error("fit_textflow returned #{rv}") if rv != "_stop"
            height = render.p.info_textflow(tf, "textheight")
            render.p.delete_textflow(tf)          
            rect.top = rect.top - height - 6
          end
          render.p.setlinewidth(1)
          render.hline(rect.left, rect.top, rect.width)
        end
      end

      def initialize(item)
        @item = item
      end
            
      def fits(render, rect)
        rect.height > 20
      end

      def drawInto(render, rect)
        render.p.setfont(render.helvetica, 10)
        render.p.fit_textline("FlowItem.drawInto", rect.left, rect.top-20, "")
        rect.top = rect.top - 20
        render.hline(rect.left, rect.top, rect.width)
      end
      
      def FlowItem.create(item)
        case
        when item.is_a?(Contest) then ContestItem.new(item)
        when item.is_a?(Question) then QuestionItem.new(item)
        when item.is_a?(String) then HeaderFlowItem.new(item)
        end
      end

    end

    class Renderer
      attr_accessor :p, :courier, :helvetica, :helveticaBold
      
      def initialize(election, precinct)
        @election, @precinct = election, precinct
        @pageWidth  = 612
        @pageHeight = 792
        @leftMargin = 44
        @bottomMargin = 60
      end

      def render
        @p = PDFlib.new
        @p.set_parameter("errorpolicy", "exception")
        @p.set_parameter("textformat", "utf8");
        @p.begin_document("", "")
        @p.set_info("Creator", "TrustTheVote")
        @p.set_info("Author", "BallotDesigner")
        @p.set_info("Title", "#{@election.display_name} #{@precinct.display_name} ballot")
        @helvetica = @p.load_font("Helvetica", "unicode", "")
        @helveticaBold = @p.load_font("Helvetica Bold", "unicode", "")
        @courier = @p.load_font("Courier New", "unicode", "")
        @flowFontSize = 10
        @flowItems = []
        @precinct.districts(@election.district_set).each do |district|
          @flowItems.push(FlowItem.create(district.display_name))
          district.contestsForElection(@election).each do |contest|
            @flowItems.push(FlowItem.create(contest))
          end
          district.questionsForElection(@election).each do |question|
            @flowItems.push(FlowItem.create(question))
          end
        end
        while @flowItems.size > 0
          render_page
        end
        @p.end_document("")
      end
      
      def draw_rects(rects) # debugging
        rects.each do |fR|
          @p.rect(fR.left, fR.bottom, fR.width, fR.height)
          Rails.logger.info(fR)
        end
        @p.stroke
      end

      def hline(left, top, width)
        @p.moveto(left, top)
        @p.lineto(left+width, top)
        @p.stroke
      end
      
      def vline(left, top, length)
        @p.moveto(left, top)
        @p.lineto(left, top - length)
        @p.stroke
      end
      
      def textHeight(text, width, font, size, opts="")
        tf = @p.add_textflow(-1, text, "font=#{font} fontsize=#{size} " + opts)
        @p.fit_textflow(tf, 0,0,width,2000, "blind=true")
        height = @p.info_textflow(tf, "textheight")
        @p.delete_textflow(tf)
        height
      end
      
      def render_page
        @p.begin_page_ext(@pageWidth, @pageHeight, "")  # letter
        render_frame
        top = render_header
        # compute flow rects
        flowRects = []
        columns = 3
        left = @leftMargin
        width = (@pageWidth - 2 * @leftMargin) /( columns * 1.0)
        columns.times do |x|
          flowRects.push Rect.create(top, @leftMargin + width *x, @bottomMargin, @leftMargin + width * (x+1))
        end
        0.upto(columns-1) {|x| vline(flowRects[x].right, top, flowRects[x].height) }
        currFlow = 0
        # try to fill up all the columns with items 
        while @flowItems.size > 0
          if @flowItems.first.fits(self, flowRects[currFlow])
            @flowItems.shift.drawInto(self, flowRects[currFlow])
          else
            if flowRects[currFlow].top == top # if column is full height
              @p.setcolor("fillstroke", "rgb", 1.0, 0.0, 0.0, 0.0)
              @flowItems.first.drawInto(self, flowRects[currFlow])
            end
            currFlow += 1
            break if currFlow == columns
          end
        end
        Rails.logger.info("rendered page")
        @p.end_page_ext("") 
      end

      def render_frame
        # FRAME
        # frame rect
        Rails.logger.info("T:#{@leftMargin} L:#{@bottomMargin} W:#{@pageWidth - @leftMargin * 2} H:#{@pageHeight - @bottomMargin * 2}")
        @p.rect(@leftMargin, @bottomMargin, @pageWidth - @leftMargin * 2, @pageHeight - @bottomMargin * 2)
        @p.stroke
        # scanalign boxes
        @p.setcolor("fillstroke", "rgb", 0.0, 0.0, 0.0, 0.0)
        scanalignHeight = 140
        saHeight = 140
        saWidth = 18
        @p.rect(18, @bottomMargin, saWidth, saHeight) #allignrect1
        @p.rect(18, @pageHeight - saHeight - @bottomMargin, saWidth, saHeight) #allignrect2
        @p.rect(@pageWidth - @leftMargin + 8 , @bottomMargin, saWidth, saHeight) #allignrect3
        @p.fill_stroke
        # side text
        fontSize = 14
        @p.setfont(@courier, fontSize)
        @p.fit_textline("Sample Ballot", @leftMargin - fontSize - 4, 330, "orientate=west")
        @p.fit_textline("Sample Ballot", @pageWidth - @leftMargin+12, 330, "orientate=west")
        @p.fit_textline("12001040100040", @leftMargin - fontSize - 4, 470, "orientate=west")
        @p.fit_textline("132301113", @pageWidth - @leftMargin+12, 210, "orientate=west")
      end

      # returns header height
      def render_header
        @p.setfont(@helvetica, 13)
        left =  @leftMargin + 6
        top = @pageHeight - @bottomMargin
        offical = "OFFICIAL BALLOT"
        @p.fit_textline(offical, left, top - 14, "")
        @p.fit_textline(@election.start_date.strftime("%B %d, %Y"), left, top - 30, "")
        oWidth = @p.info_textline(offical, "width", "")
        opts = "boxsize={#{@pageWidth - 2 * @leftMargin - oWidth} 14} position={center bottom}"
        @p.fit_textline(@election.display_name, left + oWidth, top - 14, opts)
        @p.fit_textline(@precinct.display_name, left + oWidth, top - 30, opts)
        lineLoc = top - 34
        hline(@leftMargin, lineLoc, @pageWidth)
        lineLoc
      end

      def pdf
        @p.get_buffer()
      end
    end

    def PDFBallot.create(election, precinct)
      #      begin
      renderer = Renderer.new(election, precinct)
      renderer.render
      renderer.pdf

      #      rescue PDFlibException => pe
      #        Rails.logger.error "PDFlib exception occurred in hello sample:\n" 
      #        Rails.logger.error "[" + pe.get_errnum.to_s + "] " + pe.get_apiname + ": " + pe.get_errmsg + "\n" 
      #        throw pe
      #      end
    end
  end
end
