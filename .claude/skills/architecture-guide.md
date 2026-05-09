---
description: 북살롱 Rails 아키텍처 및 컨벤션 가이드
---

# 아키텍처 가이드

## 구조 원칙
- **MVC 준수**: 비즈니스 로직은 Service Object (`app/services/`) 분리
- **네임스페이스**: 관리자 기능은 `Admin::` 네임스페이스
- **인증**: Devise 사용, role 컬럼으로 participant/coach 구분

## 핵심 모델 관계
```
User → has_many :responses, :feedbacks(as coach)
DailyContent → has_many :responses
Response → has_one :feedback
```

## 비동기 처리
- 메일 발송, PDF 생성 → Solid Queue (`deliver_later`, `perform_later`)
- 실시간 UI 업데이트 → Turbo Streams

## DB
- SQLite (개발/프로덕션 동일)
- Solid Cache로 스트릭 계산 결과 캐싱