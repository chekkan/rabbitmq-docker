FROM mcr.microsoft.com/windows/servercore:ltsc2019

#install chocolatey
RUN @powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

#install rabbitmq
RUN choco install -y rabbitmq --version 3.7.17

ENV ERLANG_HOME C:\\Program Files\\erl10.4
ENV ERLANG_SERVICE_MANAGER_PATH C:\\Program Files\\erl10.4\\erts-10.4\\bin

ENV RABBITMQ_SERVER C:\\Program Files\\RabbitMQ Server\\rabbitmq_server-3.7.17
ENV RABBITMQ_BASE C:\\RabbitMQ
RUN mkdir %RABBITMQ_BASE%
ENV RABBITMQ_CONFIG_FILE C:\\rabbitmq
RUN setx PATH "%PATH%;%RABBITMQ_SERVER%\sbin"

# WORKDIR ${RABBIT_MQ_HOME}\\sbin

# stop and remove windows service created by chocolatey
RUN rabbitmq-service.bat stop
RUN rabbitmq-service.bat remove

RUN rabbitmq-plugins.bat enable rabbitmq_management

COPY ["rabbitmq.conf"," C:/"]

ENV RABBITMQ_LOGS=- RABBITMQ_SASL_LOGS=-

EXPOSE 5672 15672
CMD "cmd /C rabbitmq-server.bat"