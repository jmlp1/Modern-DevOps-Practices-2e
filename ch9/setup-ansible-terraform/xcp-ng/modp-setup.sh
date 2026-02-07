#!/bin/bash
set -euo pipefail
trap 'echo "⚠️ Script interrupted. Exiting..."; exit 1' INT TERM

exec > >(tee -i install.log)
exec 2>&1

echo "🔧 Starting Kubernetes tooling installation..."

check_command() {
  command -v "$1" &> /dev/null
}

install_docker() {
  if check_command docker; then
    echo "✅ Docker already installed. Skipping..."
    return
  fi

  echo "🐳 Installing Docker..."
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl gnupg lsb-release
  sudo install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable docker
  sudo systemctl start docker

  if ! sudo docker info &> /dev/null; then
    echo "❌ Docker failed to start."
    exit 1
  fi
  echo "✅ Docker installed and running."
}

install_minikube() {
  if check_command minikube; then
    echo "✅ Minikube already installed. Skipping..."
    return
  fi

  echo "📦 Installing Minikube..."
  curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo install minikube-linux-amd64 /usr/local/bin/minikube
  rm minikube-linux-amd64
}

install_kubectl() {
  if check_command kubectl; then
    echo "✅ kubectl already installed. Skipping..."
    return
  fi

  echo "📦 Installing kubectl..."
  KUBECTL_VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | tr -d '\r\n')
  if [[ -z "$KUBECTL_VERSION" ]]; then
    echo "❌ Failed to fetch a valid kubectl version."
    exit 1
  fi

  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
  chmod +x kubectl
  sudo mv kubectl /usr/local/bin/
  echo "✅ kubectl ${KUBECTL_VERSION} installed successfully."
}

install_kubectx_kubens() {
  if check_command kubectx && check_command kubens; then
    echo "✅ kubectx and kubens already installed. Skipping..."
    return
  fi

  echo "🔄 Installing kubectx and kubens..."
  sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
  sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
  sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
}

install_kompose() {
  if check_command kompose; then
    echo "✅ Kompose already installed. Skipping..."
    return
  fi

  echo "📦 Installing Kompose..."
  curl -L https://github.com/kubernetes/kompose/releases/latest/download/kompose-linux-amd64 -o kompose
  chmod +x kompose
  sudo mv kompose /usr/local/bin/kompose
}

install_helm() {
  if check_command helm; then
    echo "✅ Helm already installed. Skipping..."
    return
  fi

  echo "🎯 Installing Helm..."
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
  chmod 700 get_helm.sh
  ./get_helm.sh
  rm get_helm.sh
}

install_terraform() {
  if check_command terraform; then
    echo "✅ Terraform already installed. Skipping..."
    return
  fi

  echo "🏗️ Installing Terraform..."
  sudo apt-get update
  sudo apt-get install -y gnupg software-properties-common
  
  wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
  
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list
  
  sudo apt-get update
  sudo apt-get install -y terraform
  
  echo "✅ Terraform $(terraform version | head -n1) installed successfully."
}

install_powershell() {
  if check_command pwsh; then
    echo "✅ PowerShell already installed. Skipping..."
    return
  fi

  echo "🖥️ Installing PowerShell..."
  wget -q https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb
  sudo dpkg -i packages-microsoft-prod.deb
  rm packages-microsoft-prod.deb
  sudo apt-get update
  sudo apt-get install -y powershell
}

install_k9s() {
  if check_command k9s; then
    echo "✅ k9s already installed. Skipping..."
    return
  fi

  echo "📺 Installing k9s..."
  K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f4)
  curl -L "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz" -o k9s.tar.gz
  tar -xzf k9s.tar.gz k9s
  sudo mv k9s /usr/local/bin/
  rm k9s.tar.gz
  echo "✅ k9s ${K9S_VERSION} installed successfully."
}

install_kubetail() {
  if check_command kubetail; then
    echo "✅ kubetail already installed. Skipping..."
    return
  fi

  echo "📜 Installing kubetail..."
  sudo curl -L https://raw.githubusercontent.com/johanhaleby/kubetail/master/kubetail -o /usr/local/bin/kubetail
  sudo chmod +x /usr/local/bin/kubetail
  echo "✅ kubetail installed successfully."
}

start_minikube() {
  echo "🚀 Starting Minikube with Docker driver..."
  minikube start --driver=docker || {
    echo "❌ Minikube failed to start"
    exit 1
  }
}

verify_tools() {
  echo "🔍 Verifying installations..."
  for tool in docker kubectl minikube helm terraform kubectx kubens kompose pwsh k9s kubetail; do
    if ! check_command $tool; then
      echo "❌ $tool installation failed."
      exit 1
    fi
  done
  echo "🎉 All tools installed and verified successfully!"
}

# Run all installers
install_docker
install_minikube
install_kubectl
install_kubectx_kubens
install_kompose
install_helm
install_terraform
install_powershell
install_k9s
install_kubetail
start_minikube
verify_tools
