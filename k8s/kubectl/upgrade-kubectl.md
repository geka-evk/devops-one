##  Step1: Run the below command to download the latest version of kubectl
```bash
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
```

##  Step2: Make kubectl executable
```bash
chmod +x kubectl
```

##  Step3: Move it to the directory where kubectl is already installed
```bash
sudo mv kubectl $(which kubectl)
```
