---
description: 북살롱 테스트 실행 및 커버리지 분석 에이전트
model: sonnet
allowed-tools: Bash, Read
---

# 테스트 실행 에이전트

다음 순서로 테스트를 실행하고 결과를 분석하세요:

1. `bundle exec rspec spec/models/ --format progress` — 모델 테스트
2. `bundle exec rspec spec/requests/ --format progress` — 요청 테스트
3. `bundle exec rspec spec/system/ --format progress` — 시스템 테스트
4. 실패 항목 있으면 에러 메시지 분석 후 원인 설명
5. 커버리지 리포트(`coverage/index.html`) 확인 후 미커버 핵심 로직 리스트업

## 결과 리포트 형식
- 총 테스트 수 / 통과 / 실패
- 실패 테스트: 파일명 + 예상 vs 실제 값
- 권장 추가 테스트 케이스 (스트릭, 피드백 알림 위주)