#!/bin/bash
# Actualizar paquetes
yum update -y

# Instalar Docker
amazon-linux-extras install docker -y

# Iniciar Docker y habilitar al arranque
systemctl start docker
systemctl enable docker

# Añadir ec2-user al grupo docker
usermod -a -G docker ec2-user

# Instalar Apache y mod_ssl
yum install -y httpd mod_ssl

# Crear directorio donde luego colocaremos los certificados
mkdir -p /etc/ssl/andres

# Crear archivo de configuración SSL para Apache (el contenido completo lo pondremos después)
cat <<EOF > /etc/httpd/conf.d/andres.work.gd.conf
<VirtualHost *:443>
    ServerName andres.work.gd

    SSLEngine on
    SSLCertificateFile /etc/ssl/andres/andres.work.gd.cer
    SSLCertificateKeyFile /etc/ssl/andres/andres.work.gd.key
    SSLCertificateChainFile /etc/ssl/andres/ca.cer

    ProxyPreserveHost On
    ProxyPass / http://localhost:8080/
    ProxyPassReverse / http://localhost:8080/

    ErrorLog /var/log/httpd/ssl_error.log
    CustomLog /var/log/httpd/ssl_access.log combined
</VirtualHost>

<VirtualHost *:80>
    ServerName andres.work.gd

    # Redirige todo el tráfico HTTP a HTTPS
    Redirect permanent / https://andres.work.gd/
</VirtualHost>

EOF

# Iniciar y habilitar Apache
systemctl enable httpd
systemctl start httpd

# Lanzar contenedor Docker
docker run -d --name websimple-app -p 8080:8080 andresnenis/websimple-app
