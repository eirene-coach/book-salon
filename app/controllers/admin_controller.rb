class AdminController < ApplicationController
  before_action :require_admin!

  private

  def require_admin!
    redirect_to root_path, alert: '접근 권한이 없습니다.' unless current_user.admin?
  end
end
