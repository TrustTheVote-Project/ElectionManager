module TTV

  class BallotMark
    def initialize(contest, choice, page, location)
      @contest = contest
      @page = page
      @choice = choice
      @location = location
    end

    def to_json(*a)
      x = { :contest => @contest.id,
        :choice => ((@choice.instance_of? String) ? @choice : @choice.id ),
        :page => @page,
        :location => @location
      }
      x.to_json(*a)
    end

  end

  class Scanner

    attr_accessor :ballot_marks

    def initialize
      @hspace = 72 / 4  # 1/2 inch
      @vspace = 72 / 4  # 1/2 inch
      @bar_width = 18
      @bar_height = 140
      @ballot_marks = []
    end

    def to_json(*a)
      @ballot_marks.to_json(*a)
    end

    def set_checkbox(width, height)
      @check_width = width
      @check_height = height
    end

    def create_ballot_mark(contest, choice, page, location )
      BallotMark.new(contest, choice, page, location)
    end

    def append_ballot_marks(marks)
      @ballot_marks.concat(marks)
    end

    def render_grid(pdf)
      pdf.canvas do
        pdf.fill_color = 'FFFF00'
        x = ((pdf.bounds.right - pdf.bounds.left) / (@check_width + @hspace)).floor
        y = ((pdf.bounds.top - pdf.bounds.bottom) / (@check_height + @vspace)).floor
        x.times do |i|
          y.times do |j|
            my_x = (@check_width + @hspace) * i
            my_y = pdf.bounds.top - (@check_height + @vspace) * j
            pdf.rectangle([ my_x, my_y], @check_width, @check_height)
          end
        end
        pdf.fill
        pdf.fill_color = '000000'
      end
    end

    # our grid is aligned to top/left
    # beware of this when trying to align the y axis  
    def align_checkbox(pdf, point)
      x_offset = pdf.bounds.absolute_left
      y_offset = pdf.bounds.absolute_top - pdf.bounds.top
      x = (point[0] + x_offset) / (@check_width + @hspace)
      x_count = x.ceil
      x = x.ceil * (@check_width + @hspace) - x_offset
      y = (pdf.bounds.absolute_top - point[1] + y_offset) / (@check_height + @vspace)
      y_count = y.ceil
      y = pdf.bounds.absolute_top - (y.ceil * (@check_height + @vspace)) + y_offset
      return [x, y], [x_count, y_count]
    end

    def render_ballot_marks(pdf)
      pdf.fill_color = "#000000"
      pdf.rectangle [0, @bar_height], @bar_width, @bar_height
      pdf.rectangle pdf.bounds.top_left, @bar_width, @bar_height
      pdf.rectangle [pdf.bounds.right - @bar_width, @bar_height], @bar_width, @bar_height
      pdf.rectangle [pdf.bounds.right - @bar_width, pdf.bounds.top], @bar_width, @bar_height
      pdf.fill_and_stroke
    end

  end
end