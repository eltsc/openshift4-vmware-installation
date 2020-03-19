FROM gitlab/gitlab-runner

COPY ./*.crt /usr/local/share/ca-certificates/

RUN update-ca-certificates 