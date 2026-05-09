---
description: 북살롱 코드 스타일 및 Hotwire/Tailwind 패턴 가이드
---

# 코드 스타일 가이드

## Rails 컨벤션
- 컨트롤러는 7 actions 이내 유지, 복잡한 쿼리는 scope 또는 Service로 분리
- 뷰 헬퍼 대신 ViewComponent 또는 partial 사용

## Hotwire 패턴
```erb
<%# Turbo Frame으로 폼 응답 처리 %>
<turbo-frame id="response-form">
  <%= render 'form', response: @response %>
</turbo-frame>
```
- 성공 시 `turbo_stream.replace`로 확인 메시지 교체
- Stimulus: 버튼 중복 클릭 방지, 로딩 상태 관리

## Tailwind
- 모바일 퍼스트 (`sm:`, `md:` 순서)
- 컬러: 따뜻한 톤 (warm-50, orange-400 계열)
- 버튼 공통 클래스: `btn-primary` 커스텀 컴포넌트 정의