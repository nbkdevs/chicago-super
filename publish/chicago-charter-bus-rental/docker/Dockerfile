FROM alpine:3.20
LABEL org.opencontainers.image.title="Chicago Charter Bus Rental"
LABEL org.opencontainers.image.description="Reference image linking to Chicago group charter bus rental."
LABEL org.opencontainers.image.url="https://chicagosupercoachbus.com/"

COPY README.md /README.md

ENV CHICAGO_CHARTER_BUS_RENTAL_HOMEPAGE=https://chicagosupercoachbus.com/

CMD ["sh", "-c", "echo 'Chicago Charter Bus Rental' && echo \"$CHICAGO_CHARTER_BUS_RENTAL_HOMEPAGE\" && cat /README.md"]
