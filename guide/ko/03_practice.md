# 03. 코드 읽기와 단계별 실습

작성일: 2026-09-25 · [목차](../README.md#한국어-학습-경로)

## 코드 리뷰

| 경로 | 역할 | 확인할 관계 |
| --- | --- | --- |
| `.claude/skills/autoresearch/SKILL.md` | 모드·명령 라우터 | 설치된 스킬 기준으로 helper 경로 해석 |
| `.claude/commands/autoresearch.md` | Classic 계약 | commit → verify → Guard → keep/revert → TSV |
| `scripts/orchestrate.sh` | 결정적 CLI | case dispatch → 각 함수 → stdout/exit |
| `scripts/score-regression.sh` | 회귀 점수 reducer | TSV 15열 → AWK 검증·HARD/SCORE → 판정 |
| `.claude/hooks/autoresearch/` | 이벤트 보호·문맥 | hooks.json → wrapper → Node CJS → 유틸 |
| `scripts/transform.sh` | 패키지 생성 | canonical → 플랫폼별 문구 변환·helper 복사 |
| `scripts/install.sh` | 호스트 설치 | Node 전제 확인 → 선택 경로 복사·설정 병합 |
| `tests/` | 실행 계약 | fixture와 실제 CLI 종료 코드 검증 |

## 1. 목표 분류

[01_classify.sh](../examples/01_classify.sh)는 영어 입력과 한국어 입력을 비교한다. `secure`가 `fix`보다 우선하므로 “fix insecure code”는 `harden`이다. “로그인 오류 수정”은 현재 휴리스틱에서 `explore`다. 예상 결과를 바꿔 볼 때 코드의 분류 우선순위와 함께 설명한다. 모델 품질을 테스트하는 것이 아니다.

## 2. 라우팅과 pinned predicate

[02_state.sh](../examples/02_state.sh)는 세 fixture에 `validate-state` → `screen-state-predicate` → `next-hop` 순서로 접근한다. 읽은 predicate 문자열은 **실행하지 않는다**. 오류가 있으면 fix, 오류가 없지만 독립 확인이 남았으면 verify, 모두 정리되면 DONE이다.

`validate-state`는 goal/archetype/predicate/terminal_choice 문자열, cycle 정수, 두 배열을 확인한다. 전체 도메인 스키마를 완전히 검증하는 함수는 아니다. 라우터의 숫자/문자 추출에는 grep이 쓰이므로 중복 키·중첩 JSON에 주의한다.

## 3. 회귀 판정

[03_regression.sh](../examples/03_regression.sh)는 원본 테스트 fixture를 읽어 다음 계약을 확인한다.

| fixture | 의미 | 예상 |
| --- | --- | --- |
| green-to-red.tsv | 기존 정상 기능이 깨짐 | UNSTABLE, exit 1 |
| red-to-red.tsv | 기존 오류 유지 | STABLE, exit 0 |
| 없는 경로 | 데이터 없음 | ERROR, exit 2 |

red→red의 STABLE은 “기존 결함이 없다”가 아니다. 비교 기준상 새 HARD 회귀가 없다는 뜻이다. 전체 차원이 실행되었는지는 `dims_ran`·`dims_unavailable`에서 확인한다.

## 심화 과제

1. 제공 fixture를 별도 작업용 복사본에서 변경해 `pending_verify`의 우선순위를 확인한다.
2. performance 점수만 94와 95로 넣어 경계 판정을 비교한다. 파일은 반드시 15열 TSV다.
3. 기준선이 전혀 없는 경우를 테스트하고 “데이터 없음”을 성공으로 처리하지 않는다.
4. 호스트를 실제 설치한 테스트 프로젝트에서만 세 번의 모델 반복을 수행해 품질·비용을 별도로 기록한다.

예제 fixture는 학습용 합성 상태이며 실전 모델 실행 결과가 아니다. 제품 코드나 기존 검증 fixture를 과제 중 직접 덮어쓰지 않는다.
