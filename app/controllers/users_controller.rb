class UsersController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :load_user, only: %i[edit]

  def index
    respond_to do |format|
      format.html
      format.json { render json: UserDatatable.new(params) }
    end
  end

  def new
    @user = User.new
  end

  def create
    service = UserService.new(create_params)

    service.create

    if service.success?
      flash[:success] = 'Usuário criado com sucesso!'
    else
      flash[:error] = service.errors.join(', ')
    end

    redirect_to action: :new
  end

  def edit; end

  def update
    service = UserService.new(update_params)

    service.update(record_id)

    if service.success?
      flash[:success] = 'Usuário alterado com sucesso!'
    else
      flash[:error] = service.errors.join(', ')
    end
    redirect_to action: :edit
  end

  def destroy
    service = UserService.new

    service.destroy(record_id)

    unless service.success?
      flash[:error] = service.errors.join(', ')
    end

    redirect_to action: :index
  end

  def delete_picture_attachment
    picture = ActiveStorage::Attachment.find(params[:id])
    picture.purge

    redirect_back(fallback_location: { action: 'edit', id: picture.record.id })
  rescue StandardError => e
    flash[:error] = e.message
    redirect_back(fallback_location: { action: 'edit' })
  end

  protected

  def create_params
    params.require(:user).permit(:name, :email, :gender, :picture)
  end

  def update_params
    create_params
  end

  def record_id
    params[:id]
  end

  def load_user
    @user = User.find(record_id)
  end
end
