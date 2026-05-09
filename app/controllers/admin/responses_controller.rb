module Admin
  class ResponsesController < AdminController
    def update
      @response = Response.find(params[:id])
      if @response.update(feedback_text: params[:response][:feedback_text], feedback_at: Time.current)
        UserMailer.feedback_received(@response).deliver_later
        redirect_to admin_cohort_path(params[:cohort_id]), notice: '피드백이 전송됐어요 💌'
      else
        redirect_back fallback_location: admin_root_path, alert: '피드백 저장에 실패했습니다.'
      end
    end
  end
end
