FROM httpd:2.4-alpine

# Remover a página padrão "It works!"
RUN rm -rf /usr/local/apache2/htdocs/*

# Copiar os arquivos para o diretório de conteúdo do Apache
COPY index.html /usr/local/apache2/htdocs/
COPY script.js /usr/local/apache2/htdocs/
COPY style.css /usr/local/apache2/htdocs/

# Expor a porta 80
EXPOSE 80
