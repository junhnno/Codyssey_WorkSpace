# 개발 워크스테이션 구축

## 1. 프로젝트 개요

로컬 개발 환경(터미널, Docker, Git, GitHub)을 직접 구축하고
각 도구의 기본 사용법을 실습하여 개발 워크스테이션을 완성한다.

## 2. 실행 환경

| 항목 | 값 |
|---|---|
| OS | Windows 10 (MINGW64) |
| 쉘 / 터미널 | Git Bash (bash) |
| Docker 버전 | 29.2.1 |
| Git 버전 | 2.52.0.windows.1 |

## 3. 수행 항목 체크리스트

- [x] 터미널 조작 로그
- [x] 권한 실습
- [x] Docker 설치 및 기본 점검
- [x] Docker 기본 운영 명령
- [x] 컨테이너 실행 실습
- [x] Dockerfile 커스텀 이미지 제작
- [x] 포트 매핑 및 접속 증거
- [x] 바인드 마운트
- [x] Docker 볼륨 영속성 검증
- [x] Git 설정 및 GitHub 연동

## 3-1. 프로젝트 디렉토리 구조
```
Codyssey_WorkSpace/
├── .git/           # Git 관리 폴더 (자동 생성, 수정 금지)
├── app/            # 웹서버 소스코드
│   └── index.html  # nginx가 서빙할 HTML 파일
├── practice/       # 터미널 조작 실습용 폴더
│   └── hello.txt   # 실습 중 생성한 파일
├── Dockerfile      # 커스텀 이미지 빌드 설계도
└── README.md       # 기술 문서
```

**구성 기준**
- `app/` → 웹서버 소스코드를 별도 폴더로 분리하여 Dockerfile의 COPY 경로를 명확하게 관리
- `practice/` → 터미널 실습 내용을 저장소 루트와 분리하여 실습 흔적을 명확히 구분
- `Dockerfile` → 저장소 루트에 위치시켜 `docker build .` 명령을 루트에서 바로 실행 가능하게 구성
## 4. 터미널 조작 로그

### 현재 위치 확인
```bash
$ pwd
/c/Main_Folder/Coding/Codyssey_WorkSpace/Codyssey_WorkSpace
```

### 목록 확인 (숨김 파일 포함)
```bash
$ ls -la
total 8
drwxr-xr-x 1 aptl4 197609    0  4월  1 14:22 ./
drwxr-xr-x 1 aptl4 197609    0  4월  1 14:11 ../
drwxr-xr-x 1 aptl4 197609    0  4월  1 14:20 .git/
drwxr-xr-x 1 aptl4 197609    0  4월  1 14:22 practice/
-rw-r--r-- 1 aptl4 197609 2157  4월  1 14:18 README.md
```

### 폴더 생성 및 이동
```bash
$ mkdir practice
$ cd practice
$ pwd
/c/Main_Folder/Coding/Codyssey_WorkSpace/Codyssey_WorkSpace/practice
```

### 파일 생성
```bash
$ touch hello.txt
$ mkdir testdir
$ ls -la
total 0
drwxr-xr-x 1 aptl4 197609 0  4월  1 14:30 ./
drwxr-xr-x 1 aptl4 197609 0  4월  1 14:22 ../
-rw-r--r-- 1 aptl4 197609 0  4월  1 14:30 hello.txt
drwxr-xr-x 1 aptl4 197609 0  4월  1 14:30 testdir/
```

### 파일 내용 작성 및 확인
```bash
$ echo "Hello, Docker!" > hello.txt
$ cat hello.txt
Hello, Docker!
```

### 파일 복사
```bash
$ cp hello.txt hello_copy.txt
$ ls -la
total 2
drwxr-xr-x 1 aptl4 197609  0  4월  1 14:33 ./
drwxr-xr-x 1 aptl4 197609  0  4월  1 14:22 ../
-rw-r--r-- 1 aptl4 197609 15  4월  1 14:33 hello.txt
-rw-r--r-- 1 aptl4 197609 15  4월  1 14:34 hello_copy.txt
drwxr-xr-x 1 aptl4 197609  0  4월  1 14:30 testdir/
```

### 파일 이름 변경
```bash
$ mv hello_copy.txt hello_renamed.txt
$ ls -la
total 2
drwxr-xr-x 1 aptl4 197609  0  4월  1 14:39 ./
drwxr-xr-x 1 aptl4 197609  0  4월  1 14:22 ../
-rw-r--r-- 1 aptl4 197609 15  4월  1 14:33 hello.txt
-rw-r--r-- 1 aptl4 197609 15  4월  1 14:34 hello_renamed.txt
drwxr-xr-x 1 aptl4 197609  0  4월  1 14:30 testdir/
```

### 파일 및 폴더 삭제
```bash
$ rm hello_renamed.txt
$ rm -r testdir
$ ls -la
total 1
drwxr-xr-x 1 aptl4 197609  0  4월  1 14:41 ./
drwxr-xr-x 1 aptl4 197609  0  4월  1 14:22 ../
-rw-r--r-- 1 aptl4 197609 15  4월  1 14:33 hello.txt
```
### 절대 경로 vs 상대 경로

**절대 경로** — 루트(`/`)부터 시작하는 전체 경로
```bash
cd /c/Main_Folder/Coding/Codyssey_WorkSpace
# 어디서 실행해도 항상 같은 위치로 이동
```

**상대 경로** — 현재 위치 기준으로 표현하는 경로
```bash
cd practice      # 현재 위치 안의 practice 폴더로 이동
cd ..            # 현재 위치에서 한 단계 위로 이동
cd ./app         # 현재 위치 안의 app 폴더로 이동 (./ 생략 가능)
```

**선택 기준**

| 상황 | 선택 | 이유 |
|---|---|---|
| 스크립트, 자동화 | 절대 경로 | 실행 위치가 달라도 항상 동일하게 동작 |
| 터미널 직접 입력 | 상대 경로 | 타이핑이 짧고 빠름 |
| Dockerfile COPY | 상대 경로 | 빌드 컨텍스트 기준으로 동작 |
| Docker 볼륨 마운트 | 절대 경로 | 정확한 호스트 경로 지정 필요 |
## 5. 권한 실습
### 권한 숫자 표기 규칙

권한은 소유자/그룹/others 3개 그룹으로 나뉘며 각 그룹의 권한을 숫자로 더해서 표현한다.
```
r (읽기)  = 4
w (쓰기)  = 2
x (실행)  = 1
없음      = 0
```

각 그룹의 권한을 더한 숫자 3개를 나열한다.
```
755  =  rwx r-x r-x
        ↑   ↑   ↑
        7   5   5
        소유자 그룹 others

7 = 4+2+1 = rwx (읽기+쓰기+실행)
5 = 4+0+1 = r-x (읽기+실행)
5 = 4+0+1 = r-x (읽기+실행)
```
Git Bash에서는 Windows NTFS 파일시스템 한계로 chmod가 동작하지 않아 Docker 컨테이너(진짜 Linux 환경) 내부에서 실습을 진행하였다. (트러블슈팅 1번 참고)

### 파일 권한 변경
```bash
$ touch test.txt
$ ls -la test.txt
-rw-r--r-- 1 root root 0 Apr  1 06:03 test.txt

$ chmod 777 test.txt
$ ls -la test.txt
-rwxrwxrwx 1 root root 0 Apr  1 06:03 test.txt

$ chmod 600 test.txt
$ ls -la test.txt
-rw------- 1 root root 0 Apr  1 06:03 test.txt

$ chmod 644 test.txt
$ ls -la test.txt
-rw-r--r-- 1 root root 0 Apr  1 06:03 test.txt
```

### 디렉토리 권한 변경
```bash
$ mkdir testdir
$ ls -la
drwxr-xr-x 2 root root 4096 Apr  1 06:04 testdir

$ chmod 700 testdir
$ ls -la
drwx------ 2 root root 4096 Apr  1 06:04 testdir

$ chmod 755 testdir
$ ls -la
drwxr-xr-x 2 root root 4096 Apr  1 06:04 testdir
```

## 6. Docker 설치 및 기본 점검

### Docker 버전 확인
```bash
$ docker --version
Docker version 29.2.1, build a5c7197
```

### Docker 데몬 동작 확인
```bash
$ docker info
Client:
 Version:    29.2.1
 Context:    desktop-linux
...
Server:
 Containers: 1
  Running: 1
  Paused: 0
  Stopped: 0
 Images: 1
 Server Version: 29.2.1
 OSType: linux
 Architecture: x86_64
 CPUs: 8
 Total Memory: 3.666GiB
```

## 7. Docker 기본 운영 명령

### 이미지 목록 확인
```bash
$ docker images
IMAGE                ID             DISK USAGE   CONTENT SIZE
hello-world:latest   452a468a4bf9       25.9kB         9.49kB
my-nginx:latest      c044e6fe08a0        237MB           63MB
mysql:8.0            a3dff78d8762       1.08GB          247MB
ubuntu:latest        186072bba1b2        119MB         31.7MB
```

### 컨테이너 목록 확인
```bash
$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES

$ docker ps -a
CONTAINER ID   IMAGE       COMMAND                  CREATED       STATUS                       PORTS                               NAMES
3bfa676c6f8f   mysql:8.0   "docker-entrypoint.s…"   2 weeks ago   Exited (255) 2 minutes ago   0.0.0.0:3306->3306/tcp, 33060/tcp   todos
```

### 로그 확인
```bash
$ docker logs todos
2026-03-12 03:21:47+00:00 [Note] [Entrypoint]: Entrypoint script for MySQL Server 8.0.45 started.
...
2026-03-12T03:22:03.690063Z 0 [System] [MY-010931] [Server] /usr/sbin/mysqld: ready for connections. port: 3306
```

### 리소스 확인
```bash
$ docker stats --no-stream
CONTAINER ID   NAME      CPU %     MEM USAGE / LIMIT   MEM %     NET I/O   BLOCK I/O   PIDS
(실행 중인 컨테이너 없음)
```

## 8. 컨테이너 실행 실습

### hello-world 실행
```bash
$ docker run hello-world
Hello from Docker!
This message shows that your installation appears to be working correctly.
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image.
 4. The Docker daemon streamed that output to the Docker client.
```

### ubuntu 컨테이너 진입 및 명령 실행
```bash
$ docker run -it ubuntu bash
root@0598df7fc24f:/# pwd
/
root@0598df7fc24f:/# ls
bin  dev  home  lib64  mnt  proc  run  srv  tmp  var
boot etc  lib   media  opt  root  sbin sys  usr
root@0598df7fc24f:/# echo "Hello from Ubuntu Container!"
Hello from Ubuntu Container!
root@0598df7fc24f:/# cat /etc/os-release
PRETTY_NAME="Ubuntu 24.04.4 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
```

### exec vs attach 차이 관찰

**exec 방식** — 새로운 프로세스를 추가로 실행하므로 exit 후에도 컨테이너가 유지된다.
```bash
$ docker run -it -d --name myubuntu ubuntu bash
$ docker exec -it myubuntu bash
root@f2cb6fe59267:/# exit
$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED         STATUS         NAMES
f2cb6fe59267   ubuntu    "bash"    3 minutes ago   Up 3 minutes   myubuntu
# 컨테이너가 여전히 실행 중
```

**attach 방식** — 메인 프로세스에 직접 연결하므로 exit 시 컨테이너도 종료된다.
```bash
$ docker attach myubuntu
root@f2cb6fe59267:/# exit
$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
# 컨테이너가 종료됨
```

## 9. Dockerfile 커스텀 이미지 제작

### 이미지 vs 컨테이너 — 빌드/실행/변경 관점

| 관점 | 이미지 | 컨테이너 |
|---|---|---|
| 빌드 | `docker build`로 생성 | 이미지를 기반으로 생성 |
| 실행 | 실행되지 않음 (틀) | `docker run`으로 실행됨 |
| 변경 | 불변 (변경 불가) | 실행 중 내부 변경 가능 |
| 삭제 후 | 이미지는 그대로 남음 | 컨테이너 안의 변경사항 사라짐 |
| 재사용 | 하나의 이미지로 컨테이너 여러 개 생성 가능 | 각 컨테이너는 독립적 |
```
docker build → 이미지 생성 (불변의 틀)
                    ↓
docker run  → 컨테이너 생성 (실행 가능한 인스턴스)
                    ↓
내부 변경   → 컨테이너에만 반영, 이미지는 그대로
                    ↓
docker rm   → 컨테이너 삭제, 변경사항 사라짐
```
### 선택한 베이스 이미지
nginx:latest (웹서버 베이스 이미지 활용 — A 방식)

### Dockerfile
```dockerfile
# 베이스 이미지: nginx 최신 버전
FROM nginx:latest

# 내가 만든 HTML 파일을 nginx 기본 서빙 경로에 복사
COPY app/index.html /usr/share/nginx/html/index.html

# 80번 포트 오픈
EXPOSE 80
```

### 커스텀 포인트
| 항목 | 목적 |
|---|---|
| `FROM nginx:latest` | 웹서버 환경을 베이스로 사용 |
| `COPY app/index.html` | 기본 nginx 페이지를 내가 만든 HTML로 교체 |
| `EXPOSE 80` | nginx 기본 포트 명시 |

### 빌드 및 실행
```bash
$ docker build -t my-nginx .
[+] Building 18.1s (8/8) FINISHED
 => [1/2] FROM docker.io/library/nginx:latest
 => [2/2] COPY app/index.html /usr/share/nginx/html/index.html
 => exporting to image

$ docker run -d -p 8081:80 --name my-nginx-container my-nginx
d41eff40d2aa01927405b56c397c281988567907ba85f053da47d055939b5722
```

## 10. 포트 매핑 및 접속 증거

### 컨테이너 내부 포트로 직접 접속할 수 없는 이유

컨테이너는 격리된 네트워크 환경을 가진다. 컨테이너 내부의 포트는 외부(호스트)에서 직접 접근할 수 없다.
```
브라우저 → localhost:80 접속 시도
         → 호스트의 80번 포트로 요청
         → 컨테이너 내부 포트와 연결 안 됨
         → 접속 실패
```

포트 매핑(`-p`)으로 호스트 포트와 컨테이너 포트를 연결해야 한다.
```
docker run -p 8081:80 my-nginx
               ↑    ↑
          호스트  컨테이너

브라우저 → localhost:8081
         → 호스트 8081 포트
         → 컨테이너 80 포트로 전달
         → nginx 응답
         → 접속 성공
```

**포트 매핑이 필요한 이유**
- 컨테이너는 격리된 환경이라 보안상 외부 접근이 기본 차단됨
- 명시적으로 포트를 열어야 외부에서 접근 가능
- 같은 이미지로 여러 컨테이너를 다른 포트로 동시에 실행 가능
```bash
$ docker run -d -p 8081:80 --name my-nginx-container my-nginx
```

브라우저에서 `http://localhost:8081` 접속 성공:

<img width="1920" height="1080" alt="도커 접속 인증사진" src="https://github.com/user-attachments/assets/cdd85d7a-f7b5-4341-b81c-0f5c3f5af47a" />


## 11. 바인드 마운트

호스트의 `app/` 폴더와 컨테이너의 `/usr/share/nginx/html`을 연결하여 호스트에서 파일을 수정하면 컨테이너에 즉시 반영되는 것을 확인하였다.
```bash
$ docker run -d -p 8081:80 \
  -v "C:/Main_Folder/Coding/Codyssey_WorkSpace/Codyssey_WorkSpace/app:/usr/share/nginx/html" \
  --name my-nginx-container my-nginx
```

호스트에서 `index.html`에 "바인드 마운트 성공!" 문구 추가 후 브라우저 새로고침 시 즉시 반영됨:

<img width="1919" height="957" alt="바운드 마운트 성공 인증사진" src="https://github.com/user-attachments/assets/db5baf35-8523-45e4-af9c-4c02df20483e" />

## 12. Docker 볼륨 영속성 검증

### 볼륨 생성 및 연결
```bash
$ docker volume create myvolume
myvolume

$ docker volume ls
DRIVER    VOLUME NAME
local     myvolume
local     todos
```

### 컨테이너에서 데이터 저장
```bash
$ docker run -it --name volume-test -v myvolume:/mydata ubuntu bash
root@4f5241a3b361:/mydata# echo "volume persistence test" > volume_test.txt
root@4f5241a3b361:/mydata# cat volume_test.txt
volume persistence test
```

### 컨테이너 삭제 후 새 컨테이너에서 데이터 확인
```bash
$ docker stop volume-test
$ docker rm volume-test
$ docker run -it --name volume-test2 -v myvolume:/mydata ubuntu bash
root@bca9f2a17442:/# cat /mydata/volume_test.txt
volume persistence test
# 컨테이너가 삭제됐어도 데이터가 그대로 유지됨
```

## 13. Git 설정 및 GitHub 연동
```bash
$ git config --list --global
user.name=junhnno
user.email=withardor03@gmail.com
core.autocrlf=true
init.defaultbranch=main
credential.helper=manager
```

GitHub 저장소 연동 및 push 완료:
```bash
$ git add .
$ git commit -m "add Dockerfile, app, practice"
$ git push origin main
To https://github.com/junhnno/Codyssey_WorkSpace
   78e5af3..e3aca66  main -> main
```

## 14. 트러블슈팅

### 트러블슈팅 1 — Git Bash에서 chmod 미동작

- **문제**: Git Bash에서 `chmod 777 hello.txt` 실행 후 `ls -la`로 확인했으나 권한이 변경되지 않음
- **원인 가설**: Windows NTFS 파일시스템이 Linux 권한 체계를 지원하지 않아 chmod 명령이 무시됨
- **확인**: `chmod 777` 실행 후에도 `-rw-r--r--` (644) 그대로 유지됨
- **해결**: Docker Ubuntu 컨테이너(진짜 Linux 환경) 내부에서 chmod 실습 진행 → 정상 동작 확인

### 트러블슈팅 2 — 포트 충돌로 컨테이너 실행 실패

- **문제**: `docker run -d -p 8080:80 --name my-nginx-container my-nginx` 실행 시 오류 발생
- **원인 가설**: 호스트의 8080 포트를 다른 프로그램이 이미 사용 중
- **확인**: `bind: Only one usage of each socket address` 오류 메시지 확인
- **해결**: 포트를 8081로 변경하여 실행 → 정상 동작 확인

## 15. 검증 방법 — 재현 가능한 실행 방법

아래 명령어를 순서대로 실행하면 전체 환경을 재현할 수 있다.
```bash
# 1. 저장소 클론
git clone https://github.com/junhnno/Codyssey_WorkSpace
cd Codyssey_WorkSpace

# 2. 이미지 빌드
docker build -t my-nginx .

# 3. 포트 매핑으로 컨테이너 실행
docker run -d -p 8081:80 --name my-nginx-container my-nginx

# 4. 바인드 마운트로 실행 (개발용)
docker run -d -p 8081:80 \
  -v "C:/경로/app:/usr/share/nginx/html" \
  --name my-nginx-container my-nginx

# 5. 볼륨 생성 및 연결
docker volume create myvolume
docker run -it --name volume-test -v myvolume:/mydata ubuntu bash

# 6. 브라우저 접속 확인
# http://localhost:8081
```
- **확인**: `docker exec`로 컨테이너 내부 확인 시 `C:/Program Files/Git/usr/share/nginx/html` 경로로 마운트됨
- **해결**: 호스트 경로를 `"C:/Main_Folder/..."` Windows 형식으로 변경하여 실행 → 정상 동작 확인0
