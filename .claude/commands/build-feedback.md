---
description: 코치 1:1 피드백 수신함 + 이메일 알림 구현
allowed-tools: Bash, Read, Write
---

# 피드백 수신함 & 이메일 알림 구현

1. `Feedback` 모델: response, coach(User), body(text), sent_at
2. `FeedbackMailer`: 피드백 등록 시 참여자에게 이메일 발송
3. Solid Queue로 메일 발송 비동기 처리 (`FeedbackMailer.with(...).deliver_later`)
4. 참여자 수신함 뷰: 응답별 피드백 스레드 형식 (Turbo Stream 실시간 업데이트)
5. 코치 피드백 작성 폼 (admin 네임스페이스)
6. 읽음 여부 표시 (`read_at` 컬럼)

$ARGUMENTS 옵션 반영하세요.