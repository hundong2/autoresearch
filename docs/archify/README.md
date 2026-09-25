# Autoresearch 코드 아키텍처

작성일: 2026-09-25

[대화형 HTML](architecture.html) · [원본 명세](architecture.json) · [화면 모음](architecture.visual-check.html) · [학습 가이드](../../guide/README.md#한국어-학습-경로)

## 분석 범위

- 저장소: https://github.com/hundong2/autoresearch
- 코드 revision: `050e30dc4ba0974b03f2873111b9901ec3211390`
- upstream: uditgoenka/autoresearch. 모델 학습 코드가 아닌 다중 호스트 스킬·런타임 저장소.
- 6개 구성요소, 5개 관계, revision 고정 소스 참조 15개.
- 대표 경로: 호스트가 실행 계약을 해석 → Bash 판정 도우미 호출 → 상태 JSON 검사. 보호 훅과 회귀 점수는 가까운 별도 분기.

한국어는 Archify Viewer 지원 locale이 아니므로 `meta.locale`을 생략했다. 다이어그램 설명은 한국어지만 고정 Viewer UI와 `<html lang>`은 영어 fallback이다.

## 실제 근거와 실행 흐름

| 구성요소 | 소스 근거 | 관계 해석 |
| --- | --- | --- |
| 호스트 | `.claude/skills/autoresearch/SKILL.md:15–26,77–92` | 사용자 입력에 맞는 절차를 수행하는 외부 실행 주체 |
| 명령 계약 | 같은 SKILL `63–92`, `.claude/commands/autoresearch.md:44–89`, `autoresearch/regression.md:72–78` | Markdown 지시문이며 독립적으로 실행되는 서비스가 아님 |
| Orchestrator | `scripts/orchestrate.sh:19–124,438–448` | classify/next-hop 등 case 분기로 들어가 stdout·종료 코드 반환 |
| 장부 | SKILL `94–107`, `orchestrate.sh:392–436` | 호스트가 소유하는 JSON; helper는 읽고 검증 |
| Claude 훅 | `.claude/hooks/autoresearch/hooks.json:19–38`, `node-hook-runner.sh:1–17`, `dangerous-cmd-block.cjs:61–82` | Bash 이벤트 등록 → Node wrapper → 입력·위험 명령 검사 |
| 회귀 reducer | `scripts/score-regression.sh:100–197` | 15열 TSV 유효성, HARD/SCORE, 데이터 없음 판정 |

그림의 `CLI 지시`는 Markdown 파일이 OS 프로세스를 직접 시작한다는 뜻이 아니다. 호스트가 계약의 명령을 실행한다. `JSON 읽기` 화살표는 접근 방향이며 JSON 생성·수정은 호스트 절차의 책임이다. `database` 모양은 파일 영속 상태를 뜻하고 DB 서버는 없다.

Classic은 Git commit/verify/Guard/revert/TSV를 호스트에 지시한다. Orchestrator와 regression 스크립트 자체는 모델 API를 호출하거나 실제 코드 수정·배포를 하지 않는다. 각 도우미 결과는 호출한 호스트로 돌아오며 단순한 반환 화살표는 중복해서 넣지 않았다.

## 신뢰 경계와 불확실성

- 스킬·저장 장부에 있는 명령은 신뢰할 수 없는 입력일 수 있다. `validate-state`와 predicate 재검사는 방어의 일부다. shell 문자열 필터는 완전한 parser/sandbox가 아니다.
- Claude의 훅은 입력을 검사하고 exit 2로 차단할 수 있지만 내부 오류에는 fail-open한다. hook parity가 없는 다른 호스트에 같은 보호를 가정하지 않는다.
- Git, 프로젝트 테스트, LLM 인증·네트워크·모델 선택은 호스트와 대상 프로젝트에 달린다. 특정 모델·클라우드·포트·배포 환경을 지어내지 않았다.
- `ship=yes`는 판정 문자열이다. 실제 배포 권한이 아니며 Orchestrator 계약은 명시적 승인을 요구한다.
- `.claude/` canonical → `scripts/transform.sh` → claude-plugin/.opencode/.agents/plugins 변환은 별도 배포 경로다. 런타임 주 흐름에 생성 파이프라인을 섞지 않았다.
- 14개 명령의 모든 내부 분기, 훅 9종 전체, 외부 프로젝트의 실제 테스트 실행은 이번 그림 범위에서 제외했다.

## 검증 receipt

```text
diagram_type: architecture
output: D:/workspace/laboratory/autoresearch/docs/archify/architecture.html
specification_sha256: 9626dae2c21c2e76d8dfcab4223bce3d676c4779dd8c48a09b7bca8b37d68eca
artifact_sha256: deefafdfd5a45f8256613247e7a8384b1749d0a4234bc74f4568789983df16dd
specification_bytes: 4731
artifact_bytes: 711378
validation: 9/9 showcase, 0 errors, 0 warnings
browser_evidence: passed
visual_review: passed
correction_rounds: 0
```

1. 결정적 검증: 고정 revision 소스 참조 15개, 9/9 artifact checks, composition 오류·경고 0.
2. 자동 브라우저: [현재 HTML에 결합된 receipt](architecture.visual-check.json). 1440×900, 1600×1000, 1920×1080, 2048×1320에서 가로·세로 overflow 없음.
3. 지각적 검수: 실제 image reader로 1440×900 및 2048×1320의 light/dark PNG 네 장을 확인했다. 노드·카드 잘림, 라벨 겹침, 선 교차 없음. 주 경로와 보조 분기가 구별되고 큰 화면에서도 내용과 카드가 첫 화면 안에 들어온다.

첫 deliver 전에 source 범위 한 줄과 두 세로 관계 라벨 위치를 validator에 따라 수정했다. deliver 뒤 시각 수정은 없으므로 correction_rounds는 0이다. 자동 receipt의 `visualReview: pending`은 기계가 시각 판단을 대신하지 않는다는 뜻이며 위 검수와 별개다.

## 재검증

설치된 Archify 디렉터리에서 실행한다. 변경하지 않은 HTML에 다시 render하지 않고 visual-check만 수행할 수 있다.

```bash
node bin/archify.mjs validate architecture <repo>/docs/archify/architecture.json --repo-root <repo> --quality showcase --json
node bin/archify.mjs deliver architecture <repo>/docs/archify/architecture.json <repo>/docs/archify/architecture.html --repo-root <repo> --quality showcase --json
node bin/archify.mjs visual-check <repo>/docs/archify/architecture.html --json
```

도우미·훅·설치·실습의 실제 테스트 결과는 [검증 기록](../../guide/ko/validation.md)에 있다.
