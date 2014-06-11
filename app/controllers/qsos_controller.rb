class QsosController < ApplicationController
  # GET /qsos
  # GET /qsos.json
  def index
    @qsos = Qso.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @qsos }
    end
  end

  # GET /qsos/1
  # GET /qsos/1.json
  def show
    @qso = Qso.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @qso }
    end
  end

  # GET /qsos/new
  # GET /qsos/new.json
  def new
    @qso = Qso.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @qso }
    end
  end

  # GET /qsos/1/edit
  def edit
    @qso = Qso.find(params[:id])
  end

  # POST /qsos
  # POST /qsos.json
  def create
    @qso = Qso.new(params[:qso])

    respond_to do |format|
      if @qso.save
        format.html { redirect_to @qso, notice: 'Qso was successfully created.' }
        format.json { render json: @qso, status: :created, location: @qso }
      else
        format.html { render action: "new" }
        format.json { render json: @qso.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /qsos/1
  # PUT /qsos/1.json
  def update
    @qso = Qso.find(params[:id])

    respond_to do |format|
      if @qso.update_attributes(params[:qso])
        format.html { redirect_to @qso, notice: 'Qso was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @qso.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /qsos/1
  # DELETE /qsos/1.json
  def destroy
    @qso = Qso.find(params[:id])
    @qso.destroy

    respond_to do |format|
      format.html { redirect_to qsos_url }
      format.json { head :no_content }
    end
  end
end
