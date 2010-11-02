class CandidatesController < ApplicationController

  def index
    current_context.reset
    @candidates = Candidate.paginate(:per_page => 9, :page => params[:page])
  end

  def show
    @candidate = Candidate.find(params[:id])
  end

  def new
    @candidate = Candidate.new
    @candidate.contest_id = params[:contest_id];
    raise "Invalid contest. Candidates must be created inside a contest" if params[:contest_id].nil?
    render :update do |page|
      editor_id = "#{dom_id(@candidate.contest)}_candidates_new"
      page.insert_html :after, "#{dom_id(@candidate.contest)}_static", :partial => 'new.html.erb', :locals => { :model => @candidate }
    end if request.xhr?;
  end

  def edit
    @candidate = Candidate.find(params[:id])
    render :partial => 'edit', :locals => { :candidate => @candidate } if request.xhr?
  end

  # def create -- candidates are created through contests:update nested attributes
  # end
  def update
    @candidate = Candidate.find(params[:id])
    success = @candidate.update_attributes(params[:candidate])
    flash[:notice] = "Candidate '" + @candidate.display_name + "' was successfully updated." if success
    if request.xhr?
      edit_id = "#{dom_id(@candidate)}_edit"
      static_id = "#{dom_id(@candidate)}_static"
      render :update do |page|
        if success
          page.remove edit_id
          page.replace static_id, :partial => 'static', :locals => { :candidate => @candidate }
        else
          page.replace edit_id, :partial => 'edit', :locals => { :candidate => @candidate }
        end
      end
    elsif success
      redirect_to @candidate
    else
      render :action => "edit"
    end
  end

  def destroy
    begin
      @candidate = Candidate.find(params[:id])
      contest = @candidate.contest
      display_name = @candidate.display_name
      @candidate.destroy
      flash[:notice] = "Candidate '" + display_name + "' has been deleted."
      if request.xhr? # coming from contest editor, return all contests
        render :update do |page|
          page.replace("#{dom_id(contest)}_candidates", :partial => 'contests/candidates.html.erb', :locals => {:contest => contest})
        end
      else
        redirect_to(candidates_url)
      end
    rescue => ex
      flash[:error] = "Unexpected error: " + ex.message
    end
  end
end
