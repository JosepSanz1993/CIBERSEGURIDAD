# Blue team "SOC": Python + Flask. Llegeix els logs de les víctimes, aplica
# regles de detecció, demana triatge a una IA i mostra un panell web.
FROM python:3.12-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["python", "dashboard.py"]
