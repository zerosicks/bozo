class MapsController < ApplicationController
  before_action :get_map, only: [:show, :edit, :update, :destroy, :track]
  layout "map"

  def new
    @map = Map.new
    render layout: "bare"
  end

  def create
    @map = Map.new(map_params)
    system = System.find_by(name: params[:map][:home])
    @map.home_id = system.id unless system.nil?
    @map.layout = ""

    if @map.save
      redirect_to @map, notice: "Map Created"
    else
      render :new
    end
  end

  def index
    @corps = current_user.corps
    @maps = Map.where(corp_id: @corps.pluck(:id) )
  end

  def show
    gon.nodes = @map.nodes
    gon.edges = @map.edges
    gon.layout = @map.layout unless @map.layout.nil?
    respond_to do |format|
      format.html
      format.json { render json: @map, status: :ok }
    end
  end

  def update
    respond_to do |format|
      if @map.update( map_params )
        format.html { redirect_to @map, notice: 'Map Updated.' }
        format.json { render json: @map, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @map.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      format.html { redirect_to @map, notice: 'Map Updated.' }
      format.json { head :no_content }
    end
  end

  def track
    gon.data = @igb_data = igb_data
    respond_to do |format|
      format.html
      format.json { render json: @igb_data }
    end
  end

  private
  def map_params
    params.require(:map).permit(:title, :corp_id, :home_id, :layout)
  end

  def get_map
    corps = current_user.corps.pluck(:id)
    @map = Map.includes(:connections).where(corp_id: corps).find( params[:id] )
    gon.map = { id: @map.id, version: @map.updated_at.to_i }
  end
end
