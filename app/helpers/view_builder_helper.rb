# OSDV Election Manager - View Builder Helpers
# Author: Pito Salas
# Date: 10/5/2010
#
# License Version: OSDV Public License 1.2
#
# The contents of this file are subject to the OSDV Public License
# Version 1.2 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.osdv.org/license/
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.

# The Original Code is: TTV Election Manager and Ballot Design Studio.
# The Initial Developer of the Original Code is Open Source Digital Voting Foundation.
# Portions created by Open Source Digital Voting Foundation are Copyright (C) 2010.
# All Rights Reserved.

# Contributors: Aleks Totic, Pito Salas, Tom Dyer, Jeffrey Gray, Brian Jordan, John Sebes.

# 'Macros' that build standard elements of ttv views 
module ViewBuilderHelper
  
  def ttv_view_list_basic ems_class, collection, poly_name, buttons, paginate=false
    content_tag(:div, :class => "inner") do
      title = ttv_view_list_title(ems_class.to_s.pluralize)
      view_list = ttv_view_list(ems_class, collection, poly_name)
      actions_bar = ttv_actions_bar(ems_class, collection, buttons, paginate)
      title + view_list + actions_bar
    end
  end
  
  def ttv_view_list_title(title_of)
    content_tag(:h3, :class=>"title") do
      t("ttv.all", :default => "All") + " " + title_of
    end
  end
  
  def ttv_view_list(ems_class, collection, poly_name)
    content_tag(:table, :class => "table") do
      ttv_view_list_hdr(poly_name) + ttv_view_list_body(ems_class, collection, poly_name)
    end
  end
  
  def ttv_actions_bar(ems_class, collection, buttons, paginate=false)
    html = ttv_buttons_bar(ems_class, collection, buttons)
    if (paginate) 
      html += will_paginate(collection, :class => "pagination buttons")
    end
    content_tag(:div,html , :class => "actions-bar wat-cf")
  end
  
  def ttv_buttons_bar(ems_class, collection, buttons)
    content_tag(:div, :class => "command buttons") do
      html = "".html_safe
      buttons.each do
        |btn|
        case btn
        when :list 
          html += ttv_view_link_to(:list, class_symbol_p(collection))
        when :new
          # TODO Change this when we create a real Jurisdiction Model
          if ems_class == DistrictSet
            html += ttv_view_link_to(:new, "jurisdiction")              
          else
            html += ttv_view_link_to(:new, ems_class.to_s.downcase)
          end
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
          if ems_class == DistrictSet
            html += ttv_view_link_to(:cancel, "Jurisdiction")              
          else
            html += ttv_view_link_to(:cancel, collection)
          end
        else
          raise "Unknown button type in view_builder_helper#ttv_actions_bar: #{btn}"
        end
      end
      html
    end
    
  end
  
  def ttv_view_list_body ems_class, collection, poly_name
    html = "".html_safe
    if collection.length != 0
      collection.each do 
        |element|
        html += content_tag(:tr, ttv_view_list_rows(element, poly_name), :class => cycle("odd", "even"))
      end
    else
      html += ttv_none_defined_yet(ems_class)
    end
    html
  end
  
  def ttv_none_defined_yet(ems_class)
    message = object_not_defined_yet_message(ems_class)
    content_tag(:tr, content_tag(:td, message ), :class => "emptysubtable")
  end
  
  def ttv_view_list_rows(element, poly_names)
    html = "".html_safe
    poly_names.each do
      |poly_name|
      html += content_tag(:td, link_to(poly_get_value(element, poly_name),   polymorphic_path([element])))
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
      #      link_to(t("ttv.cancel", :default => "Cancel"), polymorphic_path([class_symbol_p([element])]))
      link_to(t("ttv.cancel", :default => "Cancel"), :back)
    when :list
      link_to(t("ttv.list", :default => "List"), polymorphic_path([element]))
    when :new
      link_to(t("ttv.new", :default => "New"), polymorphic_path([:new, element]))
    else
      raise "invalid command in ViewBuilderHelper#ttv_view_link_to: #{command}"
    end
  end
  
  def ttv_show_field(record, poly_name)
    content_tag(:p) do
      case poly_name
      when "ident"
        content_tag(:b, t("ttv.ident", :default => "Ident")+": ") + poly_get_value(record, poly_name)
      when "display_name"
        content_tag(:b, t("ttv.display_name", :default => "Display Name")+": ") + poly_get_value(record, poly_name)
      when "asset"
        image_tag(poly_get_value(record, poly_name))
      when "party_id"
        content_tag(:b, t("ttv.party_id", :default => "Party Id")+": ") + poly_get_value(record, poly_name)
      when "contest_id"
        content_tag(:b, t("ttv.contest_id", :default => "Contest Id") + ": ") + poly_get_value(record, poly_name)
      when "position"
        content_tag(:b, t("ttv.position", :default => "Position") + ": ") + poly_get_value(record, poly_name)
      when "party"
        content_tag(:b, t("ttv.party", :default => "Position")+": ") + poly_get_value(record, poly_name)
      when "contest"
        content_tag(:b, t("ttv.contest", :default => "Contest")+": ") + poly_get_value(record, poly_name)
      when "ballot_style_template"
        content_tag(:b, poly_name_column_header(poly_name) + ": ") + 
        link_to(poly_get_value(record, poly_name), edit_ballot_style_template_path(BallotStyleTemplate.find(record.ballot_style_template_id)))
      when "default_voting_method"
        content_tag(:b, poly_name_column_header(poly_name) + ": ") + 
        link_to(poly_get_value(record, poly_name), edit_voting_method_path(VotingMethod.find(record.default_voting_method_id)))
      else
        content_tag(:b, poly_name_column_header(poly_name))+ ": " + poly_get_value(record, poly_name)
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
      hdr_section += content_tag(:th, poly_name_column_header(col_name))
    end
    hdr_section += content_tag(:th,  "&nbsp", :class => "last")   
    content_tag(:tr, hdr_section)
  end
  
  def ttv_linkbox(leftlinks, rightlinks)
    content_tag(:div, :id => :linkbox) do
      ttv_link_list(:left, leftlinks) + ttv_link_list(:right, rightlinks)
    end
  end
  
  def ttv_link_list(div_class, linklist)
    list_section = "".html_safe
    content_tag(:div, :class => div_class) do
      linklist.each do
        |alink|
          list_section += content_tag(:p, alink)
      end
      list_section
    end
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
