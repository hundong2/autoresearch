# 오프라인 Bash 실습

작성일: 2026-09-25 · [가이드](../README.md#한국어-학습-경로)

요구 사항: Bash, POSIX 도구, Node.js 18 이상. 외부 패키지·LLM·계정 설정 없이 저장소 루트에서 실행한다. Windows는 Git Bash를 사용한다. 프로젝트의 실제 Bash 런타임을 사용하기 때문에 임의 Python 모사 대신 `.sh`를 택했다.

| 실행 명령 | 학습 목표 | 예상 결과 |
| --- | --- | --- |
| `bash guide/examples/01_classify.sh` | 휴리스틱 분류·문자열 검사 | 5 checks passed |
| `bash guide/examples/02_state.sh` | 스키마·predicate·라우팅 | 9 checks passed |
| `bash guide/examples/03_regression.sh` | green→red·기존 오류·데이터 없음 | 3 checks passed |

실습은 입력 문자열을 실행하지 않는다. 파일 읽기와 출력만 수행하며 Git commit/revert/push도 하지 않는다. 위험 문자열은 검사 함수의 데이터일 뿐 셸 코드로 평가되지 않는다. `fixtures/`는 합성 상태이며 제품 성능 재현 결과가 아니다.

실패하면 expected/actual 또는 종료 코드가 다르다는 오류로 중단한다. 다음 과제와 해석은 [실습 해설](../ko/03_practice.md)에 있다.
