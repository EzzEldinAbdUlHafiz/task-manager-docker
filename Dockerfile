FROM python:3.12-alpine AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-alpine AS runtime

# libpq = helps Python talk to PostgreSQL
RUN apk add --no-cache libpq wget && \ 
    addgroup -S flaskgroup && \
    adduser -S flaskuser -G flaskgroup

WORKDIR /app

COPY --from=builder /install/ /usr/local/
COPY . .

RUN chown -R flaskuser:flaskgroup /app

USER flaskuser

EXPOSE 8000

HEALTHCHECK --interval=10s --timeout=5s --start-period=30s --retries=5 \
    CMD wget -qO- http://localhost:8000/api/health || exit 1

CMD ["gunicorn", "-w", "2", "-b", "0.0.0.0:8000", "flask_app:app"]