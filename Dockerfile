FROM python:3.6-slim

RUN pip install pyyaml requests

ADD assets/ /opt/resource/

RUN chmod +x /opt/resource/*
