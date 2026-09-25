# Autoresearch

작성일·원문 확인일: 2026-09-25

[English](README.md) · [한국어 학습 가이드](guide/README.md#한국어-학습-경로) · [코드 아키텍처](docs/archify/README.md)

원문: [hundong2/autoresearch](https://github.com/hundong2/autoresearch), revision `050e30dc4ba0974b03f2873111b9901ec3211390`, 표시 버전 2.2.2. upstream은 [uditgoenka/autoresearch](https://github.com/uditgoenka/autoresearch)이며 MIT 라이선스다. 아래는 원본 README의 섹션 순서와 사용 계약을 따른 한국어 번역이다. 반복되는 안내는 합쳤으며, 설치 대상과 프로젝트 이름은 원문대로 유지했다. 분석자의 보충은 `학습자 주`로 구분한다.

[![Claude Code](https://img.shields.io/badge/Claude_Code-Skill-blue)](https://docs.anthropic.com/en/docs/claude-code)
[![OpenCode](https://img.shields.io/badge/OpenCode-Skill-purple)](https://opencode.ai)
[![Codex](https://img.shields.io/badge/Codex-Skill-green)](https://developers.openai.com/codex)
[![Version](https://img.shields.io/badge/version-2.2.2-blue.svg)](https://github.com/uditgoenka/autoresearch/releases)
[![MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Claude Code, OpenCode 또는 OpenAI Codex를 끈질기게 개선을 반복하는 도구로 바꾼다. [Karpathy의 autoresearch](https://github.com/karpathy/autoresearch)에 기반한다. 범위 제한, 기계적으로 측정하는 지표, 자율 반복을 결합해 개선을 축적하는 방식이다. 목표를 정하면 에이전트가 반복 작업을 수행한다. 핵심은 AGI가 아니라 목표·지표·반복이다.

세 플랫폼에 핵심 스킬, 번들 런타임, 설치·검증 기능이 제공된다. **훅 기반 보호 기능은 Claude Code 전용**이다.

v2.2.0부터 자연어 목표를 `/autoresearch`에 주면 목표를 분류하고 성공 판정 조건을 도출한 다음 한 번 확인받아 하위 명령들을 반복한다. `Metric:` 또는 `Verify:`가 있는 호출은 기존 Classic 루프를 사용한다. [Orchestrator 안내](guide/autoresearch-orchestrator.md).

## 목차

- [프로젝트의 배경](#프로젝트의-배경)
- [작동 방식](#작동-방식)
- [훅과 안전성](#훅과-안전성)
- [명령](#명령)
- [빠른 시작](#빠른-시작)
- [명령별 상세](#명령별-상세)
- [Guard와 결과 기록](#guard와-결과-기록)
- [장애 복구](#장애-복구)
- [저장소 구조](#저장소-구조)
- [자주 묻는 질문](#자주-묻는-질문)
- [기여·라이선스·저자](#기여라이선스저자)

## 프로젝트의 배경

원문은 Karpathy의 630줄 Python 스크립트가 단일 지표·제한된 범위·빠른 검증·자동 되돌리기·Git 기록으로 밤새 100번의 ML 실험을 수행한 사례를 출발점으로 설명한다. 이 프로젝트는 그 방식을 코드, 콘텐츠, 마케팅, 영업, HR, DevOps 등 수치화할 수 있는 분야로 일반화한다.

원문은 v2.1.0에서 813줄의 단일 SKILL.md를 얇은 라우터와 자체 완결형 명령 파일로 나누었으며, 호출 토큰을 약 100K에서 5–8K로 줄여 95% 절감했다고 설명한다.

학습자 주: 실험 횟수·토큰 절감은 원문 주장이지 이 fork에서 측정한 결과가 아니다. README에 남아 있는 41줄·12개 파일 등의 과거 설명은 현재 파일 수와 일치하지 않을 수 있다. 현재 명령 표는 14개다.

## 작동 방식

```text
N회 또는 목표 달성까지 반복:
1. 현재 상태, Git 이력, 결과 로그 검토
2. 성공·실패·미시도 방식을 바탕으로 다음 변경 선정
3. 하나의 집중된 변경 수행
4. 검증 전에 실험 커밋
5. 테스트·벤치마크·점수로 기계적 검증
6. 개선되면 유지, 악화되면 git revert, 오류면 수정 또는 건너뜀
7. 결과 기록
8. 반복
```

개선은 누적되고 실패는 되돌리며 진행은 TSV로 기록한다. 시작할 때는 범위 내 파일 읽기 → 목표 정의 → 수정 가능/읽기 전용 범위 정의 → 기준선 측정(iteration 0) → 설정 확인을 수행한다.

### 여덟 가지 핵심 규칙

| 규칙 | 의미 |
| --- | --- |
| 기본은 유한 반복 | 무제한은 `Iterations: unlimited`로 명시 |
| 쓰기 전에 읽기 | 전체 맥락을 먼저 이해 |
| 반복당 변경 하나 | 실패 원인을 추적할 수 있는 원자적 변경 |
| 기계적 검증 | 주관적인 인상이 아닌 지표 사용 |
| 자동 복구 | 실패한 변경 되돌리기 |
| 단순함 우선 | 결과가 같으면 코드가 적은 쪽 유지 |
| Git을 기억으로 사용 | `experiment:` 커밋, log·diff 검토 |
| 막히면 접근 재검토 | 다시 읽고, 근접한 시도를 결합하고, 다른 전략 시도 |

## 훅과 안전성

훅은 다층 방어 장치이지 보안 샌드박스가 아니다. OpenCode·Codex에는 동일한 훅 보장이 없다.

| 훅 | 기능 | 이벤트 |
| --- | --- | --- |
| scout-block | node_modules, .git, __pycache__ 등 문맥 유입 제한 | PreToolUse |
| privacy-block | .env, SSH 키, 자격 증명 읽기 제한 | PreToolUse |
| dangerous-cmd-block | 강제 push, 재귀 강제 삭제, hard reset 제한 | PreToolUse |
| iteration-context | 문맥 압축 후 최근 TSV 주입 | UserPromptSubmit |
| subagent-context | 활성 루프 상태를 하위 에이전트에 제공 | SubagentStart |
| dev-rules-reminder | 계획 경로·코드 규칙 재주입 | UserPromptSubmit |
| simplify-gate | 배포 전 400 LOC 경고, 800 LOC 차단 | UserPromptSubmit |
| session-init | 세션 시작 시 프로젝트 문맥 준비 | SessionStart |
| stop-notify | 종료 알림, 선택적 webhook | SessionEnd |

훅은 기본 활성화다. 문제 해결 시에만 개별 비활성화한다.

```bash
export AR_DISABLE_SCOUT_BLOCK=1
export AR_DISABLE_PRIVACY_BLOCK=1
export AR_DISABLE_DANGEROUS_CMD_BLOCK=1
```

선택적으로 `AR_NOTIFY_WEBHOOK`을 Slack 등의 webhook 주소로 설정할 수 있다. 실제 URL은 비밀로 관리하고 커밋하지 않는다. `.ckignore`는 gitignore 문법으로 차단 디렉터리를 조정한다. [훅 안내](guide/hooks.md), [릴리스 절차](scripts/release.md).

## 명령

| 명령 | 목적 | 기본 반복 |
| --- | --- | --- |
| `/autoresearch` | Classic 지표 반복 또는 자연어 Orchestrator | 25 / 목표 기준 |
| `:plan` | 목표를 검증 가능한 설정으로 변환 | 1회 |
| `:debug` | 가설 기반 버그 조사 | 15 |
| `:fix` | 오류를 하나씩 수정 | 20 |
| `:security` | STRIDE·OWASP·레드팀 점검 | 15 |
| `:ship` | 8단계 출하 | 순차 |
| `:scenario` | 12차원 예외 상황 생성 | 20 |
| `:predict` | 5개 전문가 관점 분석 | 1회 |
| `:learn` | 문서 생성·검증·수정 | 10 |
| `:reason` | 블라인드 심사 기반 토론 | 8 |
| `:probe` | 8개 관점의 요구사항 질문 | 15 |
| `:improve` | ICP 조사와 PRD 생성 | 15 |
| `:evals` | 반복 결과와 정체 분석 | 1회 |
| `:regression` | 기준선 대비 STABLE/UNSTABLE 판정 | 1회 |

표의 `:plan`은 `/autoresearch:plan`의 축약이다. 공통 옵션은 `Iterations: N`, `Iterations: unlimited`, `--evals`, `--evals-interval N`, `--chain <targets>`, `--<subcommand>`다. 인자 없이 실행하면 설정 질문을 한다.

OpenCode는 `/autoresearch_debug`처럼 밑줄을 사용하고, Codex는 `$autoresearch debug`처럼 스킬 mention 뒤에 키워드를 붙인다.

### 빠른 선택

| 원하는 작업 | 호출 |
| --- | --- |
| 자연어 목표의 자동 조율 | `/autoresearch <goal>` |
| 수치 최적화 | `/autoresearch` + Metric/Verify |
| 지표가 불명확 | `/autoresearch:plan` |
| 숨은 제약 확인 | `/autoresearch:probe` |
| 보안 점검 | `/autoresearch:security` |
| 버그 조사 후 수정 | `/autoresearch:debug --fix` |
| 배포 준비만 확인 | `/autoresearch:ship --checklist-only` |
| 테스트 시나리오 | `/autoresearch:scenario --format test-scenarios` |
| 다각도 분석 후 조사 | `/autoresearch:predict --chain debug` |
| 문서 신규/갱신 | `/autoresearch:learn --mode init` 또는 `update` |
| 설계 토론 | `/autoresearch:reason --domain software` |
| 요구 확인 후 반복 | `/autoresearch:probe --chain plan,autoresearch` |
| 제품 개선 조사 | `/autoresearch:improve --depth deep` |
| 결과 추세 | `/autoresearch:evals --file *-results.tsv` |
| 회귀 점검 후 수정·출하 | `/autoresearch:regression --predict --fix --ship` |
| 기존 동작 보호 | `Guard: npm test` 추가 |

## 빠른 시작

아래는 원문 설치 안내이며 이번 문서 작업에서 사용자 환경에 설치하지 않았다. 개인 설치 경로에 기존 파일이 있으면 먼저 백업·검토한다. Bash 명령은 Bash에서 실행한다.

### Claude Code

방법 A — npx:

```bash
npx skills add uditgoenka/autoresearch
```

방법 B — 플러그인:

```text
/plugin marketplace add uditgoenka/autoresearch
/plugin install autoresearch@autoresearch
```

설치 뒤 새 세션을 시작해야 참조 파일이 정상 해석된다. 업데이트는 `/plugin update autoresearch`, 활성화는 `/reload-plugins`다.

방법 C — 직접 복사:

```bash
git clone https://github.com/uditgoenka/autoresearch.git
cp -r autoresearch/.claude/skills/autoresearch .claude/skills/autoresearch
cp -r autoresearch/.claude/commands/autoresearch .claude/commands/autoresearch
cp autoresearch/.claude/commands/autoresearch.md .claude/commands/autoresearch.md
```

전역 설치는 위 목적지를 각각 `~/.claude/skills/autoresearch`, `~/.claude/commands/autoresearch`, `~/.claude/commands/autoresearch.md`로 바꾼다. 목적지 부모 디렉터리가 있어야 한다.

방법 D — 설치 도우미:

```bash
git clone https://github.com/uditgoenka/autoresearch.git
cd autoresearch
./scripts/install.sh --claude --global
```

### OpenCode

권장 도우미: 동일 checkout에서 `./scripts/install.sh --opencode --global`.

직접 복사:

```bash
cp -r autoresearch/.opencode/skills/autoresearch .opencode/skills/autoresearch
cp autoresearch/.opencode/commands/autoresearch*.md .opencode/commands/
```

전역 경로는 `~/.config/opencode/skills/autoresearch`와 `~/.config/opencode/commands/`다. `/autoresearch_debug`, `/autoresearch_fix`, `/autoresearch_improve` 등 14개 명령을 제공한다.

### Codex

권장 도우미: 동일 checkout에서 `./scripts/install.sh --codex --global`.

직접 복사:

```bash
cp -r autoresearch/.agents/skills/autoresearch ~/.codex/skills/autoresearch
```

`$autoresearch plan`, `$autoresearch debug`, `$autoresearch evals`로 호출한다. 설치 패키지는 스킬 내부에 orchestrator·regression 실행 도우미를 포함한다. 저장소의 `plugins/autoresearch/skills/autoresearch/`와 `.agents/skills/autoresearch/`에서도 확인할 수 있다.

### 실행

```text
/autoresearch
Goal: Increase test coverage from 72% to 90%
Scope: src/**/*.test.ts, src/**/*.ts
Metric: coverage % (higher is better)
Verify: npm test -- --coverage | grep "All files"
Iterations: 25
```

파일을 읽고 기준선을 잡은 뒤 변경·검증·유지/복구·기록을 반복한다. N회 또는 사용자의 중단으로 끝난다. 학습자 주: 예시 Verify가 실제 환경에서 숫자 하나로 추출되는지는 dry-run으로 확인해야 한다.

## 명령별 상세

### /autoresearch:plan — 목표를 설정으로

`Goal: Make the API respond faster`를 주면 목표 → Scope → Metric → Direction → Verify dry-run의 다섯 단계를 거친다. Scope는 실제 파일로 해석되어야 하고, 지표는 숫자여야 하며, 검증 명령이 실행되어야 한다. 다음 단계에 전달할 `handoff.json`을 만든다.

### /autoresearch:debug — 버그 조사

증상 수집 → 코드 조사 → 구체적이고 반증 가능한 가설 → 반복당 실험 하나 → confirmed/disproven/inconclusive 분류 → 기록 순서다. 발견에는 파일:줄과 재현 절차가 필요하고 반증도 기록한다. 원문 예시는 `Scope: src/api/**/*.ts`, `Symptom: API returns 500 on POST /users`, `Iterations: 15`다.

옵션: `--fix`(후속 수정), `--scope <glob>`, `--symptom "<text>"`, `--severity <level>`.

### /autoresearch:fix — 오류 수정

테스트·타입·lint·build 오류를 탐지하고 차단 오류부터 하나씩 수정·커밋·검증한다. 오류 수 감소와 Guard 통과 여부에 따라 유지/복구하며 0개면 중단한다. 기본 20회.

옵션: `--target <command>`, `--guard <command>`, `--category <type>`(test/type/lint/build), `--from-debug`. `debug → fix --from-debug`로 연결할 수 있다.

### /autoresearch:security — 보안 점검

기본 읽기 전용이다. 자산·신뢰 경계·공격 면 조사, STRIDE 위협 모델, OWASP Top 10, 네 적대적 관점의 분석을 수행한다. 발견에는 코드 위치와 공격 시나리오가 필요하다. 기본 15회.

`--diff`는 변경 파일만, `--fix`는 확인한 Critical/High 항목 수정, `--fail-on <severity>`는 CI 종료 코드 기준이다. 원문은 `security/{date}-{slug}/`에 구조화된 보고서 7개를 만든다고 설명한다.

### /autoresearch:ship — 출하

Identify → Inventory → Checklist → Prepare → Dry-run → Ship → Verify → Log의 8단계다. code-pr, code-release, deployment, content, marketing-email, marketing-campaign, sales, research, design의 9가지 유형에 맞는 점검표를 만든다.

옵션: `--dry-run`, `--auto`(점검표 통과 시 자동 승인), `--force`(비핵심 항목만 생략), `--rollback`, `--monitor N`, `--checklist-only`.

학습자 주: 원문 예시의 `/autoresearch:ship --auto`를 무심코 실행하지 않는다. 호스트와 사용자 권한 정책이 우선하며 Orchestrator는 ship에 `--auto`를 전달하지 않는다. 이 문서 작업도 배포·릴리스를 실행하지 않는다.

### /autoresearch:scenario — 상황 탐색

정상, 오류, 경계, 남용, 확장, 동시성, 시간, 데이터 변화, 권한, 통합, 복구, 상태 전이의 12차원으로 확장한다. 반복마다 상황 하나를 생성하고 new/variant/duplicate로 분류한다. 기본 20회. 예: 여러 결제수단으로 결제하는 사용자.

`--domain`: software/product/business/security/marketing. `--depth`: shallow(10)/standard(20)/deep(50+). `--format`: use-cases/user-stories/test-scenarios/threat-scenarios. `--focus`: edge-cases/failures/security/scale.

### /autoresearch:predict — 다중 관점 예측

Architect, Security Analyst, Performance Engineer, Reliability Engineer, Devil's Advocate의 다섯 관점이 독립 분석·토론·합의를 수행한다. 원문은 약 2분의 사전 분석으로 소개한다. `--chain debug`, `--chain security`, `--chain scenario,debug,fix`로 후속 작업에 연결한다. 시간과 품질은 보장되지 않는다.

### /autoresearch:learn — 문서 생성

코드 탐색 → 문서 작성 → 검증 → 수정. `init`, `update`, `check`(읽기 전용), `summarize`의 네 모드가 있다. `--depth deep`, `--file <path>`를 사용할 수 있다. 변경 기반 범위 지정, Mermaid, API·테스트·설정 가이드와 교차 링크를 지원한다. 기본 10회.

### /autoresearch:reason — 대립적 개선

객관 지표가 없는 주관적 영역에서 블라인드 심사단을 평가 함수로 삼는다. A 생성 → 비판 → B 응답 → 통합 → 무작위 라벨 블라인드 심사 → 승자를 새 A로 삼아 반복한다. 각 역할은 새 호출로 이전 맥락 유출을 줄인다.

`--judges N`: 3–7, 홀수 권장. `--convergence N`: 연속 승리 기본 3. `--mode`: convergent/creative/debate. `--domain`: software/product/business/security/research/content. `--chain` 지원. 기본 8회.

`reason/{date}-{slug}/`에 lineage.md, candidates.md, judge-transcripts.md, reason-results.tsv, handoff.json을 만든다.

### /autoresearch:probe — 요구사항 검증

회의론자, 경계 사례 탐색자, 범위 감시자, 모호성 탐정, 모순 탐색자, 선행사례 조사자, 성공기준 감사자, 제약 발굴자의 여덟 관점으로 새 제약이 더 나오지 않을 때까지 질문한다. Goal/Scope/Metric/Direction/Verify와 handoff를 생성한다.

`--depth`: shallow(5)/standard(15)/deep(30). `--adversarial`은 적대적 관점을 우선한다. `--mode`: interactive/autonomous. `--chain`: plan/predict/debug/scenario/reason/fix/ship/learn.

`probe/{date}-{slug}/`에 probe-spec.md, constraints.tsv, autoresearch-config.yml, handoff.json을 만든다. 예: `/autoresearch:probe --chain plan,autoresearch`와 다중 테넌트 DB 격리 요구.

### /autoresearch:improve — 제품 개선

ICP(이상적 고객상)를 바탕으로 무엇을 만들지 조사한다. 제품 맥락 → 고객 문제·경쟁사 격차·시장 추세·UX·매출의 다섯 범주 조사 → 포화 확인 → ICP 적합성 → Must-have/Nice-to-have/Moonshot 순위 → 사용자 선택 → PRD 생성이다.

`--icp`, `--discover`, `--no-discover`, `--depth shallow|standard|deep`(5/15/30+), `--seeds`를 지원한다. 예: 50–500인 기업의 B2B SaaS 제품 관리자 대상 온보딩 전환 개선.

`improve/{date}-{slug}/`에 research-findings.md, improvement-plan.md, 기능별 PRD, summary.md, improve-results.tsv, handoff.json을 만든다. **체인의 종착점**이며 PRD는 `/ck:plan`, `/ck:cook` 같은 외부 도구가 소비한다. probe/predict/debug에서 `--improve`로 연결할 수 있다.

### /autoresearch:evals — 결과 분석

`*-results.tsv`에서 추세, 정체, 수렴, 반복 효율을 분석한다. v2.0.x TSV와 호환된다. 예: `/autoresearch:evals --file coverage-results.tsv`.

기본 체크포인트 간격은 `floor(max_iterations/3)`, 최소 1이다. delta, 정체, 최선 반복, 계속/중단/전략 변경 권고를 출력한다. 30회 실행에서 `--evals-interval 10`이면 10회마다 보고한다.

### /autoresearch:regression — 안정성 판정

기준 ref의 Git worktree와 후보를 8차원에서 비교해 STABLE/UNSTABLE을 낸다. **기준선 green → 후보 red만 회귀**다. pre-existing, new-coverage, baseline-unavailable, flaky는 구분해서 다룬다.

- HARD: functional, api-contract, data-migration, integration-e2e. 적격 회귀 하나면 UNSTABLE.
- SCORE: flakiness 0.30, performance 0.30, resource 0.20, visual-ui 0.20. 0–100 점수, 기본 임계값 95.

옵션: `--select auto`(관련 테스트 매퍼가 없으면 전체), `--samples N`(기본 양쪽 7), `--noise-band %`, `--fix`, `--fix-cycles N`(최대 기본 3), `--predict`, `--reason`, `--debug`, `--max-runs N`(200 초과 경고·확인).

`regression/{date}-{slug}/`에 regression-results.tsv, stability-report.md, dimensions/<dim>.md, baseline/, evals-summary.md, handoff.json을 만든다. 데이터 마이그레이션은 opt-in과 임시/허용 DB 제약, 기본 forward-only다.

학습자 주: 원문의 `*test*`·`*ci*` 표현보다 현재 코드의 `_test`·`_ci` 접미사와 호스트 판정이 구체적이다. [고급 가이드](guide/ko/04_advanced.md)에 실제 조건과 제한을 설명한다. STABLE은 측정한 범위의 판정이며 전체 안전성 인증이 아니다.

## Guard와 결과 기록

Verify는 지표 개선, Guard는 기존 동작 파손 여부다.

```text
/autoresearch
Goal: Reduce API response time to under 100ms
Verify: npm run bench:api | grep "p95"
Guard: npm test
```

원문은 Guard 실패 시 최적화를 최대 두 번 재작업하고 Guard/테스트 파일은 바꾸지 않는다고 설명한다. [@pronskiy](https://github.com/pronskiy)의 [PR #7](https://github.com/uditgoenka/autoresearch/pull/7) 기여다. 학습자 주: 현재 Classic 명령은 Guard 실패 시 revert를 명시하므로 실제 실행에서는 설치된 명령 계약을 확인한다.

```tsv
iteration  commit   metric  delta   status    description
0          a1b2c3d  85.2    0.0     baseline  initial state
1          b2c3d4e  87.1    +1.9    keep      add tests for auth edge cases
2          -        86.5    -0.6    discard   refactor test helpers (broke 2 tests)
3          c3d4e5f  88.3    +1.2    keep      add error handling tests
```

이는 원문의 축약 로그 예시다. 실제 Classic 명령에는 timestamp·guard 등이 추가되고 regression TSV는 별도의 15열 계약이다. 서로 같은 포맷이라고 가정하지 않는다.

## 장애 복구

| 장애 | 원문 대응 |
| --- | --- |
| 구문 오류 | 즉시 수정, 반복 횟수에 포함하지 않음 |
| 런타임 오류 | 최대 3회 수정 시도 후 다음 접근 |
| 자원 고갈 | 되돌리고 작은 변형 시도 |
| 무한 루프·정지 | timeout 뒤 종료·복구 |
| 외부 의존성 | 기록 후 다른 접근 |

## 저장소 구조

```text
autoresearch/
  README.md, COMPARISON.md, LICENSE
  guide/                            # 명령별 가이드와 한국어 학습 자료
  scripts/                          # 설치·변환·릴리스·결정적 런타임
  .claude/skills/autoresearch/       # 스킬 라우터·참조
  .claude/commands/autoresearch.md   # Classic 계약
  .claude/commands/autoresearch/     # 13개 하위 명령
  .claude/hooks/autoresearch/        # Node.js 보호 훅
  claude-plugin/                    # Claude 배포본
  .opencode/                        # 밑줄 명령의 변환본
  .agents/skills/autoresearch/       # Codex 스킬 변환본
  plugins/autoresearch/             # Codex 플러그인 배포본
  tests/                           # Bash 검증과 fixtures
```

학습자 주: 원문의 과거 구조 설명을 현재 트리와 대조해 표시했다. `.claude/`가 프롬프트의 기준 원본이고 `scripts/`의 런타임은 변환 시 각 배포본에 복사된다. 배포본을 직접 고치지 않는다.

## 자주 묻는 질문

- 지표를 모르겠다면? `:plan`으로 후보 지표와 Verify dry-run을 만든다.
- v2.2.0의 변화? 자연어 Orchestrator 추가. Metric/Verify가 있으면 Classic을 유지한다.
- v2.1.0의 변화? 라우터/명령 분리, evals, 유한 반복 기본값. 토큰 절감 수치는 원문 주장이다.
- 반복 수 조정? 기본 25, `Iterations: 50` 또는 명시적 `unlimited`.
- evals 사용? 이전 TSV 경로를 주거나 실행 중 `--evals-interval N`을 사용한다.
- 어떤 프로젝트? 원문은 언어·프레임워크·분야에 독립적이라고 설명한다. 실제로는 실행 가능한 검증 도구가 필요하다.
- OpenCode 지원? `--opencode --global`, 밑줄 명령 14개.
- Codex 지원? `--codex --global` 또는 직접 복사, `$autoresearch` mention.
- 중단 방법? Ctrl+C 또는 반복 상한. Git에 실험 이력이 남지만 중단 시 실패 후보가 HEAD일 수 있으므로 상태를 확인한다.
- 비코드 작업? 측정 가능한 영업 메일·마케팅·정책·운영 절차 등. [분야별 예제](guide/examples-by-domain.md).
- security는 코드 수정? 기본은 읽기 전용, `--fix`는 선택 사항.
- predict와 reason 차이? predict는 기존 코드의 일회성 다각도 분석, reason은 주관적 후보를 반복 개선한다.
- handoff.json? 다음 명령에 설정·발견·결과를 넘기는 구조화된 파일이다.

## 기여·라이선스·저자

[CONTRIBUTING.md](CONTRIBUTING.md)를 따른다. 도메인 예제, 검증 스크립트, CI/CD 통합, 실제 벤치마크를 기여할 수 있다. upstream 가이드는 [guide/](guide/)에 있다. [별 추이](https://www.star-history.com/?repos=uditgoenka%2Fautoresearch&type=timeline&legend=top-left)는 upstream 통계다.

MIT — [LICENSE](LICENSE). Copyright (c) 2026 Udit Goenka.

기여 인정: [Andrej Karpathy](https://github.com/karpathy), [Anthropic](https://anthropic.com), [OpenCode](https://opencode.ai), [OpenAI](https://openai.com).

저자 [Udit Goenka](https://udit.co)는 AI 제품 전문가·창업자·엔젤 투자자로 자신을 소개한다. 인도에서 독학으로 시작해 여러 회사를 설립하고 700개 이상 스타트업의 약 2,500만 달러 이상 매출 창출을 도왔다고 설명한다. [TinyCheque](https://tinycheque.com), [Firstsales.io](https://firstsales.io)를 만들고 38개 스타트업에 투자해 6개 exit를 경험했다는 소개다. 이 수치는 저자 소개의 번역이며 독립 검증하지 않았다.

[웹사이트](https://udit.co) · [X](https://x.com/iuditg) · [GitHub](https://github.com/uditgoenka) · [뉴스레터](https://udit.co/blog) · [후원](https://paypal.me/uditgoenka).

저자의 메시지: 범위를 제한하고 성공을 명확히 하며 검증을 기계화하면, 에이전트는 전술을 최적화하고 사람은 전략을 개선할 수 있다.
