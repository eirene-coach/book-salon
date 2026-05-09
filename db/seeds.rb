# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

User.find_or_create_by(email: "coach@booksalon.kr") do |u|
  u.name = "코치"
  u.role = "admin"
  u.password = "password123"
  u.password_confirmation = "password123"
end

puts "코치 계정 생성 완료: coach@booksalon.kr / password123"

# 테스트용 Program + Cohort + DailyContent + Enrollment
program = Program.find_or_create_by(title: '4주 북코칭') do |p|
  p.description = '책 한 챕터로 자기 방향을 발견하는 4주 프로그램'
  p.price = 99000
  p.duration_weeks = 4
end

cohort = Cohort.find_or_create_by(program: program, start_date: Date.today) do |c|
  c.status = 'active'
end

DailyContent.find_or_create_by(cohort: cohort, day_number: 1) do |dc|
  dc.video_url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'
  dc.question_text = '오늘 이 챕터를 읽으면서 가장 마음에 닿은 문장은 무엇인가요?'
end

member = User.find_or_create_by(email: 'member@booksalon.kr') do |u|
  u.name = '테스트 수강생'
  u.role = 'member'
  u.password = 'password123'
  u.password_confirmation = 'password123'
end

Enrollment.find_or_create_by(user: member, cohort: cohort) do |e|
  e.payment_status = 'paid'
end

puts '테스트 데이터 생성 완료'
