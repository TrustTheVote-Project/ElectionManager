class BallotStyleTemplatesController < ApplicationController
  
  layout 'application'
  
  # GET /ballot_style_templates
  # GET /ballot_style_templates.xml
  def index
    @ballot_style_templates = BallotStyleTemplate.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ballot_style_templates }
    end
  end

  # GET /ballot_style_templates/1
  # GET /ballot_style_templates/1.xml
  def show
    @ballot_style_template = BallotStyleTemplate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ballot_style_template }
    end
  end

  # GET /ballot_style_templates/new
  # GET /ballot_style_templates/new.xml
  def new
    @ballot_style_template = BallotStyleTemplate.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ballot_style_template }
    end
  end

  # GET /ballot_style_templates/1/edit
  def edit
    @ballot_style_template = BallotStyleTemplate.find(params[:id])
  end

  # POST /ballot_style_templates
  # POST /ballot_style_templates.xml
  def create
    @ballot_style_template = BallotStyleTemplate.new(params[:ballot_style_template])

    respond_to do |format|
      if @ballot_style_template.save
        flash[:notice] = 'BallotStyleTemplate was successfully created.'
        format.html { redirect_to(@ballot_style_template) }
        format.xml  { render :xml => @ballot_style_template, :status => :created, :location => @ballot_style_template }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ballot_style_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ballot_style_templates/1
  # PUT /ballot_style_templates/1.xml
  def update
    @ballot_style_template = BallotStyleTemplate.find(params[:id])

    respond_to do |format|
      if @ballot_style_template.update_attributes(params[:ballot_style_template])
        flash[:notice] = 'BallotStyleTemplate was successfully updated.'
        format.html { redirect_to(@ballot_style_template) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ballot_style_template.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ballot_style_templates/1
  # DELETE /ballot_style_templates/1.xml
  def destroy
    @ballot_style_template = BallotStyleTemplate.find(params[:id])
    @ballot_style_template.destroy

    respond_to do |format|
      format.html { redirect_to(ballot_style_templates_url) }
      format.xml  { head :ok }
    end
  end
  
  
  
end
