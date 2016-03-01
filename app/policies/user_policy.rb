class UserPolicy < ApplicationPolicy
  def edit?
    user == record || user.is_admin?
  end

  def update?
    user == record || user.is_admin?
  end

  def destroy?
    return false if user == record

    user.is_admin?
  end
end