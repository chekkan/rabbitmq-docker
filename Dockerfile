FROM mcr.microsoft.com/windows/servercore:ltsc2019

#install chocolatey
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# $ProgressPreference: https://github.com/PowerShell/PowerShell/issues/2138#issuecomment-251261324
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

RUN choco install -y erlang --version=21.2

ENV ERLANG_HOME C:\\Program Files\\erl10.2
ENV ERLANG_SERVICE_MANAGER_PATH C:\\Program Files\\erl10.2\\erts-10.2\\bin

ENV RABBITMQ_SERVER C:\\Program Files\\RabbitMQ Server\\rabbitmq_server-3.7.17
RUN mkdir $env:RABBITMQ_SERVER
ENV RABBITMQ_BASE C:\\RabbitMQ
RUN mkdir $env:RABBITMQ_BASE
ENV RABBITMQ_CONFIG_FILE C:\\rabbitmq
RUN setx /M PATH ('{0};{1}\sbin' -f $env:PATH, $env:RABBITMQ_SERVER);

ENV RABBITMQ_VERSION 3.7.17

# https://www.rabbitmq.com/install-windows-manual.html
RUN $url = 'https://github.com/rabbitmq/rabbitmq-server/releases/download/v{0}/rabbitmq-server-windows-{0}.zip' -f $env:RABBITMQ_VERSION; \
	Write-Host ('Downloading {0} ...' -f $url); \
	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
	Invoke-WebRequest -Uri $url -OutFile rabbit.zip; \
	\
	Write-Host 'Expanding ...'; \
	Expand-Archive -Path rabbit.zip -DestinationPath C:\\; \
	\
	Write-Host 'Renaming ...'; \
	Get-ChildItem -LiteralPath ('rabbitmq_server-{0}' -f $env:RABBITMQ_VERSION) -Recurse | Move-Item  -Destination $env:RABBITMQ_SERVER; \
	\
	Write-Host 'Removing ...'; \
	Remove-Item rabbit.zip -Force; \
	\
# TODO verification
	\
	Write-Host 'Complete.'

RUN rabbitmq-plugins enable rabbitmq_management

COPY ["rabbitmq.conf"," C:/"]

ENV RABBITMQ_LOGS=- RABBITMQ_SASL_LOGS=-

EXPOSE 5672 15672
CMD "rabbitmq-server"