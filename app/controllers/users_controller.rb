class UsersController < ApplicationController
  respond_to :json, :html
  before_filter :logged_in?, :only => [:show, :edit, :update, :destroy, :your_profile]
  before_filter :load_and_authorize_user, :only => [:show, :edit, :update, :destroy]

  def your_profile
    @user = current_user
    @event = Event.new
    @event.event_items.build.item = Item.new
    render :show
  end

  def simple_login
    @login_error = session[:login_error]
  end

  def create_guest
    @user = User.find_by_email(person_params[:email]) 
    items = person_params[:items]
    if @user
      puts 'here'
      # items.each do |e| 
      #   p e.amountToBring
      #   @user.assigned_items << AssignedItem.new(quantity_provided: :amountToBring, 
      #     event_item_id: :id, event_id: :eventId )
      # end
    else
      puts 'in there else'
      @user = User.new
      @user.name = person_params[:name]
      @user.email = person_params[:email]
      @user.guest = true
      @user.save!
      # items.each do |e|
      #   @user.assigned_items << AssignedItem.new(quantity_provided: :amountToBring, 
      #     event_item_id: :id, event_id: :eventId )
      # end
    end 
    if @user.save
      redirect_to guest_path(@user.url) 
    else 
      puts @user.errors.full_messages
    end
  end

  def create 
    @user = User.new(person_params)
    if @user.save
      session[:id] = @user.id
      redirect_to your_profile_path
    else
      puts @user.errors.messages
      redirect_to login_path
    end 
  end

  def destroy
    @user.destroy
  end

  def guest
    @user = User.find_by_url(params[:url])
    render 'show'
  end

  private

  def person_params
    params.require(:user).permit(:name, :email, :guest, :password, :password_confirmation, 
      "items" => [:name, :description, :id, :amountPromised, :quantity, :amountToBring, :eventId, :stillNeeded]
      )
  end
end