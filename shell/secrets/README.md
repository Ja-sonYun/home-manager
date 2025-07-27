# Agenix Secrets Management

이 디렉토리는 agenix를 사용한 시크릿 관리를 담당합니다. 모든 시크릿은 별도의 비공개 저장소에 저장되며, 이 dotfiles 저장소에서는 참조만 합니다.

## 구조

```
dotfiles/shell/secrets/
├── default.nix     # agenix 설정
└── README.md       # 이 문서

agenix-secrets/     # 별도의 비공개 저장소
├── secrets.nix     # 시크릿 파일 정의
├── keys/           # 공개 키 (선택사항)
└── secrets/        # 암호화된 시크릿 파일들
    ├── github-token.age
    ├── openai-api-key.age
    └── ...
```

## 설정 방법

### 1. 비공개 시크릿 저장소 생성

```bash
# GitHub에 비공개 저장소 생성
git init agenix-secrets
cd agenix-secrets

# secrets.nix 파일 생성
cat > secrets.nix << 'EOF'
let
  # 사용자 공개 키
  jasonyun = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG..."; # 실제 공개 키로 교체
  
  # 시스템 키 (선택사항)
  systems = {
    macbook = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH...";
  };
  
  allUsers = [ jasonyun ];
  allSystems = builtins.attrValues systems;
in
{
  # 각 시크릿 파일에 대한 접근 권한 정의
  "secrets/github-token.age".publicKeys = allUsers ++ allSystems;
  "secrets/openai-api-key.age".publicKeys = allUsers ++ allSystems;
}
EOF

# 저장소 커밋 및 푸시
git add .
git commit -m "Initial secrets setup"
git remote add origin git@github.com:username/agenix-secrets.git
git push -u origin main
```

### 2. 시크릿 추가

```bash
# agenix가 설치되어 있어야 함
nix-shell -p agenix

# 새 시크릿 생성/편집
cd ~/agenix-secrets
agenix -e secrets/github-token.age

# 변경사항 커밋
git add secrets/github-token.age
git commit -m "Add GitHub token"
git push
```

### 3. dotfiles에서 사용

시크릿은 다음 경로에 복호화됩니다:
- `~/.secrets/github-token`
- `~/.secrets/openai-api-key`

사용 예제:

```nix
# 환경 변수로 설정
home.sessionVariables = {
  OPENAI_API_KEY = "$(cat ${config.age.secrets.openai-api-key.path})";
};

# Git credential helper에서 사용
credential.helper = "!f() { echo \"password=$(cat ${config.age.secrets.github-token.path})\"; }; f";
```

## 필수 조건

1. SSH 키가 있어야 합니다 (`~/.ssh/id_ed25519` 또는 `~/.ssh/id_rsa`)
2. 해당 SSH 키의 공개 키가 `secrets.nix`에 등록되어 있어야 합니다
3. agenix-secrets 저장소에 대한 읽기 권한이 있어야 합니다

## 문제 해결

### 시크릿이 복호화되지 않는 경우

1. SSH 키 확인:
   ```bash
   ls -la ~/.ssh/id_ed25519 ~/.ssh/id_rsa
   ```

2. 공개 키가 secrets.nix에 있는지 확인:
   ```bash
   ssh-keygen -y -f ~/.ssh/id_ed25519
   ```

3. agenix-secrets 저장소 접근 권한 확인:
   ```bash
   git ls-remote git@github.com:username/agenix-secrets.git
   ```

### 새로운 시스템 추가

1. 새 시스템의 SSH 공개 키 생성
2. agenix-secrets/secrets.nix에 키 추가
3. 모든 시크릿 파일 재암호화:
   ```bash
   cd ~/agenix-secrets
   agenix -r
   ```

## 보안 주의사항

- 시크릿 저장소는 반드시 비공개로 유지하세요
- SSH 키는 안전하게 보관하세요
- 시크릿 파일의 권한은 600으로 자동 설정됩니다
- 복호화된 시크릿은 `~/.secrets/` 디렉토리에만 저장됩니다