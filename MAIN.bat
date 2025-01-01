echo off
color A
chcp 65001 >nul
title TICKET TOOL

:start
call :banner

:menu
for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set BS=%
echo.
echo.
echo ╚╗═ 1.隨機連點器
echo ░╚╗═2.YES24 TICKET
echo ░░╚╗═3.ibon
echo ░░░╚╗═4.拓元(tixcraft)
echo ░░░░╚╗═5.Ticket PLUS
echo ░░░░░╚══6.KKTIX
echo ╔═7.結束
echo.
echo ════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
echo.
echo ░═╗ 選擇功能
set /p input=%BS%
if /I %input% EQU 1 start .\auto-clicker.bat
if /I %input% EQU 2 start http://ticket.yes24.com/Pages/English/Perf/FnPerfDeail.aspx?IdPerf=51547
if /I %input% EQU 3 start https://ticket.ibon.com.tw/
if /I %input% EQU 4 start https://tixcraft.com/
if /I %input% EQU 5 start https://ticketplus.com.tw/
if /I %input% EQU 6 start https://kktix.com/
if /I %input% EQU 7 start exit
exit

cls
goto start

:banner
echo.
echo.
echo                   ████████ ██  ██████ ██   ██ ███████ ████████     ████████  ██████   ██████  ██
echo                      ██    ██ ██      ██  ██  ██         ██           ██    ██    ██ ██    ██ ██
echo                      ██    ██ ██      █████   █████      ██           ██    ██    ██ ██    ██ ██
echo                      ██    ██ ██      ██  ██  ██         ██           ██    ██    ██ ██    ██ ██
echo                      ██    ██  ██████ ██   ██ ███████    ██           ██     ██████   ██████  ███████
echo.
echo.
