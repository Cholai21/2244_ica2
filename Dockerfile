FROM ubuntu:latest

# Install Nginx
RUN apt-get update && apt-get install -y nginx

# Copy website files into Nginx default directory
COPY . /var/www/html/

# Expose port 80 to serve the website
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]

