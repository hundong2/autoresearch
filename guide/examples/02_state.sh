#!/usr/bin/env bash
# 목표: 상태 검증 후 라우팅. 실행: bash guide/examples/02_state.sh
set -euo pipefail
AR_EXAMPLES=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
AR_REPO=$(cd "$AR_EXAMPLES/../.." && pwd)
AR_TOOL="$AR_REPO/scripts/orchestrate.sh"
check_state() {
  local fixture="$1" expected="$2" output
  # 입력은 저장된 문자열이다. 승인되지 않은 predicate를 eval하지 않는다.
  output=$(bash "$AR_TOOL" validate-state "$fixture")
  [[ "$output" == valid ]] || exit 1
  output=$(bash "$AR_TOOL" screen-state-predicate "$fixture")
  [[ "$output" == ok ]] || exit 1
  output=$(bash "$AR_TOOL" next-hop "$fixture")
  [[ "$output" == "$expected" ]] || { printf 'expected=%s actual=%s\n' "$expected" "$output" >&2; exit 1; }
}
check_state "$AR_EXAMPLES/fixtures/needs-fix.json" fix
check_state "$AR_EXAMPLES/fixtures/needs-verify.json" verify
check_state "$AR_EXAMPLES/fixtures/done.json" DONE
printf '9 checks passed\n'
