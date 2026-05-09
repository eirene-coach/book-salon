---
description: 참여 스트릭, 4주 여정 일지, 수료 PDF 다운로드 구현
allowed-tools: Bash, Read, Write
---

# 스트릭 & 여정 일지 & PDF 구현

1. `StreakService`: 유저 응답 기록으로 연속 참여일 계산
2. 4주 캘린더 그리드 컴포넌트 (ViewComponent 또는 partial)
3. 스트릭 시각화: 응답 완료일은 초록 원, 미완료는 회색
4. `JournalController`: 4주 응답 전체 조회 뷰
5. 수료 조건 체크 (28일 중 N일 이상 응답)
6. `CertificatePdfJob`: Solid Queue 비동기로 PDF 생성 (Prawn 또는 WickedPdf)
7. 다운로드 링크 이메일 발송

$ARGUMENTS 옵션 반영하세요.