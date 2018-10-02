class SubscriptionHistoriesController < ApplicationController
  before_action :set_subscription_history, only: [:show, :update, :destroy]

  # GET /subscription_histories
  def index
    @subscription_histories = SubscriptionHistory.all

    render json: @subscription_histories
  end

  # GET /subscription_histories/1
  def show
    render json: @subscription_history
  end

  # POST /subscription_histories
  def create
    @subscription_history = SubscriptionHistory.new(subscription_history_params)

    if @subscription_history.save
      render json: @subscription_history, status: :created, location: @subscription_history
    else
      render json: @subscription_history.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subscription_histories/1
  def update
    if @subscription_history.update(subscription_history_params)
      render json: @subscription_history
    else
      render json: @subscription_history.errors, status: :unprocessable_entity
    end
  end

  # DELETE /subscription_histories/1
  def destroy
    @subscription_history.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscription_history
      @subscription_history = SubscriptionHistory.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def subscription_history_params
      params.require(:subscription_history).permit(:canceled_times)
    end
end
