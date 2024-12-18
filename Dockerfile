FROM jenkins/jenkins:lts

# Cambiar a usuario root temporalmente para instalar los paquetes necesarios
USER root

# Actualizar los paquetes e instalar Python3, pip3 y dependencias necesarias
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-venv \
        openjdk-17-jre-headless \
        wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Crear un entorno virtual y usarlo para instalar pytest
RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir pytest flask

# Descargar WireMock standalone jar
RUN mkdir -p /opt/wiremock \
    && wget -qO /opt/wiremock/wiremock.jar https://repo1.maven.org/maven2/org/wiremock/wiremock-standalone/3.10.0/wiremock-standalone-3.10.0.jar

# Agregar WireMock y el entorno virtual al PATH del usuario Jenkins
ENV PATH="/opt/venv/bin:/opt/wiremock:$PATH"

# Cambiar de nuevo al usuario Jenkins
USER jenkins

# Exponer el puerto predeterminado de Jenkins y WireMock
EXPOSE 8080
EXPOSE 50000
EXPOSE 8081 
# Comando predeterminado
CMD ["/usr/bin/tini", "--", "/usr/local/bin/jenkins.sh"]
