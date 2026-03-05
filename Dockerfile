FROM python:3.12-alpine AS builder
WORKDIR /build
RUN apk add --no-cache gcc musl-dev postgresql-dev python3-dev
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

FROM python:3.12-alpine AS runtime

RUN apk add --no-cache libpq wget

RUN addgroup -S flaskgroup
RUN adduser -S flaskuser -G flaskgroup

WORKDIR /app

ENV PATH="/usr/local/bin:${PATH}"

COPY --from=builder /install/ /usr/local/
COPY . .

RUN chown -R flaskuser:flaskgroup /app

USER flaskuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8000/api/health || exit 1

CMD [ "gunicorn", "--bind", "0.0.0.0:8000", "flask_app:app" ]