class PricesController < ApplicationController
  before_action :set_price, only: [:show, :edit, :update, :destroy]

  # GET /companies/[:company_id]/prices - not active
  # GET /companies/[:company_id]/prices.json
  # GET /companies/[:company_id]/prices.csv
  # GET /companies/[:company_id]/prices.xml
  def index
    #@prices = Price.where(company_id: params[:company_id])
    #@prices = Price.all_in(company_id: params[:company_id])
    @c_ids = params[:company_id]
    @c_ids = [@c_ids] if @c_ids.is_a?(String)
    @prices = Price.where(company_id: {'$in': @c_ids})
    respond_to do |format|  
      #format.json { render json: @prices, 
      #  only: [:company_id, :date, :open, :high, :low, :close, :volume] }
      #format.json { render json: @prices }
#      format.csv { render text: @prices.to_to_csv }
#      format.xml { render xml: @prices, only: [:date, :open, :high, :low, :close, :volume] }
#      format.html 
      format.json 
    end  
  end

  # GET /prices/1
  # GET /prices/1.json
  def show
  end

  # GET /prices/new
  def new
    @price = Price.new
  end

  # GET /prices/1/edit
  def edit
  end

  # POST /prices
  # POST /prices.json
  def create
    @price = Price.new(price_params)

    respond_to do |format|
      if @price.save
        format.html { redirect_to @price, notice: 'Price was successfully created.' }
        format.json { render :show, status: :created, location: @price }
      else
        format.html { render :new }
        format.json { render json: @price.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /prices/1
  # PATCH/PUT /prices/1.json
  def update
    respond_to do |format|
      if @price.update(price_params)
        format.html { redirect_to @price, notice: 'Price was successfully updated.' }
        format.json { render :show, status: :ok, location: @price }
      else
        format.html { render :edit }
        format.json { render json: @price.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /prices/1
  # DELETE /prices/1.json
  def destroy
    @price.destroy
    respond_to do |format|
      format.html { redirect_to prices_url, notice: 'Price was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_price
      @price = Price.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def price_params
      params.require(:price).permit(:date, :open, :high, :low, :close, :volume)
    end
end
