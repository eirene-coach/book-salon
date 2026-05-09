module Admin
  class DailyContentsController < AdminController
    before_action :set_cohort
    before_action :set_content, only: [:edit, :update, :destroy]

    def new
      @content = DailyContent.new(cohort: @cohort, day_number: params.dig(:daily_content, :day_number))
    end

    def create
      @content = @cohort.daily_contents.build(content_params)
      if @content.save
        redirect_to admin_cohort_path(@cohort), notice: "Day #{@content.day_number} 콘텐츠가 등록됐습니다."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @content.update(content_params)
        redirect_to admin_cohort_path(@cohort), notice: "Day #{@content.day_number} 콘텐츠가 수정됐습니다."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      day = @content.day_number
      @content.destroy
      redirect_to admin_cohort_path(@cohort), notice: "Day #{day} 콘텐츠가 삭제됐습니다."
    end

    private

    def set_cohort
      @cohort = Cohort.find(params[:cohort_id])
    end

    def set_content
      @content = @cohort.daily_contents.find(params[:id])
    end

    def content_params
      params.require(:daily_content).permit(:day_number, :video_url, :question_text)
    end
  end
end
