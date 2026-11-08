@echo off
title Doctors App Server
echo ============================================
echo Starting Doctors App on http://localhost:8080
echo ============================================
cd /d "%~dp0"
start http://localhost:8080
python -m http.server 8080 --directory "build\web"
pause
