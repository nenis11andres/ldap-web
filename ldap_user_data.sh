#!/bin/bash
# Actualizar repositorios
yum update -y

# Instalar Docker
amazon-linux-extras install docker -y

# Iniciar el servicio Docker
systemctl start docker

# Habilitar Docker para que arranque al iniciar el sistema
systemctl enable docker

# Añadir usuario ec2-user al grupo docker para usar docker sin sudo (opcional)
usermod -aG docker ec2-user