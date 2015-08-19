class ListsController < ApplicationController
  before_action :set_list, only: [:show, :edit, :update, :destroy]

  # GET /lists
  # GET /lists.json
  def index
    @lists = List.all
  end

  # GET /lists/1
  # GET /lists/1.json
  # GET /lists/1.pdf
  def show
    @list = List.find_by(name: params[:id])
    @companies = @list.companies.desc(:roar)
    respond_to do |format|
      format.html 
      format.json 
      format.pdf
    end
  end

  # GET /lists/new
  def new
    @list = List.new
  end

  # GET /lists/1/edit
  def edit
    @list = List.find_by(name: params[:id])
    gon.list_companies = Company.unscoped.find(@list.company_ids).map {|c| {id: c._id, text: c.ticker } }
  end

  # POST /lists
  def create
    @list = List.new(name: params[:list][:name])
    companies_array = params[:list][:company_ids].split(",")
    @list.company_ids = companies_array if companies_array.size > 0

    respond_to do |format|
      if @list.save
        format.html { redirect_to list_path(@list.name), notice: 'List was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /lists/1
  # PATCH/PUT /lists/1.json
  def update
    @list = List.find_by(name: params[:id])
    company_ids = params[:list][:company_ids].split(",")
    respond_to do |format|
      if @list.update_attributes(name: params[:list][:name], company_ids: company_ids)
        format.html { redirect_to list_path(@list.name), notice: 'List was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lists/1
  # DELETE /lists/1.json
  def destroy
    @list.destroy
    respond_to do |format|
      format.html { redirect_to lists_url, notice: 'List was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_list
      @list = List.find_by(name: params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def list_params
      params.require(:list).permit(:name)
    end
end
