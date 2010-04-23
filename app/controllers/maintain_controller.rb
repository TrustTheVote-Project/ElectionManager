require 'pathname'
class MaintainController < ApplicationController
  
  def import_file
    begin
      if params[:importFile].nil? 
        flash[:error] = "Import failed because file was not specified."
        redirect_to :back
        return
      end
      if params[:commit] == "XML file"
        @election = TTV::ImportExport.import(params[:importFile])
      elsif params[:commit] == "YML file"
        import_handler = TTV::YAMLImport.new(params[:importFile])
        @election = import_handler.import
      end
      flash[:notice] = "Election import was successful. Here is your new election."
      redirect_to @election
    rescue ActionController::RedirectBackError => ex
      redirect_to elections_url
    rescue Exception => ex
      flash[:error] = "Import error: #{ex.message}";
      redirect_to elections_url
    end
  end  
  
  def import_batch
    begin
      if params[:import_folder_path].length == 0 
        flash[:error] = "Import failed because the directory was not specified."
        redirect_to :back
        return
      end
      if params[:commit] == "XML files"
            @election = TTV::ImportExport.import(params[:import_folder_path])
      elsif params[:commit] == "YML files"
        import_handler = TTV::YAMLImport.new(params[:import_folder_path])
        @election = import_handler.import
      end
      flash[:notice] = "Election import was successful. Here are your elections"
      redirect_to elections_url
    rescue ActionController::RedirectBackError => ex
      redirect_to elections_url
    rescue Exception => ex
      flash[:error] = "Import error: #{ex.message}";
      redirect_to elections_url
    end
  end

  def export_file       
    if params[:commit] == "YML file"
      election = Election.find(params[:election_to_export][:id])
      export_obj = TTV::YAMLExport.new(election)
      export_obj.do_export
      election_hash = export_obj.election_hash
      file_contents = YAML.dump(TTV::DataLayer.audit_header_dummy) + YAML.dump(election_hash)
      send_data file_contents, :content_type => "text", :filename => election.display_name.gsub(' ', '_') + ".yml"
      flash[:notice] = "Export succeeded."
    elsif params[:commit] == "XML file"
      election = Election.find(params[:election_to_export][:id])
      xml_builder = TTV::ImportExport.export(election)
      send_data xml_builder, :content_type => "text", :filename => election.display_name.gsub(' ', '_') + ".xml"
      flash[:notice] = "Export succeeded."
    else
      flash[:error] = "Apparent bug in Maintain Controller. Call Pito :)"
    end
  end

end
