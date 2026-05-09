class PaymentsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new]

  def new
    @cohort = Cohort.find(params[:cohort_id])
    @program = @cohort.program
    @order_id = "booksalon_#{current_user&.id}_#{@cohort.id}_#{Time.current.to_i}"
  end

  def success
    payment_key = params[:paymentKey]
    order_id    = params[:orderId]
    amount      = params[:amount].to_i

    result = confirm_payment(payment_key, order_id, amount)

    if result[:success]
      cohort_id = params[:cohort_id]
      cohort = Cohort.find(cohort_id)

      enrollment = current_user.enrollments.find_or_initialize_by(cohort: cohort)
      enrollment.payment_status = "paid"
      enrollment.save!

      UserMailer.payment_confirmation(current_user, cohort).deliver_later

      redirect_to dashboard_path, notice: "결제가 완료됐어요! 지금 바로 시작해보세요 🎉"
    else
      redirect_to fail_payments_path, alert: "결제 승인 실패: #{result[:error]}"
    end
  end

  def fail
    @error_message = params[:message] || "결제에 실패했습니다."
  end

  private

  def confirm_payment(payment_key, order_id, amount)
    require "net/http"
    require "uri"
    require "base64"
    require "json"

    uri = URI("https://api.tosspayments.com/v1/payments/confirm")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10

    request = Net::HTTP::Post.new(uri)
    request["Authorization"] = "Basic " + Base64.strict_encode64("#{ENV['TOSS_SECRET_KEY']}:")
    request["Content-Type"] = "application/json"
    request.body = { paymentKey: payment_key, orderId: order_id, amount: amount }.to_json

    response = http.request(request)
    parsed = JSON.parse(response.body)

    if response.code == "200"
      { success: true, data: parsed }
    else
      Rails.logger.error "Toss Payment Error: #{parsed}"
      { success: false, error: parsed["message"] || "알 수 없는 오류" }
    end
  rescue => e
    Rails.logger.error "Payment Network Error: #{e.message}"
    { success: false, error: e.message }
  end
end
