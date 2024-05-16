#!/bin/bash
virtualenv venv
source venv/bin/activate
pip install pyinstaller .
pyinstaller netexec.spec