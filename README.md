Anytask [![Build Status](https://github.com/znick/anytask/actions/workflows/anytask.yml/badge.svg)](https://github.com/znick/anytask/actions)
=======

Used Python3.8

local install
-------------

Development installation commands:

    # ... clone ...
    # ... cd ...
    . deploy_local_beta/run.sh
    ./anytask/manage.py runserver 127.0.0.1:8019 -v 3 --traceback

To activate environment in already deployed project run
    
    . deploy_local_beta/activate.sh

Run deploy_local_beta/run.sh -h for more information.

## How to run locally in docker:
1. Create `app.env` file in root directory:
> cp app.env.example app.env
2. Run containers:
> docker-compose up -d
3. Access website at `localhost:8000`, emails at `localhost:9000`. Logs are printed to `./logs/full.log`