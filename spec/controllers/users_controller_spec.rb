require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET index' do
    let(:user) { create(:user) }

    def do_request
      get :index, xhr: true
    end

    it 'renders the index template' do
      do_request

      expect(response).to render_template(:index)
    end

    it 'returns ok status' do
      do_request

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET new' do
    it 'renders the new template' do
      get :new

      expect(response).to render_template(:new)
    end

    it 'returns ok status' do
      get :new

      expect(response).to have_http_status(:ok)
    end

    it 'assigns user' do
      get :new

      expect(assigns(:user).class.name).to eq 'User'
    end
  end

  describe 'POST create' do
    let(:service) { instance_double(UserService, create: true, success?: true, record: instance_double(User, id: 99)) }
    let(:user_attributes) { attributes_for(:user) }
    let(:parameters) { { user: user_attributes } }

    before do
      allow(UserService).to receive(:new).and_return(service)
    end

    def do_post
      post :create, xhr: true, params: parameters
    end

    it 'initializes the user service' do
      do_post

      expect(UserService).to have_received(:new).with(to_strong_parameters(user_attributes))
    end

    it 'tries to create the user' do
      do_post

      expect(service).to have_received(:create)
    end

    it 'redirects to new user' do
      do_post

      expect(response).to redirect_to(new_user_url)
    end

    context 'with error' do
      let(:service) { instance_double(UserService, create: false, success?: false, errors: %w[foo bar]) }

      it 'returns the errors' do
        do_post

        expect(flash[:success]).not_to be_present
        expect(flash[:error]).to be_present
      end
    end

    context 'with success' do
      it 'returns success' do
        do_post

        expect(flash[:error]).not_to be_present
        expect(flash[:success]).to be_present
      end
    end
  end

  describe 'GET edit' do
    let(:user) { create(:user) }

    def do_edit
      get :edit, params: { id: user.id }
    end

    it 'renders the edit template' do
      do_edit

      expect(response).to render_template(:edit)
    end

    it 'returns ok status' do
      do_edit

      expect(response).to have_http_status(:ok)
    end

    it 'finds user' do
      expect(User).to receive(:find).with(user.id.to_s).and_return(user)

      do_edit
    end

    it 'assigns user' do
      do_edit

      expect(assigns(:user)).to eq(user)
    end
  end

  describe 'PUT update' do
    let(:user) { create(:user) }
    let(:service) { instance_double(UserService, update: true, success?: true, record: instance_double(User, id: 99)) }
    let(:user_attributes) { attributes_for(:user) }
    let(:parameters) { { user: user_attributes } }

    def do_put
      put :update, xhr: true, params: parameters.merge(id: user.id)
    end

    before do
      allow(UserService).to receive(:new).and_return(service)
    end

    it 'initializes the user service' do
      do_put

      expect(UserService).to have_received(:new).with(to_strong_parameters(user_attributes))
    end

    it 'tries to update the user' do
      do_put

      expect(service).to have_received(:update)
    end

    it 'redirects to edit user' do
      do_put

      expect(response).to redirect_to(edit_user_url)
    end

    context 'with error' do
      let(:service) { instance_double(UserService, update: false, success?: false, errors: %w[foo bar]) }

      it 'returns the errors' do
        do_put

        expect(flash[:success]).not_to be_present
        expect(flash[:error]).to be_present
      end
    end

    context 'with success' do
      it 'returns success' do
        do_put

        expect(flash[:error]).not_to be_present
        expect(flash[:success]).to be_present
      end
    end
  end

  describe 'DELETE destroy' do
    let(:user) { create(:user) }
    let(:service) { instance_double(UserService, destroy: true, success?: true) }

    def do_delete
      delete :destroy, params: { id: user.id }
    end

    before do
      allow(UserService).to receive(:new).and_return(service)
    end

    it 'initializes the user service' do
      do_delete

      expect(UserService).to have_received(:new)
    end

    it 'tries to delete the user' do
      do_delete

      expect(service).to have_received(:destroy)
    end

    context 'with error' do
      let(:service) { instance_double(UserService, destroy: false, success?: false, errors: %w[foo bar]) }

      it 'returns the errors' do
        do_delete

        expect(flash[:error]).to be_present
      end
    end

    context 'with success' do
      it 'returns no errors' do
        do_delete

        expect(flash[:error]).not_to be_present
      end
    end
  end

  describe 'DELETE delete_picture_attachment' do
    let(:user) { create(:user, :with_picture) }
    let(:picture) { user.picture }

    def do_delete
      delete :delete_picture_attachment, params: { id: picture.id }
    end

    it 'finds picture' do
      expect(ActiveStorage::Attachment).to receive(:find).with(picture.id.to_s).and_return(picture)
      expect(picture).to receive(:purge).and_return(true)

      do_delete
    end

    it 'redirects to edit user' do
      do_delete

      expect(response).to redirect_to(edit_user_url(user))
    end

    context 'with error' do
      before do
        allow(ActiveStorage::Attachment).to receive(:find).and_raise('foo')
      end

      it 'returns the errors' do
        do_delete

        expect(flash[:error]).to be_present
      end
    end

    context 'with success' do
      it 'destroy picture' do
        do_delete
  
        expect(user.reload.picture.attached?).to be_falsey
      end
    end
  end

  private

  def to_strong_parameters(params)
    ActionController::Parameters.new(params).permit!.tap do |whitelisted|
      stringify_values(whitelisted)
    end
  end

  def stringify_values(values)
    values.transform_values! do |value|
      if value.is_a?(ActionController::Parameters)
        stringify_values(value)
      elsif value.is_a?(Array)
        value.map { |element| stringify_values(element) }
      elsif [Rack::Test::UploadedFile, ActionDispatch::Http::UploadedFile].include?(value.class)
        value
      else
        value.to_s
      end
    end
  end
end
