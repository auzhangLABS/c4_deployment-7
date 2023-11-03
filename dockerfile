FROM python:3.7

RUN git clone https://github.com/auzhangLABS/c4_deployment-7.git

WORKDIR c4_deployment-7

RUN pip install -r requirements.txt

RUN pip install mysqlclient

RUN pip install gunicorn

RUN python database.py

# RUN python load_data.py

EXPOSE 8000

ENTRYPOINT python -m gunicorn app:app -b 0.0.0.0
