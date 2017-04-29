
cd "%~dp0"
set api_key=
set secret_key=
::e.g. domain="www.cloudxns.net."
set "domain=example.com"
for /f "tokens=3 delims=:" %%a in ('ipconfig ^| findstr /n /r "10\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*"') do (set value=%%a)
if not defined value goto next
set value=%value:~1%
set "url=https://www.cloudxns.net/api2/ddns"
set "data={"domain":"%domain%","ip":"%value%"}"
>s.txt set /p=%data%<nul
call :api
curl -s -k -X POST -H "%header1%" -H "%header2%" -H "%header3%" -H "%header4%" --data-raw %data% %url%
:next
::get domainid
set "url=https://www.cloudxns.net/api2/domain"
set "data="
call :api
curl -s -k -X GET -H "%header1%" -H "%header2%" -H "%header3%" -H "%header4%" -d "%data%" %url% >info.txt
set count=0

:whilet
set /a count=%count%+2
for /f "tokens=%count% delims=[]{}" %%a in (info.txt) do (set strinfo=%%a)
for /f "tokens=1,2 delims= " %%a in ('echo %strinfo%') do (
if %%~b==domain":"bitweb.ga. (set domainidt=%%~a) else goto whilet
)

for /f tokens^=3^ delims^=^" %%a in ('echo %domainidt%') do (set domainid=%%~a)
echo %domainid%
set "url=https://www.cloudxns.net/api2/record/%domainid%?host_id=0"
set "data="
call :api
curl -s -k -X GET -H "%header1%" -H "%header2%" -H "%header3%" -H "%header4%" -d "%data%" %url% >info.txt

set count=0
:while2
set /a count=%count%+2
for /f "tokens=%count% delims=[]{}" %%a in (info.txt) do (set strinfo=%%a)
for /f "tokens=1,3 delims= " %%a in ('echo %strinfo%') do (
if %%~b==host":"ftp6 (set recordidt=%%~a) else goto while2
)
for /f tokens^=3^ delims^=^" %%a in ('echo %recordidt%') do (set recordid=%%~a)
echo %recordid%

::change v6
for /f "tokens=4 delims=. " %%a in ('ipconfig ^| findstr /r "200[0-9]:.*:.*:.*:.*:.*"') do (set value=%%a)
echo %value%
set "url=https://www.cloudxns.net/api2/record/%recordid%"
set "data={"domain_id":"%domainid%","host":"ftp6","value":"%value%","type":"AAAA"}"
call :api
curl -s -k -X GET -H "%header1%" -H "%header2%" -H "%header3%" -H "%header4%" -d "%data%" "%url%"
pause
exit
:api
for /f "tokens=1,2,3,4,5,6" %%a in ('ltime') do (set ltime=%%a^ %%b^ %%c^ %%d^ %%e^ %%f)
set "mac_raw=%api_key%%url%%data%%ltime%%secret_key%"
for /f "tokens=1" %%a in ('md5 -l -d"%mac_raw%"') do (set mac=%%a)
echo %mac%
set header1=API-HMAC:%mac%
set header2=API-FORMAT:json
set header3=API-REQUEST-DATE:%ltime%
set header4=API-KEY:%api_key%
goto :EOF

