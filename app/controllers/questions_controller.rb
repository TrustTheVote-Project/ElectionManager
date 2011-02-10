class QuestionsController < ApplicationController

  def index
    current_context.reset
    @questions = Question.paginate(:per_page => 10, :page => params[:page])
  end

  def show
    @question = Question.find(params[:id])
    current_context.question = @question
  end

  def new
    @question = Question.new(:election_id => params[:election_id], :requesting_district_id => params[:district_id])
    render :update do |page|
      editor_id = "#{dom_id(@question.district)}_questions_new"
      page << "if (!$('#{editor_id}')) {"
      page.insert_html :after, "#{dom_id(@question.district)}_static", :partial => 'new.html.erb', :locals => { :question => @question }
      page << "}"
    end if request.xhr?
  end

  def edit
    @question = Question.find(params[:id])
    render :partial => 'edit', :locals => { :question => @question } if request.xhr?
  end

  def create
    @question = Question.new(params[:question])
    success = @question.save
    flash[:notice] = "Question '" + @question.display_name + "' has been created." if success
    if request.xhr?
      render :update do |page|
        if success
          page.replace("#{dom_id(@question.district)}_questions_new", "")
          page.replace "#{dom_id(@question.district)}_questions", :partial => 'districts/questions', 
            :locals => { :district => @question.district, :election => @question.election } 
        else
          page.replace "#{dom_id(@question)}_questions_new", :partial => 'question/new.html.erb', 
            :locals => {:question => @question }
        end
      end
    elsif success
      redirect_to(@question)
    else
      render :action => "new"
    end
  end

  def update
    @question = Question.find(params[:id])
    success =  @question.update_attributes(params[:question])
    flash[:notice] = "Question '" + @question.display_name + "' was updated." if success
    if request.xhr?
      edit_id = "#{dom_id(@question)}_edit"
      static_id = "#{dom_id(@question)}_static"
      render :update do |page|
        if success
          page.remove edit_id
          page.replace static_id, :partial => 'static', :locals => { :question => @question }
        else
          page.replace edit_id, :partial => 'edit', :locals => { :question => question }
        end
      end
    elsif success
      redirect_to @question
    else
      render :action => 'edit'
    end

  end

  def destroy
    @question = Question.find(params[:id])
    display_name = @question.display_name
    district = @question.requesting_district
    election = @question.election
    @question.destroy
    flash[:notice] = "Question '#{display_name}' has been deleted." 
    if request.xhr? # coming from editor, replace question list
      render :update do |page|
        page.replace("#{dom_id(district)}_questions", :partial => 'districts/questions.html.erb', 
        :locals => {:district => district, :election => election })
      end
    else
      redirect_to(questions_path)
    end
  end
end
