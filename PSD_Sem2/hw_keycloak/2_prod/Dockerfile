# Рекомендуемая сборка Keycloak для прода: build-time опции «запекаются»
# на этапе сборки, а контейнер стартует с --optimized (быстрее старт).
FROM quay.io/keycloak/keycloak:24.0 AS builder

ENV KC_DB=postgres \
    KC_HEALTH_ENABLED=true \
    KC_METRICS_ENABLED=true

RUN /opt/keycloak/bin/kc.sh build

FROM quay.io/keycloak/keycloak:24.0

COPY --from=builder /opt/keycloak/ /opt/keycloak/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized"]
