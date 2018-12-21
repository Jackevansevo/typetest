FROM python:alpine

ENV FLASK_ENV=development
ENV FLASK_APP=app.py

EXPOSE 5000/tcp

COPY . .

RUN pip install -r requirements.txt

CMD ["flask", "run", "--host=0.0.0.0"]
