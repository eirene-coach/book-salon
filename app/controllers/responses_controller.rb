class ResponsesController < ApplicationController
  def create
    @content = DailyContent.find(params[:daily_content_id])
    @enrollment = current_user.enrollments.find_by!(cohort: @content.cohort)
    @response = @enrollment.responses.find_or_initialize_by(daily_content: @content)

    if @response.update(response_params)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'response_form',
            partial: 'responses/success',
            locals: { response: @response }
          )
        end
        format.html { redirect_to dashboard_path, notice: '오늘도 연결됐어요 ✓' }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            'response_form',
            partial: 'responses/form',
            locals: { response: @response, content: @content }
          )
        end
        format.html { render 'missions/show' }
      end
    end
  end

  private

  def response_params
    params.require(:response).permit(:content, :is_public)
  end
end
