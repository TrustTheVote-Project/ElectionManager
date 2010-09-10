require 'ballots/default/ballot_config'

module DefaultBallot
  class FlowItem

    ANY_WIDTH = 1
    HPAD = 3
    HPAD2 = 6
    VPAD = 3
    VPAD2 = 6
    
    attr_accessor :item
    
    def initialize(item, scanner)
      @item = item
      @scanner = scanner
    end

    def reset_ballot_marks
      @ballot_marks = []
    end
    
    def ballot_marks
      @ballot_marks || []
    end
    
    def fits(config, rect)
      # clever way to see if we fit, avoiding code duplication for measure vs. draw
      # Algorithm: draw the item. If it overflows flow rectangle, it does not fit.
      r = rect.clone
      config.pdf.transaction do
        draw(config, r)
        config.pdf.rollback
      end
      r.height > 0
    end

    def min_width
      0
    end
    
    def display_name
      @item.display_name
    end
    
    def to_s
      @item.to_s
    end
    
    def self.init_flow_items(pdf,election, precinct_split)
      flow_items = []
      # puts "TGD: election districts = #{election.district_set.jur_districts.map(&:display_name).join(',')}"
      # puts "TGD: precinct_split districts = #{precinct_split.district_set.districts.map(&:display_name).join(',')}"
      
      # intersection of this precinct split's districts and an election's districts
      ballot_districts = precinct_split.ballot_districts(election)
      # puts "TGD: adding ballot flow items for #{ballot_districts.map(&:display_name).join(',')}"
      
      ballot_districts.each do |district|
        # puts "TGD: creating header flow item for district #{district.display_name}"
        header_item = self.create_flow_item(pdf, district.display_name)        

        contest_list = ::Contest.find_all_by_district_id(district.id)
        # puts "TGD: contest_list = #{contest_list.map(&:display_name).join(',')}"
        
        contest_list.sort { |a,b| a.position <=> b.position}.each do |contest|
          if header_item
            # puts "TGD: adding contest flow #{contest.display_name} and heading for district #{district.display_name}"
            flow_items.push(self.create_flow_item(pdf, [header_item, self.create_flow_item(pdf,contest)] ))
            header_item = nil
          else
            # puts "TGD: adding contest flow #{contest.display_name} for district #{district.display_name}"
            flow_items.push(self.create_flow_item(pdf,contest))
          end
        end
        
        question_list = ::Question.find_all_by_requesting_district_id(district.id)
        # puts "TGD: question_list = #{question_list.map(&:display_name).join(',')}"

        question_list.each do |question|
          if header_item
            # puts "TGD: adding question flow #{question.display_name} and heading for district #{district.display_name}"
            flow_items.push(self.create_flow_item(pdf, [header_item, self.create_flow_item(pdf,question)] ))
            header_item = nil
          else
            # puts "TGD: adding question flow #{question.display_name} for district #{district.display_name}"
            flow_items.push(self.create_flow_item(pdf,question))
          end
        end
      end
      flow_items
    end
    
    def self.create_flow_item(pdf, item)
      flow_item = case 
                  when item.is_a?(::Contest) then FlowItem::Contest.new(pdf, item, @scanner)
                  when item.is_a?(::Question) then FlowItem::Question.new(pdf, item, @scanner)
                  when item.is_a?(String) then FlowItem::Header.new(pdf, item, @scanner)
                  when item.is_a?(Array) then FlowItem::Combo.new(pdf, item)
                  else
                    raise "Failed to create a flow item for #{item.class.name}"
                  end
    end

  end # end FlowItem
  
end
