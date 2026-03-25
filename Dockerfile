# -------- Build Stage --------
FROM eclipse-temurin:21-jdk-jammy AS builder
WORKDIR /app
COPY app.java .
RUN javac app.java
# -------- Runtime Stage --------
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=builder /app/app.class .
EXPOSE 8080
CMD ["java", "app"]
