class RegistrationsController < Devise::RegistrationsController
  before_filter :exclude_wrong_roles, only: :create

  def new
    super
  end

  def create
    @user = User.new(registration_params)
    if @user.save
      redirect_to :root, notice: "Вы зарегистрировали пользователя"
    else
      render :new
    end
  end

  def update
    super
  end


  private

  def exclude_wrong_roles
    case params["commit"]
    when "Зарегистрировать водителя"
      params["user"].except!(:dispatcher_attributes)
    when "Зарегистрировать диспетчера"
      params["user"].except!(:driver_attributes)
    when "Зарегистрировать администратора"
      params["user"].except!(:driver_attributes, :dispatcher_attributes)
      params["user"]["admin_attributes"] = { }
    end
  end

  def registration_params
    params.require(:user).permit!
  end

end
