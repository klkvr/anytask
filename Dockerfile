###########
# BUILDER #
###########

# pull official base image
FROM python:2.7-alpine as builder

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# install dependencies
RUN pip install --upgrade pip
# install psycopg2 dependencies  #
RUN apk update alpine-sdk \
    && apk add gcc python-dev musl-dev \
        libxml2-dev libxslt-dev \
        freetype-dev libpng-dev libjpeg-turbo-dev \
        build-base libzmq zeromq-dev \
    && apk add --no-cache mariadb-dev  # for MySQL

# lint
RUN pip install --upgrade pip
RUN pip install flake8

COPY . .
RUN flake8 anytask

# install dependencies
COPY ./requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /usr/src/app/wheels -r requirements.txt


#########
# FINAL #
#########

# pull official base image
FROM python:2.7-alpine

ENV ANYTASK_HOME=/home/anytask

# create directory for the anytask user
RUN mkdir -p $ANYTASK_HOME
RUN mkdir -p $ANYTASK_HOME/anytask/static
RUN mkdir -p $ANYTASK_HOME/anytask/media

# create the anytask user
RUN addgroup -S anytask && adduser -S anytask -G anytask

WORKDIR $ANYTASK_HOME

# install dependencies
RUN apk update \
    && apk add libpq libjpeg libxslt \
        git \
        busybox-initscripts \
    && apk add --no-cache mariadb-dev \
    && apk add --update busybox-suid


COPY --from=builder /usr/src/app/wheels /wheels
COPY --from=builder /usr/src/app/requirements.txt .
RUN pip install --no-cache /wheels/*

### Cron
ENV CRON_DIR=/etc/crontabs
# Copy cron file to the cron directory
COPY scripts/anytask-cron $CRON_DIR/anytask-cron
# Give execution rights on the cron job
RUN chmod 0755 $CRON_DIR/anytask-cron
# Apply cron job
RUN crontab $CRON_DIR/anytask-cron
# Create the log files
WORKDIR /var/log/cron
RUN touch \
    cleanup.log \
    cleanupregistration.log \
    check_contest.log \
    send_freezed_run_id_notify.log \
    send_notifications.log \
    send_task_notifications.log \
    send_mail_notifications.log \
    update_index.partial.log \
    update_index.log \
    check_task_taken_expires.log \
    healthcheck.log

WORKDIR $ANYTASK_HOME
### /Cron

# copy entrypoint.sh
COPY ./entrypoint.sh $ANYTASK_HOME

# copy project
COPY . $ANYTASK_HOME
RUN git submodule update --init --recursive

# chown all the files to the anytask user
RUN chown -R anytask:anytask $ANYTASK_HOME

# change to the anytask user
# breaks crond
#USER anytask

# gunicorn uses this to find application
ENV PYTHONPATH=$ANYTASK_HOME/anytask

WORKDIR $ANYTASK_HOME

# run entrypoint.sh
ENTRYPOINT ["/home/anytask/entrypoint.sh"]
