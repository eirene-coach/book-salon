module Admin
  class DashboardController < AdminController
    def index
      @active_cohorts = Cohort.where(status: 'active').includes(:program, :enrollments)
      @total_members = User.where(role: 'member').count
      @pending_feedbacks = Response.where(feedback_text: nil)
                                    .joins(enrollment: :cohort)
                                    .where(cohorts: { status: 'active' })
                                    .count
    end
  end
end
