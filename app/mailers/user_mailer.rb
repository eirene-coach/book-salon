class UserMailer < ApplicationMailer
  default from: 'coach@booksalon.kr'

  def feedback_received(response)
    @response = response
    @user = response.enrollment.user
    @content = response.daily_content
    mail(
      to: @user.email,
      subject: '[북살롱] 코치의 피드백이 도착했어요 💌'
    )
  end

  def program_reminder(user, content)
    @user = user
    @content = content
    mail(
      to: user.email,
      subject: '[북살롱] 오늘의 코칭, 아직 기다리고 있어요 📖'
    )
  end

  def payment_confirmation(user, cohort)
    @user = user
    @cohort = cohort
    @program = cohort.program
    mail(
      to: user.email,
      subject: '[북살롱] 결제가 완료됐어요! 이제 여정을 시작해요 📚'
    )
  end
end
