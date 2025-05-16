output "nginx_apache_public_ip" {
  description = "IP pública del servidor Nginx/Apache"
  value       = aws_instance.web_server.public_ip
}

output "ldap_server_private_ip" {
  value = aws_instance.ldap_server.private_ip
  description = "IP privada de la instancia LDAP"
}
