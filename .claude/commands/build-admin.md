---
description: 코치용 관리자 화면 구현 (영상 등록, 응답 조회, 출석 현황)
allowed-tools: Bash, Read, Write
---

# 관리자(코치) 화면 구현

1. `Admin` 네임스페이스 라우트 및 `ApplicationController` 상속 + coach role 인증
2. `Admin::ContentsController`: 영상/질문 CRUD
3. `Admin::ResponsesController`: 참여자 응답 목록, 필터(주차/날짜/참여자)
4. `Admin::FeedbacksController`: 응답별 피드백 작성
5. 출석 현황 대시보드: 참여자별 스트릭 테이블 + 미응답자 표시
6. Turbo Frame으로 페이지 이동 없이 피드백 작성 가능하도록 구현

$ARGUMENTS 옵션 반영하세요.