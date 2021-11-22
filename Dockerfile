FROM ubuntu:18.04

ENV LANG C.UTF-8
ENV TZ=America/Caracas
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update \
    && apt install git python3-pip python3-pil build-essential \
    python3-lxml python-ldap3 wget python3-dev \
    python3-venv python3-wheel libxslt-dev libzip-dev \
    libldap2-dev libsasl2-dev python3-setuptools \
    libsasl2-dev  libxml2-dev libxslt1-dev \
    libjpeg-dev npm node-less -y
RUN apt update && apt install -y python3-setuptools
RUN pip3 install --upgrade pip
RUN pip3 install unicodecsv unicode pysftp libsass
RUN adduser --system --quiet --shell=/bin/bash --no-create-home --gecos 'ODOO' --group odoo

ENV ODOO_SRC odoo

VOLUME [ "/opt/odoo12/data", "/opt/odoo12/extra-addons", "/var/lib/odoo" ]

RUN git clone https://gitlab.com/Yusuke1998/no-me-gusta-odoo-12.git --depth 1 /opt/odoo12/
RUN pip3 install -r /opt/odoo12/requirements.txt
RUN mkdir -p /opt/odoo12/extra-addons \
    && mkdir -p /opt/odoo12/data \
    && mkdir -p /var/lib/odoo \
    && chown -R odoo /opt/odoo12

COPY ./entrypoint.sh /
COPY ./config/odoo.conf /opt/odoo12

EXPOSE 8069 8071 8072

ENV ODOO_RC /opt/odoo12/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

RUN chown -R odoo /opt/odoo12
RUN chown -R odoo /var/lib/odoo
RUN chown odoo /opt/odoo12/odoo.conf
RUN ln -s /opt/odoo12/odoo-bin /usr/bin/odoo
RUN chown -R odoo /usr/bin/odoo
RUN chmod +x /usr/bin/odoo

USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]