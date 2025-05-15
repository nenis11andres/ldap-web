output "nginx_apache_public_ip" {
  description = "IP pública del servidor Nginx/Apache"
  value       = aws_instance.web_server.public_ip
}


