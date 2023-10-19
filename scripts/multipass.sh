# Single Node

sudo apt -y install bridge-utils cpu-checker libvirt-clients libvirt-daemon qemu qemu-kvm -y
kvm-ok
sudo snap install multipass
multipass launch --name foo
multipass exec foo -- lsb_release -a
multipass delete --purge foo
wget -qO- https://raw.githubusercontent.com/canonical/maas-multipass/main/maas.yml | multipass launch --name maas -c4 -m8GB -d32GB --cloud-init -
multipass list

mkdir -p /var/www/maas

cat <<EOF > /var/www/maas/index.html
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title>Hello, Nginx!</title>
</head>
<body>
    <h1>Hello, Nginx!</h1>
    <p>We have just configured our Nginx web server on Ubuntu Server!</p>
</body>
</html>
EOF

cat <<EOF | tee /etc/nginx/sites-enabled/maas
server {
    listen 80;
    listen [::]:80;

    server_name maas www.maas;

    location / {
        proxy_pass http://10.244.114.158:5240;
    }
}
EOF

cat <<EOF > /etc/nginx/sites-enabled
server {
       listen 5240;
       listen [::]:5240;

       server_name maas.appkins.io;

       root /var/www/maas;
       index index.html;

       location /MAAS/ {
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_pass http://10.244.114.158:5240;
       }
}
EOF

curl "http://10.244.114.158:5240/MAAS"
