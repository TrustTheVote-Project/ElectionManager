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
            html += ttv_view_link_to(:list, class_symbol_p(collection))
          when :new
            html += ttv_view_link_to(:new, class_symbol_s(collection))
          when :edit
            html += ttv_view_link_to(:edit, collection)
          when :show
            html += ttv_view_link_to(:show, collection)
          when :back
            html += ttv_view_link_to(:back, collection)
          when :delete
            html += ttv_view_link_to(:delete, collection)
          when :save
            html += content_tag(:button, t("ttv.save", :default => "Save"), :type => :submit)
          when :cancel
            html += ttv_view_link_to(:cancel, collection)
          else
            raise "Unknown button type in view_builder_helper#ttv_actions_bar: #{btn}"
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
    when :back
      link_to(t("ttv.back", :default => "Back"), polymorphic_path([class_symbol_p([element])]))
    when :cancel
      link_to(t("ttv.cancel", :default => "Cancel"), polymorphic_path([class_symbol_p([element])]))
    when :list
      link_to(t("ttv.list", :default => "List"), polymorphic_path([element]))
    when :new
      link_to(t("ttv.new", :default => "New"), polymorphic_path([:new, element]))
    else
      raise "invalid command in ViewBuilderHelper#ttv_view_link_to: #{command}"
    end
  end
  
  def ttv_show_field(record, field)
    content_tag(:p) do
      case field
      when "ident"
        content_tag(:b, t("ttv.ident", :default => "Ident")+": ") + record.ident
      when "display_name"
        content_tag(:b, t("ttv.display_name", :default => "Display Name")+": ") + record.display_name
      when "asset"
        image_tag(record.asset.url(:medium))
      when "party_id"
        content_tag(:b, t("ttv.party_id", :default => "Party Id")+": ") + record.party_id.to_s
      when "contest_id"
        content_tag(:b, t("ttv.contest_id", :default => "Contest Id") + ": ") + record.contest_id.to_s
      when "position"
        content_tag(:b, t("ttv.position", :default => "Position") + ": ") + record.position.to_s
      when "party"
        content_tag(:b, t("ttv.party", :default => "Position")+": ") + record.party.display_name
      when "contest"
        content_tag(:b, t("ttv.contest", :default => "Contest")+": ") + record.contest.display_name
      else
        raise "view_builder_helper#ttv_show_field invalid field: #{field}"
      end
    end
  end
  
  def ttv_form_field(form, field)
    case field
    when "ident"
      label = form.label :ident, t("ttv.ident", :default => "Ident"), :class => :label
      fld = form.text_field :ident, :class => 'text_field'
    when "display_name"
      label = form.label :display_name, t("ttv.display_name", :default => "Display Name"), :class => :label
      fld = form.text_field :display_name, :class => 'text_field'
    when "asset"
      label = "".html_safe
      fld = form.file_field :asset
    when "party_id"
    when "contest_id"
    when "position"
    when "party"
      parties = Party.find(:all, :order => :id)
      label = form.label :party_id, t("activerecord.attributes.contest.party_id", :default => "Party"), :class => :label
      fld = form.collection_select(:party_id, parties, :id, :display_name)
    when "contest"
      contests = Contest.find(:all, :order => :id)
      label = form.label :contest_id, t("ttv.contest_id", :default => "Contest"), :class => :label
      fld = form.collection_select :contest_id, contests, :id, :display_name
    else
      raise "view_builder_helper#ttv_form_field invalid field: #{field}"
    end
    label + fld
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
  
# Given a column name as a string (e.g. "party_affiliation") convert it to a string suitable for
# a prompt or column name in a view.
  def ttv_col_name(col_name)
    t("ttv."+col_name, :default => col_name.titleize)
  end
  
#
# Take a Collection of ActiveRecord models and return the underlying class name as a :symbol. This crazy conversion
# is needed because polymorphic_path requires the classname as a symbol in order to generate a path for the whole collection.
# e.g: coll is an array of instances of the model Asset, then class_symbol_p(coll) => :assets and class_symbol_s(coll) => :asset
#
# <tt>coll:</tt>Collection to be converted
# <tt>returns:</tt>Class name as a plural symbol
  def class_symbol_p(coll)
    coll[0].class.to_s.pluralize.downcase.to_sym
  end
  def class_symbol_s(coll)
    coll[0].class.to_s.downcase.to_sym
  end


end
