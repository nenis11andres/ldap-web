#!/bin/bash

docker run -d \
  --name ldap-server \
  -p 389:389 \
  -p 636:636 \
  -e LDAP_ORGANISATION="Andres Corp" \
  -e LDAP_DOMAIN="andres.work.gd" \
  -e LDAP_ADMIN_PASSWORD="admin123" \
  -v $(pwd)/bootstrap.ldif:/container/service/slapd/assets/config/bootstrap/ldif/50-bootstrap.ldif \
  -v $(pwd)/users.ldif:/container/service/slapd/assets/config/bootstrap/ldif/60-users.ldif \
  osixia/openldap:1.5.0
