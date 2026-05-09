module Admin
  class DailyContentsController < AdminController
    def new
      @cohort = Cohort.find(params[:cohort_id])
      @content = DailyContent.new(cohort: @cohort)
    end

    def create
      @cohort = Cohort.find(params[:cohort_id])
      @content = @cohort.daily_contents.build(content_params)
      if @content.save
        redirect_to admin_cohort_path(@cohort), notice: "Day #{@content.day_number} 콘텐츠가 등록됐습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def content_params
      params.require(:daily_content).permit(:day_number, :video_url, :question_text)
    end
  end
end
