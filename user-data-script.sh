#!bin/bash
sudo apt update -y && sudo apt install docker.io
sudo systemctl start docker
sudo usermod aG ubuntu
docker run -p 8080:80 nginx
