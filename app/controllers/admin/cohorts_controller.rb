module Admin
  class CohortsController < AdminController
    def index
      @cohorts = Cohort.includes(:program).order(created_at: :desc)
    end

    def show
      @cohort = Cohort.find(params[:id])
      @enrollments = @cohort.enrollments.includes(:user).where(payment_status: 'paid')
      @daily_contents = @cohort.daily_contents.order(:day_number)
      @attendance = @enrollments.map do |e|
        { user: e.user, count: e.responses.count, streak: calculate_streak(e) }
      end
    end

    def new
      @cohort = Cohort.new
      @programs = Program.all
    end

    def create
      @cohort = Cohort.new(cohort_params)
      if @cohort.save
        redirect_to admin_cohort_path(@cohort), notice: '기수가 생성됐습니다.'
      else
        @programs = Program.all
        render :new, status: :unprocessable_entity
      end
    end

    private

    def cohort_params
      params.require(:cohort).permit(:program_id, :start_date, :status)
    end

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
end
