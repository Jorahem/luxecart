# Pundit policy skeleton. Create resource-specific policies under app/policies/
class AdminPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user&.admin?
  end

  def create?
    user&.super_admin?
  end

  def update?
    user&.super_admin? || user&.admin?
  end

  def destroy?
    user&.super_admin?
  end
end