#!/usr/bin/env python
from app import create_app

if __name__ == '__main__':
    my_app = create_app()
    my_app.run()
