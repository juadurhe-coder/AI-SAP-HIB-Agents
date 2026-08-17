@echo off
title Configurando Entorno Antigravity IDE
echo Iniciando configuracion automatica de Antigravity...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0.agents\scripts\utils\setup-environment.ps1"
pause
