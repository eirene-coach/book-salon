---
description: 북살롱 테스트 작성 가이드 (RSpec + Capybara)
---

# 테스트 가이드

## 기본 원칙
- 모델: RSpec unit test, validations/associations/scopes 검증
- 컨트롤러: request spec으로 인증/권한 확인
- 통합: System spec (Capybara) for 주요 사용자 플로우

## 핵심 테스트 케이스
1. 응답 제출 → Turbo Stream으로 확인 메시지 렌더링
2. 피드백 등록 → 이메일 큐에 잡 추가 확인
3. 스트릭 계산 로직 (연속/비연속 응답 케이스)
4. coach role만 admin 접근 가능 확인

## 팩토리
```ruby
FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    role { :participant }
  end
end
```
- `rails_helper.rb`에 FactoryBot, Shoulda Matchers 설정