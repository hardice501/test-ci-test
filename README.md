# ci-test

`zksurvey` GitHub Actions workflow 테스트용 최소 모노레포임.

## 구성 원칙

- `turbo`, `typescript`만 설치
- 원본 repo의 디렉터리 패턴만 유지
- 각 workspace 스크립트는 no-op
- `docker-bake.hcl`은 파싱만 가능한 빈 동작
