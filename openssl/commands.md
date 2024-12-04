# Generate a CA key and certificate
openssl genpkey -algorithm RSA -out ca-key.pem -pkeyopt rsa_keygen_bits:2048
openssl req -x509 -new -sha256 -days 1024 -key ca-key.pem -out ca-cert.pem ## -config ca.cnf

# Generate a server key, certificate signing request (CSR) and certificate signed by the CA
openssl genpkey -algorithm RSA -out server-key.pem
openssl req -new -key server-key.pem -out server-csr.pem
openssl x509 -req -sha256 -in server-csr.pem -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -days 500

# Generate a client key,  certificate signing request (CSR) and certificate signed by the CA
openssl genpkey -algorithm RSA -out client-key.pem
openssl req -new -key client-key.pem -out client-csr.pem
openssl x509 -req -sha256 -in client-csr.pem -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out client-cert.pem -days 500

# Generate public key
openssl rsa -in client-key.pem -pubout -out client-public-key.pem

# Install a root CA certificate in the trust store (not working)
### https://ubuntu.com/server/docs/install-a-root-ca-certificate-in-the-trust-store#install-a-pem-format-certificate
```bash
sudo apt-get install -y ca-certificates
sudo cp local-ca.crt /usr/local/share/ca-certificates
sudo update-ca-certificates
```
