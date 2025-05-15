# Usar una imagen base de Tomcat
FROM tomcat:9.0

# Eliminar cualquier aplicación predeterminada de Tomcat
RUN rm -rf /usr/local/tomcat/webapps/*

# Copiar tu archivo .war dentro de la carpeta webapps de Tomcat
COPY websimple-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

# Exponer el puerto 8080
EXPOSE 8080

