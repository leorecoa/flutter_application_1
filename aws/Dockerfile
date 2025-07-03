FROM debian:bullseye-slim

# Instalar dependências
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Definir variáveis de ambiente
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$FLUTTER_HOME/bin:$PATH

# Instalar Flutter
RUN git clone -b stable https://github.com/flutter/flutter.git $FLUTTER_HOME

# Verificar instalação e pré-baixar dependências
RUN flutter doctor -v
RUN flutter config --enable-web

# Diretório de trabalho
WORKDIR /app

# Copiar arquivos do projeto
COPY . .

# Obter dependências
RUN flutter pub get

# Build para web
RUN flutter build web --release

# Expor porta
EXPOSE 8080

# Comando para servir o app
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080", "--web-hostname", "0.0.0.0"]