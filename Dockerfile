# 1. 베이스 이미지: nginx 최신 버전 사용
FROM nginx:latest

# 2. 내가 만든 HTML 파일을 nginx 기본 서빙 경로에 복사
COPY app/index.html /usr/share/nginx/html/index.html

# 3. 80번 포트 오픈 (nginx 기본 포트)
EXPOSE 80