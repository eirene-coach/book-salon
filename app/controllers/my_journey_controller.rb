class MyJourneyController < ApplicationController
  def index
    @enrollment = current_user.enrollments
                              .joins(:cohort)
                              .where(payment_status: 'paid')
                              .order('cohorts.start_date desc')
                              .first

    if @enrollment
      @responses = @enrollment.responses
                               .includes(:daily_content)
                               .order('daily_contents.day_number asc')
      total_days = @enrollment.cohort.program.duration_weeks * 7
      @completed = @responses.count >= total_days
      @unread_feedbacks = @responses.where.not(feedback_text: [nil, '']).count
    end
  end

  def download
    redirect_to my_journey_path, notice: 'PDF 기능은 준비 중입니다.'
  end
end
