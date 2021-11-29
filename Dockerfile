FROM ubuntu:18.04

ENV LANG C.UTF-8
ENV TZ=America/Caracas
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt install git \
    python3-pip python3-pil build-essential \
    python3-lxml python-ldap3 wget python3-dev \
    python3-venv python3-wheel libxslt-dev libzip-dev \
    libldap2-dev libsasl2-dev python3-setuptools \
    libsasl2-dev  libxml2-dev libxslt1-dev \
    libjpeg-dev npm node-less python3-setuptools -y
RUN pip3 install --upgrade pip && pip3 install unicodecsv unicode pysftp libsass
RUN adduser --system --quiet --shell=/bin/bash --no-create-home --gecos 'ODOO' --group odoo

RUN git clone https://gitlab.com/Yusuke1998/no-me-gusta-odoo-12.git --depth 1 /opt/odoo12/
RUN pip3 install firebase-admin -r /opt/odoo12/requirements.txt 

RUN mkdir -p /opt/odoo12/extra-addons /opt/odoo12/data /opt/odoo12/config /var/lib/odoo
RUN chown -R odoo /opt/odoo12

COPY ./entrypoint.sh /
COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

EXPOSE 8069 8071 8072

ENV ODOO_RC /opt/odoo12/config/odoo.conf

RUN chown -R odoo /var/lib/odoo
RUN ln -s /opt/odoo12/odoo-bin /usr/bin/odoo
RUN chown -R odoo /usr/bin/odoo && chmod +x /usr/bin/odoo

USER odoo

ENTRYPOINT ["/entrypoint.sh"]

CMD ["odoo"]