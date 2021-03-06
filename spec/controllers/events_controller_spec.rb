require 'spec_helper'

describe EventsController do
  let(:user) {FactoryGirl.create(:registered_user, email: 'blah@gmail.com')}
  let(:event) {FactoryGirl.create(:event)}

  before do 
    user.events << event
  end

  def log_in_user(user)
    session[:id] = user.id
  end

  describe "Get #show" do

    it 'assigns the requested event to @event' do
      get :show, id: event.id
      expect(response).to render_template(:show) 
    end

    context 'as the events host' do
      before(:each) do
        log_in_user(user)
      end

      it 'renders events#show' do
        get :show, id: event.id
        expect(assigns(:event)).to eq event
      end
    end


    context 'as a guest' do
      it 'renders events#show' do
        guest = FactoryGirl.create(:guest)
        log_in_user(guest)
        get :show, id: event.id
        expect(response).to render_template(:show) 
      end
    end
  end

  describe "Get #invitation" do

    it 'assigns the requested event to @event' do
      get :show, id: event.id
      expect(response).to render_template(:show) 
    end

    context 'as the events host' do
      it 'renders events#show' do
        log_in_user(user)
        get :invitation, id: event.url
        expect(response).to render_template(:show) 
      end
    end


    context 'as a guest' do
      it 'renders events#show' do
        guest = FactoryGirl.create(:guest)
        log_in_user(guest)
        get :invitation, id: event.url
        expect(response).to render_template(:show) 
      end
    end
  end

  describe 'Get #new' do

    it 'redirects if there is not a current user' do
      get :new, event: attributes_for(:invalid_event)
      expect(response).to redirect_to(root_path)
    end

    it 'renders the correct view' do
      log_in_user(user)
      get :new, id: event.url
      expect(response).to render_template(:new) 
    end
  end

  describe 'Get #edit' do
    
    it 'assigns the requested event to @event' do
      get :edit, id: event.id
      expect(assigns(:event)).to eq event
    end 

    context 'as a guest viewer' do
      it 'redirects to invitation view' do
        guest = FactoryGirl.create(:guest)
        log_in_user(guest)
        get :edit, id: event.id
        expect(response).to redirect_to(invitation_path(event.url))
      end
    end

    context 'as event host' do
      it 'renders events#edit' do
        log_in_user(user)
        get :edit, id: event.id
        expect(response).to render_template(:edit)
      end
    end
  end

  describe 'Post #create' do 
    
    it 'redirects if there is not a current user' do
      post :create, event: attributes_for(:invalid_event)
      expect(response).to redirect_to(root_path)
    end

    context 'with valid attributes' do

      before(:each) do
        log_in_user(user)
      end

      it 'saves a new event in the database' do
        expect{post :create, event: attributes_for(:event)}.to change(Event, :count).by 1
      end
    end

    context'with invalid attributes' do 

      before(:each) do
        log_in_user(user)
      end

      it 'does not saves a new event in the database' do
        expect{post :create, event: attributes_for(:invalid_event)}.to change(Event, :count).by 0
      end
    end
  end

  describe 'Post #create' do
    before(:each) do 
      event = create(:event)
    end
    
  end

end