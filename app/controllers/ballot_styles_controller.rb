class BallotStylesController < ApplicationController
  # GET /ballot_styles
  # GET /ballot_styles.xml
  def index
    @ballot_styles = BallotStyle.paginate(:per_page => 10, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @ballot_styles }
    end
  end

  # GET /ballot_styles/1
  # GET /ballot_styles/1.xml
  def show
    @ballot_style = BallotStyle.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @ballot_style }
    end
  end

  # GET /ballot_styles/new
  # GET /ballot_styles/new.xml
  def new
    @ballot_style = BallotStyle.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @ballot_style }
    end
  end

  # GET /ballot_styles/1/edit
  def edit
    @ballot_style = BallotStyle.find(params[:id])
  end

  # POST /ballot_styles
  # POST /ballot_styles.xml
  def create
    @ballot_style = BallotStyle.new(params[:ballot_style])

    respond_to do |format|
      if @ballot_style.save
        flash[:notice] = 'BallotStyle was successfully created.'
        format.html { redirect_to(@ballot_style) }
        format.xml  { render :xml => @ballot_style, :status => :created, :location => @ballot_style }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @ballot_style.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /ballot_styles/1
  # PUT /ballot_styles/1.xml
  def update
    @ballot_style = BallotStyle.find(params[:id])

    respond_to do |format|
      if @ballot_style.update_attributes(params[:ballot_style])
        flash[:notice] = 'BallotStyle was successfully updated.'
        format.html { redirect_to(@ballot_style) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @ballot_style.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /ballot_styles/1
  # DELETE /ballot_styles/1.xml
  def destroy
    @ballot_style = BallotStyle.find(params[:id])
    @ballot_style.destroy

    respond_to do |format|
      format.html { redirect_to(ballot_styles_url) }
      format.xml  { head :ok }
    end
  end
end
