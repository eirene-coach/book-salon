---
description: 오늘의 코칭 영상 + 텍스트 응답 폼 기능 구현
allowed-tools: Bash, Read, Write
---

# 코칭 영상 & 응답 폼 구현

아래 기능을 순서대로 구현하세요:

1. `DailyContent` 모델: title, video_url(YouTube/Vimeo), question, week, day
2. `Response` 모델: user, daily_content, body(text), submitted_at
3. `CoachingController#show`: 오늘 날짜 기준 콘텐츠 조회
4. YouTube/Vimeo URL을 embed URL로 변환하는 헬퍼 메서드
5. Turbo Frame으로 응답 폼 구현 → 제출 즉시 '오늘도 연결됐어요 ✓' 메시지 표시
6. Stimulus 컨트롤러로 제출 버튼 로딩 상태 처리

$ARGUMENTS 옵션 반영하세요.