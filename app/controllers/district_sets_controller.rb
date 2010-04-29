class DistrictSetsController < ApplicationController
  # GET /district_sets
  # GET /district_sets.xml
  def index
    @district_sets = DistrictSet.paginate(:per_page => 10, :page => params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @district_sets }
    end
  end

  # GET /district_sets/1
  # GET /district_sets/1.xml
  def show
    @district_set = DistrictSet.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @district_set }
    end
  end

  # GET /district_sets/new
  # GET /district_sets/new.xml
  def new
    @district_set = DistrictSet.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @district_set }
    end
  end

  # GET /district_sets/1/edit
  def edit
    @district_set = DistrictSet.find(params[:id])
  end

  # POST /district_sets
  # POST /district_sets.xml
  def create
    @district_set = DistrictSet.new(params[:district_set])

    respond_to do |format|
      if @district_set.save
        flash[:notice] = 'DistrictSet was successfully created.'
        format.html { redirect_to(@district_set) }
        format.xml  { render :xml => @district_set, :status => :created, :location => @district_set }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @district_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /district_sets/1
  # PUT /district_sets/1.xml
  def update
    @district_set = DistrictSet.find(params[:id])

    respond_to do |format|
      if @district_set.update_attributes(params[:district_set])
        flash[:notice] = 'DistrictSet was successfully updated.'
        format.html { redirect_to(@district_set) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @district_set.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /district_sets/1
  # DELETE /district_sets/1.xml
  def destroy
    @district_set = DistrictSet.find(params[:id])
    @district_set.destroy

    respond_to do |format|
      format.html { redirect_to(district_sets_url) }
      format.xml  { head :ok }
    end
  end
end
