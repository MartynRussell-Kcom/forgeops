#!/usr/bin/env bash

# install packages
tool=apt-get
#tool=yum

# Original:
sudo $tool update -y && sudo $tool install git docker -y

# install AWS kubectl
sudo $tool install kubectl -y

if [ $? -ne 0 ]; then
	# Upstream (pay attention to the architecture here!):
	curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

	# For our version (1.14):
	# curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl
	#
	# Original:
	# curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/kubectl

	chmod +x ./kubectl
	sudo mv ./kubectl /usr/local/bin/
fi

# install Helm

# Remove existing symlink if it exists.
sudo rm -f /usr/local/bin/helm /usr/local/bin/helm2 /usr/local/bin/helm3

# Original
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > get_helm.sh
chmod +x ./get_helm.sh
./get_helm.sh
sudo mv /usr/local/bin/helm /usr/local/bin/helm3
rm get_helm.sh

# Suggested AWS version (2.16.1)
curl https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get | bash
sudo mv /usr/local/bin/helm /usr/local/bin/helm2
sudo ln -s /usr/local/bin/helm2 /usr/local/bin/helm

# install aws-iam-authenticator
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
sudo mv ./aws-iam-authenticator /usr/local/bin

# install pip
pip install --upgrade pip
# https://stackoverflow.com/questions/26302805/pip-broken-after-upgrading
hash -r
pip install --upgrade awscli
