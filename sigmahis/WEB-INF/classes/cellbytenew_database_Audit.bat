#El servicio de oracle debe estar creado en sistema local con nombre de TNS 'cellbyte'
#Este programa genera respaldo en misma carpeta donde reside o de donde sea llamado y crear archivo con fecha y hace respaldo de schema.

@echo off
cls

FOR /f "tokens=1-4 delims=/ " %%a in ('date /t') do (
set day=%%a
set MM=%%d
set dd=%%b
set yy=%%c
)

exp userid=cellbyteaudit/cellbyteaudit@orcl compress=Y file="F:\cellbytebackup\%day%%dd%%MM%%yy%_cellbyteAudit40.74.dmp" owner=cellbyteaudit
