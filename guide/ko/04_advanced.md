# 04. 고급 설계·확장·위험

작성일: 2026-09-25 · [목차](../README.md#한국어-학습-경로)

## 두 종류의 루프

Classic은 지표를 개선하는 변경 탐색이다. Orchestrator는 errors/regression/gaps 등 상태에서 다음 하위 작업을 고른다. 후자는 스케줄러 역할을 하지만 OS daemon은 아니며 호스트 에이전트가 다시 호출한다. `verdict`의 `ship=yes`는 추천 문자열이지 push 실행도 사용자 승인도 아니다.

`units = failing_tests + open_hard_regressions + metric_delta / metric_target`. target 0 또는 입력 누락은 unknown과 exit 2다. 합산값은 목표별 측정 정의에 의존하므로 서로 다른 프로젝트의 절대 품질 순위에 사용하면 안 된다.

Plateau는 계산 가능한 최근 5개 값에서 마지막 값이 첫 값보다 낮지 않을 때다. 중간 unknown은 수치 표본에서 제외하지만 후행 unknown 5개는 BLOCKED다. 일시적인 측정 실패를 0으로 바꿔 “수렴”이라고 판단하지 않는다.

## 회귀 게이트의 의미

HARD는 적격 green→red 하나라도 실패다. SCORE는 실행한 차원의 가중치를 다시 정규화하고 각 차원 최악 subscore를 사용한다. 코드상 SCORE 행은 baseline-unavailable만 제외하므로 pre-existing/flaky 분류도 subscore에 영향을 줄 수 있다. README의 “분류 제외” 문구를 모든 점수 계산에서 제외된다는 뜻으로 확대하지 않는다.

측정 차원이 적으면 분모가 작아져 점수 100이 쉽게 나올 수 있다. 따라서 점수, 실행 차원, 미측정 차원, 원시 표본, 임계값을 함께 보관한다. 화면 표시 점수는 소수 둘째 자리에서 버리지만 판정은 원 정밀도로 한다.

## 신뢰 경계

- `screen-cmd`는 패턴 검사다. 셸을 완전히 해석하지 않으며 `ok`가 안전함을 증명하지 않는다. 문서·상태 파일에 들어온 명령은 무조건 실행하지 않는다.
- DB URL 검사는 `postgres(ql)` URI에 대해 localhost/127.0.0.1 또는 점 없는 호스트, 그 외에는 DB 이름 `_test`/`_ci` 접미사를 본다. 실제 DB가 임시인지 확인하는 기능은 아니다. 접미사만 맞춘 원격 운영 DB도 별도 정책으로 차단해야 한다.
- Claude 훅은 예외 시 fail-open한다. 일반 `git push`도 dangerous-cmd 훅이 막지 않는다. 호스트 권한 정책·승인·최소 권한·격리된 테스트 환경이 별도로 필요하다.
- 훅 로그는 프로젝트 밖 임시/사용자 경로에 생길 수 있다. webhook에는 업무 데이터가 나갈 수 있으므로 기본 비활성으로 두고 필요한 필드만 사용한다.
- plan/probe/ship 등의 문서화된 행동과 실제 모델의 준수 여부는 다르다. deterministic test 통과를 에이전트 보안 인증으로 보고하지 않는다.

## 확장과 성능

프롬프트는 `.claude/`부터 수정하고 `bash scripts/transform.sh`로 배포본을 생성한다. `scripts/orchestrate.sh`·`score-regression.sh`는 root가 원본이다. 생성된 복사본을 각각 직접 고치면 drift가 생긴다. 새 명령이면 라우터·명령 문서·변환·테스트·가이드를 함께 갱신한다. 기여자는 버전을 임의로 올리지 않는다.

큰 코드베이스에서는 범위를 줄이고 영향을 받는 테스트 매퍼를 사용하되, 매퍼가 없으면 전체 suite라는 계약을 지킨다. 토큰 비용은 LLM 호출 수·입력 길이·재시도에 좌우된다. 원문의 95% 절감 수치는 현재 작업에서 검증하지 않았다.

## 검증과 디버깅

```bash
bash tests/test-orchestrator.sh
bash tests/test-regression.sh
bash tests/test-hooks.sh
bash tests/test-maintenance.sh
```

maintenance는 임시 checkout에서 변환 멱등성과 가짜 git/gh 도구로 릴리스 준비를 검사한다. 실제 release.sh를 따로 실행하지 않는다. 원본 `.claude/`를 바꾸지 않은 번역 작업에는 root에서 transform을 돌려 생성 파일을 무의미하게 갱신할 필요가 없다.

실패 시 OS·Bash·Node 버전, fixture, stdout/stderr, exit 코드를 기록한다. 훅은 exit 2=차단, 회귀는 exit 1=UNSTABLE, plateau는 exit 0=정체로 **종료 코드 의미가 서로 다르다**. [실측 검증 결과](validation.md).
