# Autoresearch 한국어 학습 가이드

작성일: 2026-09-25

## 한국어 학습 경로

[한국어 README](../README_kor.md) · [코드 아키텍처](../docs/archify/README.md) · [검증 기록](ko/validation.md)

목차: [출처와 작업 범위](#출처와-작업-범위) · [한눈에 보기](#한눈에-보기) · [단계별 학습](#단계별-학습) · [용어](#용어) · [다음 경로](#다음-경로). 아래 기존 영문 가이드 목록은 보존했다.

### 출처와 작업 범위

[hundong2/autoresearch](https://github.com/hundong2/autoresearch), upstream uditgoenka/autoresearch, MIT, 기준 revision `050e30dc4ba0974b03f2873111b9901ec3211390`, 확인일 2026-09-25. 입력 GitHub URL을 한국어 번역·실습·코드 분석 요청으로 해석했다. 이 저장소는 **Karpathy의 Python 모델 학습 저장소 자체가 아니다.** Markdown 명령 계약, Bash 런타임, Node.js 훅으로 이루어진 에이전트 반복 작업 도구다.

### 한눈에 보기

사람이 목표와 수정 범위를 정하고 호스트 에이전트가 명령 문서를 해석한다. `scripts/orchestrate.sh`는 목표 분류·다음 작업 결정·상태 검사 같은 작은 결정적 기능만 수행한다. Bash 스크립트가 LLM을 호출하거나 실제 수정 루프 전체를 실행하는 구조는 아니다. 기본 25회 Classic 지표 반복과 자연어 Orchestrator를 구별한다.

### 단계별 학습

| 순서 | 자료 | 도달 목표 |
| --- | --- | --- |
| 1 | [기초 개념](ko/01_foundations.md) | Goal/Scope/Metric/Verify/Guard와 기준선 이해 |
| 2 | [설치와 최소 실행](ko/02_setup.md) | 개인 설치 전에 오프라인 도우미 확인 |
| 3 | [코드 흐름·실습](ko/03_practice.md) | 실제 CLI에서 분류·경로·회귀 판정 관찰 |
| 4 | [고급 설계와 위험](ko/04_advanced.md) | 평가 누수·신뢰 경계·배포본 동기화 이해 |
| 5 | [실행 예제](examples/README.md) | Bash 세 단계 assert 실습 |
| 6 | [아키텍처](../docs/archify/README.md) | 코드 근거를 따라 구조 탐색 |

### 용어

- **Metric**: 개선하려는 숫자. 방향과 단위를 고정한다.
- **Verify**: 지표를 계산하는 재실행 가능한 명령.
- **Guard**: 지표 외의 기존 동작을 지키는 검사.
- **Predicate**: 성공 여부를 기계적으로 판단하는 조건. 중간에 목표를 유리하게 바꾸지 않는다.
- **Handoff**: 한 명령의 결과를 다음 명령에 전달하는 파일.
- **Regression**: 원래 통과하던 항목이 변경 후 실패하는 회귀.
- **Plateau**: 계산 가능한 진척값이 일정 구간 개선되지 않는 상태.
- **Hook**: 도구 호출 등 이벤트 앞뒤의 보호·문맥 보조 코드. 격리 환경은 아니다.

### 다음 경로

기초 → 오프라인 실습 → 격리된 테스트 프로젝트에서 3회 Classic → Guard 추가 → 독립 평가 → 회귀 분석 순서로 진행한다. 모델 품질과 토큰 비용은 별도 측정한다. 외부 배포·push·유료 API 호출을 연습의 필수 단계로 두지 않는다. 기여 시 [CONTRIBUTING.md](../CONTRIBUTING.md)를 읽고 `.claude/` 원본을 바꾸었을 때만 배포본 동기화를 수행한다.

---

<div align="center">

# Autoresearch Guides

**By [Udit Goenka](https://udit.co)**

[![Version](https://img.shields.io/badge/version-2.2.2-blue.svg)](https://github.com/uditgoenka/autoresearch/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](../LICENSE)

</div>

---

Everything you need to master autonomous iteration — from first run to advanced multi-command chains. Each guide is self-contained with examples, flags, chains, and tips.

---

## Quick Start

```bash
npx skills add uditgoenka/autoresearch
/autoresearch
```

---

## Guide Index

| Guide | Description |
|-------|-------------|
| [Getting Started](getting-started.md) | Installation, first run, core concepts |
| [/autoresearch — Orchestrator](autoresearch-orchestrator.md) | Autonomous orchestrator — type a plain-language goal, the system selects and loops the pipeline |
| [/autoresearch](autoresearch.md) | Core autonomous loop — modify, verify, keep/discard, repeat |
| [/autoresearch:plan](autoresearch-plan.md) | One-shot wizard — Goal → Scope, Metric, Verify |
| [/autoresearch:debug](autoresearch-debug.md) | Autonomous bug-hunting with scientific method |
| [/autoresearch:fix](autoresearch-fix.md) | Error crusher — tests, types, lint, build |
| [/autoresearch:security](autoresearch-security.md) | STRIDE + OWASP + red-team security audit |
| [/autoresearch:ship](autoresearch-ship.md) | 8-phase shipping workflow |
| [/autoresearch:scenario](autoresearch-scenario.md) | Scenario explorer — 12 dimensions |
| [/autoresearch:predict](autoresearch-predict.md) | 5 expert personas debate before you act |
| [/autoresearch:learn](autoresearch-learn.md) | Autonomous documentation engine |
| [/autoresearch:reason](autoresearch-reason.md) | Adversarial refinement with blind judges |
| [/autoresearch:probe](autoresearch-probe.md) | 8 personas interrogate requirements to saturation |
| [/autoresearch:improve](autoresearch-improve.md) | Research ICP challenges, discover improvements, generate PRDs |
| [/autoresearch:evals](autoresearch-evals.md) | Analyze results TSV — trends, plateaus, checkpoints |
| [/autoresearch:regression](autoresearch-regression.md) | Stability gate — baseline diff, STABLE/UNSTABLE verdict before you push |
| [Chains & Combinations](chains-and-combinations.md) | Multi-command pipelines with all 14 commands |
| [Examples by Domain](examples-by-domain.md) | Real-world examples: software, sales, marketing, DevOps, ML, HR |
| [Advanced Patterns](advanced-patterns.md) | Guards, MCP, CI/CD, evals checkpoints, transform.sh |
| [Hooks Reference](hooks.md) | 9 auto-firing hooks: safety gates, context injection, notifications |
| **[Scenario Guides](scenario/)** | **Real-world scenario walkthroughs** |

---

## Quick Decision Guide

| I want to... | Use |
|--------------|-----|
| Give a plain-language goal, let it self-orchestrate | bare `/autoresearch <goal>` |
| Improve test coverage / reduce bundle size / any metric | `/autoresearch` |
| Don't know what metric to use | `/autoresearch:plan` |
| Requirements are unclear — surface hidden constraints | `/autoresearch:probe` |
| Run a security audit | `/autoresearch:security` |
| Ship a PR / deployment / release | `/autoresearch:ship` |
| Hunt all bugs in a codebase | `/autoresearch:debug` |
| Fix all errors (tests, types, lint) | `/autoresearch:fix` |
| Debug then auto-fix | `/autoresearch:debug --fix` |
| Check if something is ready to ship | `/autoresearch:ship --checklist-only` |
| Explore edge cases for a feature | `/autoresearch:scenario` |
| Generate test scenarios | `/autoresearch:scenario --format test-scenarios` |
| Get expert opinions before starting | `/autoresearch:predict` |
| Debate an architecture decision | `/autoresearch:reason --domain software` |
| Generate docs for a new codebase | `/autoresearch:learn --mode init` |
| Update existing docs after changes | `/autoresearch:learn --mode update` |
| Discover what to build next for your ICP | `/autoresearch:improve` |
| Analyze loop results, detect plateaus | `/autoresearch:evals` |
| Verify a change is safe to push (catch regressions) | `/autoresearch:regression` |
| Gate, auto-fix, then ship in one chain | `/autoresearch:regression --predict --evals --fix --ship` |
| Optimize without breaking existing tests | `/autoresearch` with `Guard: npm test` |
| Bound any looping command | Add `Iterations: N` inline |

---

<div align="center">

**Built by [Udit Goenka](https://udit.co)** | [GitHub](https://github.com/uditgoenka/autoresearch) | [Follow @iuditg](https://x.com/iuditg)

</div>
