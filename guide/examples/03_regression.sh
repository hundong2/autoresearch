#!/usr/bin/env bash
# 목표: 실제 scorer의 판정과 오류 코드를 구별. 실행: bash guide/examples/03_regression.sh
set -euo pipefail
AR_REPO=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
AR_SCORER="$AR_REPO/scripts/score-regression.sh"
check_verdict() {
  local file="$1" expected="$2" expected_code="$3" actual code=0
  # UNSTABLE도 정상적인 계산 결과이므로 set -e로 바로 종료하지 않고 코드를 잡는다.
  actual=$(bash "$AR_SCORER" verdict "$file") || code=$?
  [[ "$code" -eq "$expected_code" ]] || { printf 'unexpected exit=%s\n' "$code" >&2; exit 1; }
  printf '%s\n' "$actual" | grep -qx "VERDICT: $expected"
}
check_verdict "$AR_REPO/tests/fixtures/regression/green-to-red.tsv" UNSTABLE 1
check_verdict "$AR_REPO/tests/fixtures/regression/red-to-red.tsv" STABLE 0
# 디렉터리 아래의 존재하지 않는 자식: 삭제나 임시 파일 생성 없이 누락 입력 검사.
check_verdict "$AR_REPO/LICENSE/missing.tsv" ERROR 2
printf '3 checks passed\n'
