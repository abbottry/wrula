class AdminPolicy < Struct.new(:user, :is_admin)

  def site_admin?
    user.is_admin?
  end

  def index?
    site_admin?
  end

  def show?
    site_admin?
  end

  def create?
    site_admin?
  end

  def new?
    site_admin?
  end

  def update?
    site_admin?
  end

  def edit?
    site_admin?
  end

  def destroy?
    site_admin?
  end

end