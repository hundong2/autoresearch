# 검증 기록

작성일: 2026-09-25 · [학습 목차](../README.md#한국어-학습-경로)

## 환경

Windows, Git Bash (`MINGW64_NT-10.0-26200`), Node.js 22.18.0. 테스트 프로세스 PATH에서 Git Bash를 선택했고 전역 환경변수는 변경하지 않았다. 추가 npm 의존성이나 Python 패키지는 설치하지 않았다.

## 실행 결과

| 검사 | 결과 |
| --- | --- |
| `bash tests/test-orchestrator.sh` | 195/195 통과 |
| `bash tests/test-regression.sh` | 65/65 통과 |
| `bash tests/test-hooks.sh` | 228/228 통과 |
| `bash tests/test-maintenance.sh` | 50/50 통과 |
| `bash guide/examples/01_classify.sh` | 5/5 통과 |
| `bash guide/examples/02_state.sh` | 9/9 통과 |
| `bash guide/examples/03_regression.sh` | 3/3 통과 |
| Archify showcase | 9/9, 오류 0, 경고 0 |
| Archify browser | 네 viewport containment 통과 |
| Archify perceptual review | light/dark PNG 네 장 실제 확인 |

원본 4 suite는 총 538개, 새 실습은 총 17개 assert가 통과했다. maintenance는 임시 checkout과 가짜 git/gh로 release 준비를 검증한다. 테스트 출력의 “push/PR 통과”는 **mock 호출 검사**이며 실제 PR이나 릴리스가 생성된 것이 아니다. 설치 smoke 역시 폐기 가능한 config-dir를 사용했고 사용자 개인 설치는 하지 않았다.

실제 LLM 호출·무한 루프·자동 배포·유료 API·프로덕션 DB 연결·모델 품질 평가는 수행하지 않았다. Bash 계약 검증을 모델 종단간 검증으로 과장하지 않는다.

## 번역·내용 대조

원본 README 전체 섹션, 14개 명령, 설치 방식, Guard, TSV, 복구, FAQ, 기여/저자를 확인했다. 반복 소개는 합치고 링크·옵션·수치·라이선스를 보존했다. 원본 guide 목록을 삭제하지 않고 한국어 입문 경로를 앞에 추가했다.

현재 코드와 원문 설명이 다른 부분은 학습자 주로 구별했다. 특히 AGENTS의 오래된 unlimited 기본 설명, README의 과거 41줄/12개 파일, Guard 재시도, DB 접미사 검사, SCORE의 분류 처리에 주의한다. upstream의 토큰·성능 주장은 따로 재현하지 않았다.

원본·한국어 README, guide 시작점과 새 문서 등 Markdown 10개의 상대 링크·anchor 95개를 검사했고 깨진 참조는 없었다. 스테이징의 `git diff --cached --check`와 실습 세 파일 각각의 Bash 구문 검사도 통과했다.

## 아키텍처 증거

[docs/archify/README.md](../../docs/archify/README.md)에 명세·산출물 SHA256, 15개 소스 참조, 자동 브라우저와 시각 검수 상태를 기록했다. Viewer 고정 UI는 영어 fallback이며 도식의 설명은 한국어다.
