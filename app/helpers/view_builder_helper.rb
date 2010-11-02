# 'Macros' that build standard elements of ttv views 
module ViewBuilderHelper

# <%= ttv_view_list "asset", ["ident", "display_name"], ["list", "new"] %>
  def ttv_view_list collection, headings, buttons
    content_tag(:div, :class => "inner") do
      view_list = content_tag(:table, :class => "table") do
        ttv_view_list_hdr(headings) + ttv_view_list_body(collection, headings)
      end      
      actions_bar = ttv_actions_bar(collection, buttons)
      view_list + actions_bar
    end
  end
  
  def ttv_actions_bar(collection, buttons)
    content_tag(:div, :class => "actions-bar wat-cf") do
      content_tag(:div, :class => "buttons") do
        html = "".html_safe
        buttons.each do
          |btn|
          case btn
          when :list 
            html += link_to t("ttv.list", :default => "List"), polymorphic_path(collection)
          when :new
            html += link_to t("ttv.new", :default => "New"), polymorphic_path(:new, collection)
          else
            raise "Unknown button type in view_builder_helper#ttv_actions_bar"
          end
        end
        html
      end
    end
  end
    
  def ttv_view_list_body collection, headings
    html = "".html_safe
    collection.each do 
      |element|
      html += content_tag(:tr, ttv_view_list_rows(element, headings), :class => cycle("odd", "even"))
    end
    html
  end
  
  def ttv_view_list_rows(element, headings)
    html = "".html_safe
    headings.each do
      |heading|
      html += content_tag(:td, link_to(element.read_attribute(heading),   polymorphic_path([element])))
    end
    show_cmd = ttv_view_link_to(:show, element)
    edit_cmd = ttv_view_link_to(:edit, element)
    delete_cmd = ttv_view_link_to(:delete, element)
    html += content_tag(:td, show_cmd + " | " + edit_cmd + " | " + delete_cmd, :class => "last")
  end
  
  def ttv_view_link_to(command, element)
    case command
    when :show
      link_to(t("ttv.show", :default => "Show"), polymorphic_path([element]))
    when :edit
       link_to(t("ttv.edit", :default => "Edit"), polymorphic_path([:edit, element]))
    when :delete
      link_to(t("ttv.delete", :default => "Delete"), polymorphic_path([element]), :method => :delete, :confirm => t("ttv.areyosure", :default => "Are you sure?"))
    end
  end
  
  def ttv_view_list_hdr headings
    hdr_section = "".html_safe
    headings.each do 
      |col_name|
      hdr_section += content_tag(:th, t("ttv."+col_name, :default => col_name.titleize))
    end
    hdr_section += content_tag(:th,  "&nbsp", :class => "last")   
    content_tag(:tr, hdr_section)
  end
end
