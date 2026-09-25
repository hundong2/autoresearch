# 02. 설치와 최소 실행

작성일: 2026-09-25 · [목차](../README.md#한국어-학습-경로)

## 개인 설치 전

Git, Bash, grep/sed/awk 같은 POSIX 도구, Node.js 18 이상이 필요하다(`scripts/install.sh:291` 이후에서 Node 확인). Python·GPU·모델 가중치는 필요하지 않다. 실제 LLM 기반 작업은 별도 호스트 제품의 계정·인증·사용량 설정에 의존한다. 이 저장소에는 모든 호스트에 공통인 하나의 API 키 설정이 없다.

Windows에서는 Git Bash를 사용한다. PowerShell에서 `bash`가 WSL을 가리킬 수 있으므로 `Get-Command bash`로 경로를 확인한다. 아래 명령은 **Bash 터미널에서 저장소 루트 기준**으로 실행한다.

```bash
node --version
git --version
bash scripts/orchestrate.sh classify "fix the login bug"
bash guide/examples/01_classify.sh
bash guide/examples/02_state.sh
bash guide/examples/03_regression.sh
```

첫 분류의 예상 출력은 `fix-broken`이다. 실습은 공개된 결정적 도우미를 호출하며 모델·네트워크·Git 변경 없이 작동한다.

## 실제 호스트 설치는 선택

[한국어 README](../../README_kor.md#빠른-시작)에 원문 설치 방법을 번역했다. 이 문서 작업은 사용자의 개인 설정에 설치하지 않는다. 테스트 suite의 설치 검증은 임시 `--config-dir` 안에서만 수행한다.

```bash
# 필요한 플랫폼 하나만 선택한다. 개인 파일 덮어쓰기를 검토한 뒤 실행한다.
bash scripts/install.sh --claude --global
# 또는 --opencode --global / --codex --global
```

설치 전 `bash scripts/install.sh --help`를 읽는다. 강제 덮어쓰기 `--force`는 기본 연습 명령에 넣지 않는다. Claude의 훅·settings 병합과 스킬 복사는 범위가 다르다. 설치 후 새 세션에서 명령이 발견되는지 확인한다.

## 처음 사용할 설정

자신의 테스트 프로젝트에서 다음 틀의 값을 실제 명령으로 바꾼다. 제공하지 않은 프로젝트 경로·스크립트가 존재한다고 가정하지 않는다.

```text
/autoresearch
Goal: 고정 입력에서 비교 횟수를 줄이되 결과는 유지
Scope: src/search.js
Metric: 비교 횟수
Direction: lower_is_better
Verify: <숫자 하나를 출력하는 내 벤치마크 명령>
Guard: <기존 정답 테스트 명령>
Iterations: 3
```

이 틀의 `<...>`는 실행 명령이 아니다. 실제 구현/검증 파일을 마련한 뒤 대체한다. baseline, 읽기 전용 Guard, 지출·시간·반복 상한을 확인한다. 종료·취소 시 `git status`, 최근 커밋과 결과 로그를 검토한다. 실패 후보가 최신 커밋일 수 있다.

## 흔한 문제

- `node` 없음: Node 18 이상을 설치하고 같은 Bash 세션의 PATH를 점검한다.
- `$'\r'` 오류: `.gitattributes`가 LF를 요구하므로 shell 파일 개행을 확인한다.
- Bash가 WSL 실행: 설치된 Git Bash를 명시적으로 선택한다. 전역 환경변수를 무작정 덮어쓰지 않는다.
- 분류가 `explore`: 영어 키워드 휴리스틱이다. 한국어 자연어 의미를 이해하는 분류기가 아니다.
- 판정 exit 1: 반드시 실행 오류는 아니다. UNSTABLE/정체 여부에 따라 의도된 종료 코드다.
- 훅이 없는데 안전하다고 오해: OpenCode/Codex와 Claude의 훅 표면은 다르다.
