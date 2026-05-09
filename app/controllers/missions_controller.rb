class MissionsController < ApplicationController
  before_action :set_content_and_enrollment

  def show
    @response = @enrollment.responses.find_or_initialize_by(daily_content: @content)
  end

  private

  def set_content_and_enrollment
    @content = DailyContent.find(params[:id])
    @enrollment = current_user.enrollments.find_by!(cohort: @content.cohort)
  end
end
