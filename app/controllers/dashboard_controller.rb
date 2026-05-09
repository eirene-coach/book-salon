class DashboardController < ApplicationController
  def index
    @enrollment = current_user.enrollments
                              .joins(:cohort)
                              .where(cohorts: { status: 'active' }, payment_status: 'paid')
                              .first

    if @enrollment
      @cohort = @enrollment.cohort
      days_elapsed = (Date.today - @cohort.start_date.to_date).to_i + 1
      @today_content = @cohort.daily_contents.find_by(day_number: days_elapsed)
      @today_response = @enrollment.responses.find_by(daily_content: @today_content) if @today_content
      @streak = calculate_streak(@enrollment)
      total_days = @cohort.program.duration_weeks * 7
      submitted_count = @enrollment.responses.count
      @progress_percent = [(submitted_count.to_f / total_days * 100).round, 100].min
    end
  end

  private

  def calculate_streak(enrollment)
    responses = enrollment.responses.order(created_at: :desc)
    streak = 0
    check_date = Date.today
    responses.each do |r|
      if r.created_at.to_date == check_date
        streak += 1
        check_date -= 1.day
      else
        break
      end
    end
    streak
  end
end
