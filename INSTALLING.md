# ForgeRock with EKS / AWS

Documentation available here:
<https://backstage.forgerock.com/docs/platform/6.5/eks-cookbook/index.html#eks-cookbook>

## Environment
1. Copy template config and update it:

```
$ cd ~/Source/forgeops/etc
$ cp eks-env.template eks-env.cfg
```

2. Update `etc/eks-env.template`

## Tools

The versions of the tools are **VERY** important. Things break if this is not right. 

### Forgerock Recommended Versions

| Software                              | Version                                | Link                                             |
|---------------------------------------|----------------------------------------|--------------------------------------------------|
| Kubernetes client (kubectl)           | 1.16.0                                 | https://kubernetes.io/docs/tasks/kubectl/install |
| Kubernetes Helm                       | 2.11.0 (stable), 2.14.2 (leading edge) | https://github.com/helm/helm                     |
| Kubernetes context switcher (kubectx) | 0.7.0                                  | https://github.com/ahmetb/kubectx                |

The problem here is that the versions that FR recommends and that the FR ops repository downloads are not consistent. The versions available AWS are also out of step with with FR docs too. The ***helm*** and ***kubectl*** versions seem to be the most important to get right.

**WARNING:** Version recommended for kubectl is not available from AWS, expected 1.16, latest available is 1.14. Debian Buster offers 1.17.0

**WARNING:** Version recommended for helm is too modern at v3.x and causes issues later on, expected 2.11.0 / 2.14.2

**WARNING:** Version recommended for kubectx is too old in Debian Buster's packaging, expected 0.7.0, latest available is 0.6.2-1

### Used versions

1. Versions used that work are:

    | Software                              | Version          |
    |---------------------------------------|------------------|
    | Kubernetes client (kubectl)           | 1.17.0           |
    | Kubernetes Helm                       | 3.x (was 2.16.1) |
    | Kubernetes context switcher (kubectx) | 0.7.1            |

    **WARNING:** `helm` 2.16.1 is required to set up RBAC.

    **WARNING:** `helm` 3.x is required to deploy CDM.

2. Ensure you have Python Pip installed. On Debian you can use:

    ```
    $ apt-get install python-pip
    ```

3. Run `eks-setup`:

    **WARNING:** This needs fixing, DO NOT run this yet. Versions for `kubectl`, `kubectx` and `helm` are not correct

    ```
    $ cd ~/Source/forgeops/bin
    $ ./eks-setup
    ...
    ```

## Setting up EKS / Kubernetes

This part is documented in section 2.3.x titled **SECTION 2.3 - Setting up an Amazon EKS Environment for CDM**.

All scripts in the following steps are run from the same place:

```
$ cd ~/Source/forgeops/bin
```

**IMPORTANT:** In all of the following steps for the EKS setup, ensure after each script to update variables in `eks-env.cfg` from the output.

### Creating a Virtual Private Cloud

```
$ ./eks-create-vpc.sh
```

### Creating an Amazon EFS File System

```
$ ./eks-create-filesystem.sh
```

### Creating an Amazon S3 Bucket Policy

```
$ ./eks-create-s3-policy.sh
```

### Creating a Service Role

```
$ ./eks-create-service-role.sh
```

### Creating a Key Pair to Connecto Worker Nodes

**NOTE:** Only needs to be done once.

```
$ ./eks-create-keypair.sh
$ chown 400 ~/.ssh/*.pem
```

### Create DNS / Route53 for Service

**NOTE:** This can be skipped if this is already set up (e.g. a public set up). For private DNS configurations this is usually required.

In our case, we're using a private DNS suffix of ***eg.fr.kcom.com***, as I clearly don't have control over the ***kcom.com*** domain or subdomains.

You can do all of this quickly in Route53 in AWS. Make sure the VPC is attached to the domains and that the domain suffix matches the `eks-env.cfg` in use.

## Create a Bastion instance

**NOTE:** This can be skipped if using a public DNS set up.

This is used to test from inside the VPC. The reason this is needed is that DNS names won't resolve to test the service from a standard machine outside the AWS VPC set up.

- When deploying a Bastion, use the following link:

    <https://eu-west-1.console.aws.amazon.com/cloudformation/home?region=eu-west-1#/stacks/create/template?stackName=Linux-bastion&templateURL=https://aws-quickstart.s3.amazonaws.com/quickstart-linux-bastion/templates/linux-bastion.template>

- Specify the S3 template `https://aws-quickstart.s3.amazonaws.com/quickstart-linux-bastion/templates/linux-bastion.template`.
- Use CIDR of `0.0.0.0/1` or whatever you want to restrict it to.
- Make sure you specify an EC2 key pair. This should already exist as `fr-eks-clust-key`.
- Create and wait.
- Test it works using

    ```
    $ ssh ec2-user@52.213.235.183 -i ~/.ssh/fr-eks-clust-key.pem

           __|  __|_  )
           _|  (     /   Amazon Linux 2 AMI
          ___|\___|___|

    https://aws.amazon.com/amazon-linux-2/
    [ec2-user@ip-192-168-179-156 ~]$
    ```

    - The `.pem` file is created in SECTION 2.3.x.
    - The IP address can be found by looking at the Cloud Formation details for the ***Linux-bastion*** stack, under ***Outputs***.

- Set up VNC access, to do this follow the instructions here: <https://aws.amazon.com/premiumsupport/knowledge-center/ec2-linux-2-install-gui/>

    This will allow access remotely to a desktop with a browser.

## Creating and Setting Up a Kubernetes Cluster

This part is documented in section 2.4.x titled **SECTION 2.4 - Creating and Setting Up a Kubernetes Cluster**.

**NOTE:** If you already have a cluster created, comment out the line with `eks-create-cluster.sh` in `eks-up.sh` (ca. line 41).

Bring the cluster in Kubernetes up:

```
$ ./eks-up.sh
WARNING: The following components must be initialized before deployment:
  -Elastic File System (EFS)
  -IAM Service Role
  -VPC/Subnets
  -Control Plane Security Group
 These pre-requisites are outlined in the DevOps Documentation. Please ensure you have completed all before proceeding.

=> Have you copied the template file etc/eks-env.template to etc/eks-env.cfg and edited to cater to your enviroment?
Should i continue (y/n)?y
yes

You are authenticated and logged into AWS as "arn:aws:iam::693146231573:user/cdm-user". If this is not correct then exit this script and run "aws configure" to login into the correct account first.
Should i continue (y/n)?y
yes
=> Read the following env variables from config file
  Cluster Name = fr-eks-cluster
  Cluster Version = 1.12
  Role ARN = arn:aws:iam::693146231573:role/eksServiceRole
  VPC ID = vpc-02e4732fba42b3031
  Subnets = subnet-0da39cdaf0ce76a76,subnet-029ff8490b3fe25a9
  Security Group = sg-03f65e3ea65e9c9b9

=> Do you want to continue creating the cluster with these settings?
Continue (y/n)?y
yes

=> Creating cluster called "fr-eks-cluster"

EKS Cluster is being created.  Usually it takes 10 minutes...
Waiting for EKS cluster to be ready...
Waiting for EKS cluster to be ready...
Waiting for EKS cluster to be ready...
Waiting for EKS cluster to be ready...
Waiting for EKS cluster to be ready...
Waiting for EKS cluster to be ready...
Waiting for EKS cluster to be ready...
Waiting for EKS cluster to be ready...
Waiting for EKS cluster to be ready...
Waiting for EKS cluster to be ready...
EKS cluster is ready
Updated context arn:aws:eks:eu-west-1:693146231573:cluster/fr-eks-cluster in /home/martyn/.kube/config-eks
Context "arn:aws:eks:eu-west-1:693146231573:cluster/fr-eks-cluster" modified.

Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - fr-clust-nodes
Worker nodes provisioned. Sleeping for 15 seconds...
configmap/aws-auth created
Waiting for worker nodes to be ready...

added sg-048f833363ee45a34 security group to fsmt-7a3c92b2 mount target
added sg-048f833363ee45a34 security group to fsmt-7c3c92b4 mount target
Warning: Permanently added '52.215.54.118' (ECDSA) to the list of known hosts.
EFS activate on on worker node 52.215.54.118

namespace/monitoring created
namespace/prod created
Context "arn:aws:eks:eu-west-1:693146231573:cluster/fr-eks-cluster" modified.
Error from server (NotFound): deployments.extensions "tiller-deploy" not found
serviceaccount/tiller created
clusterrolebinding.rbac.authorization.k8s.io/tiller created
$HELM_HOME has been configured at /home/martyn/.helm.

Tiller (the Helm server-side component) has been installed into your Kubernetes Cluster.

Please note: by default, Tiller is deployed with an insecure 'allow unauthenticated users' policy.
To prevent this, run `helm init` with the --tiller-tls-verify flag.
For more information on securing your installation see: https://docs.helm.sh/using_helm/#securing-your-helm-installation
NAME:   nginx
LAST DEPLOYED: Tue Jan 14 13:16:18 2020
NAMESPACE: nginx
STATUS: DEPLOYED

RESOURCES:
==> v1/Deployment
NAME                                 AGE
nginx-nginx-ingress-controller       0s
nginx-nginx-ingress-default-backend  0s

==> v1/Pod(related)
NAME                                                  AGE
nginx-nginx-ingress-controller-9f7998f6b-qwhss        0s
nginx-nginx-ingress-default-backend-5dd86bd697-bp9c2  0s

==> v1/Service
NAME                                 AGE
nginx-nginx-ingress-controller       1s
nginx-nginx-ingress-default-backend  1s

==> v1/ServiceAccount
NAME                         AGE
nginx-nginx-ingress          1s
nginx-nginx-ingress-backend  1s

==> v1beta1/ClusterRole
NAME                 AGE
nginx-nginx-ingress  1s

==> v1beta1/ClusterRoleBinding
NAME                 AGE
nginx-nginx-ingress  1s

==> v1beta1/Role
NAME                 AGE
nginx-nginx-ingress  1s

==> v1beta1/RoleBinding
NAME                 AGE
nginx-nginx-ingress  1s


NOTES:
The nginx-ingress controller has been installed.
It may take a few minutes for the LoadBalancer IP to be available.
You can watch the status by running 'kubectl --namespace nginx get services -o wide -w nginx-nginx-ingress-controller'

An example Ingress that makes use of the controller:

  apiVersion: extensions/v1beta1
  kind: Ingress
  metadata:
    annotations:
      kubernetes.io/ingress.class: nginx
    name: example
    namespace: foo
  spec:
    rules:
      - host: www.example.com
        http:
          paths:
            - backend:
                serviceName: exampleService
                servicePort: 80
              path: /
    # This section is only required if TLS is to be enabled for the Ingress
    tls:
        - hosts:
            - www.example.com
          secretName: example-tls

If TLS is enabled for the Ingress, a Secret containing the certificate and key must also be provided:

  apiVersion: v1
  kind: Secret
  metadata:
    name: example-tls
    namespace: foo
  data:
    tls.crt: <base64 encoded cert>
    tls.key: <base64 encoded key>
  type: kubernetes.io/tls

Waiting for NLB to initialize DNS
...
NLB DNS is ready
=> Creating route53 records
{
    "ChangeInfo": {
        "Status": "PENDING",
        "Comment": "UPSERT a record ",
        "SubmittedAt": "2020-01-14T15:59:50.490Z",
        "Id": "/change/COVL2V41KW8HR"
    }
}
{
    "ChangeInfo": {
        "Status": "PENDING",
        "Comment": "UPSERT a record ",
        "SubmittedAt": "2020-01-14T15:59:52.097Z",
        "Id": "/change/C2EQRA7JY5BKM2"
    }
}
{
    "ChangeInfo": {
        "Status": "PENDING",
        "Comment": "UPSERT a record ",
        "SubmittedAt": "2020-01-14T15:59:53.560Z",
        "Id": "/change/C3L52JR6DGIKX9"
    }
}
{
    "ChangeInfo": {
        "Status": "PENDING",
        "Comment": "UPSERT a record ",
        "SubmittedAt": "2020-01-14T15:59:54.834Z",
        "Id": "/change/C163DXEPD76CEI"
    }
}
storageclass.storage.k8s.io/fast created
storageclass.storage.k8s.io/standard created
storageclass.storage.k8s.io/fast10 created
storageclass.storage.k8s.io/nfs created
storageclass.storage.k8s.io/standard patched
storageclass.storage.k8s.io "gp2" deleted
error: error reading ../etc/cert-manager/cert-manager.json: no such file or directory
The tiller pod is available...
Release "cert-manager" does not exist. Installing it now.
NAME:   cert-manager
LAST DEPLOYED: Tue Jan 14 16:01:50 2020
NAMESPACE: kube-system
STATUS: DEPLOYED

RESOURCES:
==> v1/Pod(related)
NAME                           AGE
cert-manager-8545fbf86c-qqqb5  1s

==> v1/ServiceAccount
NAME          AGE
cert-manager  1s

==> v1beta1/ClusterRole
NAME          AGE
cert-manager  1s

==> v1beta1/ClusterRoleBinding
NAME          AGE
cert-manager  1s

==> v1beta1/Deployment
NAME          AGE
cert-manager  1s


NOTES:
cert-manager has been deployed successfully!

In order to begin issuing certificates, you will need to set up a ClusterIssuer
or Issuer resource (for example, by creating a 'letsencrypt-staging' issuer).

More information on the different types of issuers and how to configure them
can be found in our documentation:

https://cert-manager.readthedocs.io/en/latest/reference/issuers.html

For information on how to configure cert-manager to automatically provision
Certificates for Ingress resources, take a look at the `ingress-shim`
documentation:

https://cert-manager.readthedocs.io/en/latest/reference/ingress-shim.html

The cert-manager pod is not available...
The cert-manager pod is available...
clusterissuer.certmanager.k8s.io/letsencrypt-prod created
Installing Prometheus Operator and Grafana to 'monitoring' namespace in 10 seconds or when enter is pressed...

"stable" has been added to your repositories
Release "monitoring-prometheus-operator" does not exist. Installing it now.
NAME:   monitoring-prometheus-operator
LAST DEPLOYED: Tue Jan 14 16:03:13 2020
NAMESPACE: monitoring
STATUS: DEPLOYED

RESOURCES:
==> v1/Alertmanager
NAME                                     AGE
monitoring-prometheus-oper-alertmanager  36s

==> v1/ClusterRole
NAME                                                         AGE
monitoring-prometheus-oper-alertmanager                      36s
monitoring-prometheus-oper-operator                          36s
monitoring-prometheus-oper-operator-psp                      36s
monitoring-prometheus-oper-prometheus                        36s
monitoring-prometheus-oper-prometheus-psp                    36s
monitoring-prometheus-operator-grafana-clusterrole           36s
psp-monitoring-prometheus-operator-kube-state-metrics        36s
psp-monitoring-prometheus-operator-prometheus-node-exporter  36s

==> v1/ClusterRoleBinding
NAME                                                         AGE
monitoring-prometheus-oper-alertmanager                      36s
monitoring-prometheus-oper-operator                          36s
monitoring-prometheus-oper-operator-psp                      36s
monitoring-prometheus-oper-prometheus                        36s
monitoring-prometheus-oper-prometheus-psp                    36s
monitoring-prometheus-operator-grafana-clusterrolebinding    36s
psp-monitoring-prometheus-operator-kube-state-metrics        36s
psp-monitoring-prometheus-operator-prometheus-node-exporter  36s

==> v1/ConfigMap
NAME                                                          AGE
monitoring-prometheus-oper-apiserver                          36s
monitoring-prometheus-oper-cluster-total                      36s
monitoring-prometheus-oper-controller-manager                 36s
monitoring-prometheus-oper-etcd                               36s
monitoring-prometheus-oper-grafana-datasource                 36s
monitoring-prometheus-oper-k8s-resources-cluster              36s
monitoring-prometheus-oper-k8s-resources-namespace            36s
monitoring-prometheus-oper-k8s-resources-node                 36s
monitoring-prometheus-oper-k8s-resources-pod                  36s
monitoring-prometheus-oper-k8s-resources-workload             36s
monitoring-prometheus-oper-k8s-resources-workloads-namespace  36s
monitoring-prometheus-oper-kubelet                            36s
monitoring-prometheus-oper-namespace-by-pod                   36s
monitoring-prometheus-oper-namespace-by-workload              36s
monitoring-prometheus-oper-node-cluster-rsrc-use              36s
monitoring-prometheus-oper-node-rsrc-use                      36s
monitoring-prometheus-oper-nodes                              36s
monitoring-prometheus-oper-persistentvolumesusage             36s
monitoring-prometheus-oper-pod-total                          36s
monitoring-prometheus-oper-pods                               36s
monitoring-prometheus-oper-prometheus                         36s
monitoring-prometheus-oper-proxy                              36s
monitoring-prometheus-oper-scheduler                          36s
monitoring-prometheus-oper-statefulset                        36s
monitoring-prometheus-oper-workload-total                     36s
monitoring-prometheus-operator-grafana                        36s
monitoring-prometheus-operator-grafana-config-dashboards      36s
monitoring-prometheus-operator-grafana-test                   36s

==> v1/DaemonSet
NAME                                                     AGE
monitoring-prometheus-operator-prometheus-node-exporter  36s

==> v1/Deployment
NAME                                               AGE
monitoring-prometheus-oper-operator                36s
monitoring-prometheus-operator-grafana             36s
monitoring-prometheus-operator-kube-state-metrics  36s

==> v1/Pod(related)
NAME                                                             AGE
monitoring-prometheus-oper-operator-5f55c97495-6n2rz             36s
monitoring-prometheus-operator-grafana-69bb5c9fd5-9xrfg          36s
monitoring-prometheus-operator-kube-state-metrics-9f454965b7jp7  36s
monitoring-prometheus-operator-prometheus-node-exporter-22vwg    36s
monitoring-prometheus-operator-prometheus-node-exporter-5fkk6    36s
monitoring-prometheus-operator-prometheus-node-exporter-sgd4t    36s
monitoring-prometheus-operator-prometheus-node-exporter-vjkrg    36s

==> v1/Prometheus
NAME                                   AGE
monitoring-prometheus-oper-prometheus  36s

==> v1/PrometheusRule
NAME                                                             AGE
monitoring-prometheus-oper-alertmanager.rules                    36s
monitoring-prometheus-oper-etcd                                  36s
monitoring-prometheus-oper-general.rules                         36s
monitoring-prometheus-oper-k8s.rules                             36s
monitoring-prometheus-oper-kube-apiserver-error                  36s
monitoring-prometheus-oper-kube-apiserver.rules                  36s
monitoring-prometheus-oper-kube-prometheus-node-recording.rules  36s
monitoring-prometheus-oper-kube-scheduler.rules                  36s
monitoring-prometheus-oper-kubernetes-absent                     36s
monitoring-prometheus-oper-kubernetes-apps                       36s
monitoring-prometheus-oper-kubernetes-resources                  36s
monitoring-prometheus-oper-kubernetes-storage                    36s
monitoring-prometheus-oper-kubernetes-system                     36s
monitoring-prometheus-oper-kubernetes-system-apiserver           36s
monitoring-prometheus-oper-kubernetes-system-controller-manager  36s
monitoring-prometheus-oper-kubernetes-system-kubelet             36s
monitoring-prometheus-oper-kubernetes-system-scheduler           36s
monitoring-prometheus-oper-node-exporter                         36s
monitoring-prometheus-oper-node-exporter.rules                   36s
monitoring-prometheus-oper-node-network                          36s
monitoring-prometheus-oper-node-time                             36s
monitoring-prometheus-oper-node.rules                            36s
monitoring-prometheus-oper-prometheus                            36s
monitoring-prometheus-oper-prometheus-operator                   36s

==> v1/Role
NAME                                         AGE
monitoring-prometheus-operator-grafana-test  36s

==> v1/RoleBinding
NAME                                         AGE
monitoring-prometheus-operator-grafana-test  36s

==> v1/Secret
NAME                                                  AGE
alertmanager-monitoring-prometheus-oper-alertmanager  36s
monitoring-prometheus-operator-grafana                36s

==> v1/Service
NAME                                                     AGE
monitoring-prometheus-oper-alertmanager                  36s
monitoring-prometheus-oper-coredns                       36s
monitoring-prometheus-oper-kube-controller-manager       36s
monitoring-prometheus-oper-kube-etcd                     36s
monitoring-prometheus-oper-kube-proxy                    36s
monitoring-prometheus-oper-kube-scheduler                36s
monitoring-prometheus-oper-operator                      36s
monitoring-prometheus-oper-prometheus                    36s
monitoring-prometheus-operator-grafana                   36s
monitoring-prometheus-operator-kube-state-metrics        36s
monitoring-prometheus-operator-prometheus-node-exporter  36s

==> v1/ServiceAccount
NAME                                                     AGE
monitoring-prometheus-oper-alertmanager                  36s
monitoring-prometheus-oper-operator                      36s
monitoring-prometheus-oper-prometheus                    36s
monitoring-prometheus-operator-grafana                   36s
monitoring-prometheus-operator-grafana-test              36s
monitoring-prometheus-operator-kube-state-metrics        36s
monitoring-prometheus-operator-prometheus-node-exporter  36s

==> v1/ServiceMonitor
NAME                                                AGE
monitoring-prometheus-oper-alertmanager             35s
monitoring-prometheus-oper-apiserver                35s
monitoring-prometheus-oper-coredns                  35s
monitoring-prometheus-oper-grafana                  35s
monitoring-prometheus-oper-kube-controller-manager  35s
monitoring-prometheus-oper-kube-etcd                35s
monitoring-prometheus-oper-kube-proxy               35s
monitoring-prometheus-oper-kube-scheduler           35s
monitoring-prometheus-oper-kube-state-metrics       35s
monitoring-prometheus-oper-kubelet                  35s
monitoring-prometheus-oper-node-exporter            35s
monitoring-prometheus-oper-operator                 35s
monitoring-prometheus-oper-prometheus               35s

==> v1beta1/ClusterRole
NAME                                               AGE
monitoring-prometheus-operator-kube-state-metrics  36s

==> v1beta1/ClusterRoleBinding
NAME                                               AGE
monitoring-prometheus-operator-kube-state-metrics  36s

==> v1beta1/MutatingWebhookConfiguration
NAME                                  AGE
monitoring-prometheus-oper-admission  36s

==> v1beta1/PodSecurityPolicy
NAME                                                     AGE
monitoring-prometheus-oper-alertmanager                  36s
monitoring-prometheus-oper-operator                      36s
monitoring-prometheus-oper-prometheus                    36s
monitoring-prometheus-operator-grafana                   36s
monitoring-prometheus-operator-grafana-test              36s
monitoring-prometheus-operator-kube-state-metrics        36s
monitoring-prometheus-operator-prometheus-node-exporter  36s

==> v1beta1/Role
NAME                                    AGE
monitoring-prometheus-operator-grafana  36s

==> v1beta1/RoleBinding
NAME                                    AGE
monitoring-prometheus-operator-grafana  36s

==> v1beta1/ValidatingWebhookConfiguration
NAME                                  AGE
monitoring-prometheus-oper-admission  35s


NOTES:
The Prometheus Operator has been installed. Check its status by running:
  kubectl --namespace monitoring get pods -l "release=monitoring-prometheus-operator"

Visit https://github.com/coreos/prometheus-operator for instructions on how
to create & configure Alertmanager and Prometheus instances using the Operator.
Release "monitoring-forgerock-metrics" does not exist. Installing it now.
NAME:   monitoring-forgerock-metrics
LAST DEPLOYED: Tue Jan 14 16:04:32 2020
NAMESPACE: monitoring
STATUS: DEPLOYED

RESOURCES:
==> v1/ConfigMap
NAME                  AGE
forgerock-dashboards  1s

==> v1/PrometheusRule
NAME                                   AGE
monitoring-forgerock-metrics-fr.rules  1s

==> v1/Secret
NAME            AGE
prometheus-am   1s
prometheus-ds   1s
prometheus-idm  1s
prometheus-ig   1s

==> v1/ServiceMonitor
NAME  AGE
am    1s
ds    1s
idm   1s
ig    1s


Please add 'export KUBECONFIG=$KUBECONFIG:~/.kube/config-eks' to your bash_profile
```

## Deploying the CDM

This part is documented in section 3.x titled **SECTION 3 - Deploying the CDM**.

For the below actions, let's assume a small cluster (`s-cluster`) is being used. This is important because later its directory (`samples/config/prod/s-cluster`) is used for deployment:

1. Ensure the `nfs:` -> `server:` is correct in `samples/config/prod/s-cluster/dsadmin.yaml`. This should be the EFS URN, e.g. `fs-8c760d47.efs.eu-west-1.amazonaws.com`.
2. Ensure the `domain:` is correct in `samples/config/prod/s-cluster/common.yaml`.
3. Ensure the `fqdn:` is correct in `samples/config/prod/s-cluster/common.yaml`.
4. Run the `deploy.sh` script:

    **NOTE:** To remove a deployment first, use `-R` with the line below

    ```
    $ ./deploy.sh /home/martyn/Source/forgeops/samples/config/prod/s-cluster/
    => k8s Context is: "arn:aws:eks:eu-west-1:693146231573:cluster/fr-eks-cluster"
    => Using "/home/martyn/Source/forgeops/samples/config/prod/s-cluster/" as the root of your configuration
    => Reading env.sh
    => Reading /home/martyn/Source/forgeops/samples/config/prod/s-cluster//env.sh
    =>  Namespace: "prod"
    =>  Domain: "eg.fr.kcom.com"
    =>  Components: "frconfig dsadmin configstore userstore ctsstore openam amster postgres-openidm openidm openig web"
    => Namespace prod already exists.  Skipping creation...
    => Deploying charts into namespace "prod" with URL "login.prod.eg.fr.kcom.com" on provider "aws"
    ...
    ```

## Using the CDM

This part is documented in section 4.x titled **SECTION 4 - Using the CDM**.

- Q: How do I test CTS is up and running?
- A: Using the following:

    ```
    $ kubectl exec -it ctsstore-0 -- /bin/bash

    forgerock@ctsstore-0:~$ ldapsearch --port 1389 --baseDN "" --searchScope base "(&)" alive healthy
    dn:
    alive: true
    healthy: true
    ```

- Q: How do I test OpenIDM REST API works?
- A: Using the following:

    ```
    [ec2-user@ip-192-168-179-156 bin]$ curl \
       --request POST \
       --insecure \
       --header "Content-Type: application/json" \
       --header "X-OpenAM-Username: amadmin" \
       --header "X-OpenAM-Password: password" \
       --header "Accept-API-Version: resource=2.0" \
       --data "{}" \
       'https://login.prod.eg.fr.kcom.com/json/realms/root/authenticate?service=ldapService&authIndexType=service&authIndexValue=ldapService'

    {"tokenId":"0X09Ez1i8M29_Mq4ZqTFsXquv1A.*AAJTSQACMDIAAlNLABxYOVYydk9EUXBtVythYjRDOE14VVNpeFdxOHc9AAR0eXBlAANDVFMAAlMxAAIwMQ..*","successUrl":"/console","realm":"/"}
    ```

- Q: How do I test OpenIDM REST API works?
- A: Using the following:

    ```
    [ec2-user@ip-192-168-179-156 bin]$ curl \
       --request GET \
       --insecure \
       --header "X-OpenIDM-Username: openidm-admin" \
       --header "X-OpenIDM-Password: openidm-admin" \
       --data "{}" \
       https://openidm.prod.eg.fr.kcom.com/openidm/info/ping

    {"_id":"","_rev":"","shortDesc":"OpenIDM ready","state":"ACTIVE_READY"}
    ```

- Q: How do I get a browser open to access the admin console web interfaces?
- A: First, create a port forward to the Bastion:

    ```
    $ ssh -L 5901:localhost:5901 -i ~/.ssh/fr-eks-clust-key.pem ec2-user@52.213.235.183
    ```

    Second, install `tigervnc`.

    Third, start `tigervnc` and connect to `localhost:1`.

## Benchmarking the CDM Performance

This part is documented in section 5.x titled **SECTION 5 - Benchmarking the CDM Performance**.

In preparation for these tests, 1 millon users were generated, imported and then backed up on CTS 0. Following this, the backup was restored onto CTS-1. This all took less than 10 minutes to do.

The documentation officially released by ForgeRock gives an ***expected*** performance that their engineers have seen which we are comparing to below:

### Searchrate

```
--------------------------------------------------------------------------------------------
|     Throughput    |                 Response Time                |       Additional      | 
|    (ops/second)   |                (milliseconds)                |       Statistics      | 
|   recent  average |   recent  average    99.9%   99.99%  99.999% |  err/sec Entries/Srch | 
|------------------------------------------------------------------------------------------|
| ForgeRock engineers                                                                      |
|------------------------------------------------------------------------------------------|
|           17000.0 |            31.000                            |                       | 
|------------------------------------------------------------------------------------------|
| Our results                                                                              |
|------------------------------------------------------------------------------------------|
|  28753.2  28753.2 |   17.967   17.967   320.86   400.56   402.65 |      0.0          1.0 | 
|  30718.0  29735.6 |   16.662   17.293   312.48   398.46   402.65 |      0.0          1.0 | 
|  32398.4  30623.2 |   15.828   16.776   301.99   398.46   402.65 |      0.0          1.0 | 
|  33100.2  31242.5 |   15.418   16.416   295.70   394.26   402.65 |      0.0          1.0 | 
|  33064.8  31606.9 |   15.526   16.230   287.31   385.88   402.65 |      0.0          1.0 | 
|  30128.4  31360.5 |   16.980   16.350   278.92   381.68   402.65 |      0.0          1.0 | 
|  33133.8  31613.8 |   15.472   16.219   260.05   375.39   402.65 |      0.0          1.0 | 
|  32380.6  31709.7 |   15.792   16.164   243.27   373.29   402.65 |      0.0          1.0 | 
|  32242.8  31768.9 |   15.865   16.131   229.64   369.10   402.65 |      0.0          1.0 | 
|  28264.6  31418.5 |   17.969   16.296   222.30   369.10   400.56 |      0.0          1.0 | 
--------------------------------------------------------------------------------------------
```

Implementation is already pushing more throughput and with faster response times than expected.

### Modrate

```
-------------------------------------------------------------------------------
|     Throughput    |                 Response Time                |          | 
|    (ops/second)   |                (milliseconds)                |          | 
|   recent  average |   recent  average    99.9%   99.99%  99.999% |  err/sec | 
|-----------------------------------------------------------------------------|
| ForgeRock engineers                                                         |
|-----------------------------------------------------------------------------|
|            2400.0 |             5.000 (mean)                     |          | 
|-----------------------------------------------------------------------------|
| Our results                                                                 |
|-----------------------------------------------------------------------------|
|   3265.3   3265.3 |    2.374    2.374    69.73    74.97    75.50 |      0.0 | 
|   4058.1   3658.0 |    1.985    2.160    69.73   110.62   110.62 |      0.0 | 
|   4455.0   3923.7 |    1.787    2.019    69.73   110.62   110.62 |      0.0 | 
|   4261.0   4008.0 |    1.866    1.978    69.21    85.46   110.62 |      0.0 | 
|   4272.6   4061.3 |    1.852    1.951    69.21    85.46   110.62 |      0.0 | 
|   3697.4   4000.8 |    2.148    1.982    69.21   109.58   110.62 |      0.0 | 
|   4050.6   4007.9 |    1.964    1.979    69.21   136.31   147.85 |      0.0 | 
|   4655.2   4088.0 |    1.728    1.944    69.21   124.26   147.85 |      0.0 | 
|   4448.2   4128.4 |    1.774    1.923    69.21   124.26   147.85 |      0.0 | 
|   4709.0   4186.4 |    1.691    1.897    69.21   124.26   147.85 |      0.0 | 
-------------------------------------------------------------------------------
```


Implementation is already pushing more throughput and with faster response times than expected.

### Addrate

```
--------------------------------------------------------------------------------------
|     Throughput    |                 Response Time                |    Additional   | 
|    (ops/second)   |                (milliseconds)                |    Statistics   | 
|   recent  average |   recent  average    99.9%   99.99%  99.999% |  err/sec   Add% | 
|------------------------------------------------------------------------------------|
| ForgeRock engineers                                                                |
|------------------------------------------------------------------------------------|
|             300.0 |            12.000 (mean)                     |                 | 
|------------------------------------------------------------------------------------|
| Our results                                                                        |
|------------------------------------------------------------------------------------|
|     37.4     37.4 |  208.830  208.830   442.50   442.50   442.50 |      0.0 100.00 | 
|     54.4     45.9 |  148.203  172.903   442.50   442.50   442.50 |      0.0 100.00 | 
|     84.8     58.9 |   94.461  135.237   425.72   442.50   442.50 |      0.0 100.00 | 
|    165.6     85.6 |   48.446   93.236   421.53   442.50   442.50 |      0.0 100.00 | 
|    320.0    132.4 |   25.007   60.266   417.33   442.50   442.50 |      0.0 100.00 | 
|    580.6    207.1 |   13.716   38.519   373.29   425.72   442.50 |      0.0 100.00 | 
|    995.0    319.7 |    7.987   24.943   356.52   425.72   442.50 |      0.0 100.00 | 
|    699.0    367.1 |   11.437   21.729   369.10   696.25   696.25 |      0.0 100.00 | 
|   1178.4    457.2 |    6.708   17.428   343.93   696.25   696.25 |      0.0 100.00 | 
|    973.4    508.9 |    8.190   15.661   367.00   696.25   696.25 |      0.0 100.00 | 
--------------------------------------------------------------------------------------
```

Implementation is faster at throughput but slightly slower at response time. This improves over time it seems.

## Q & A

- Q: Why do I get errors like this: `Unable to connect to the server: dial tcp: lookup C55C043F30FBFC78F70813F5996518CF.sk1.eu-west-1.eks.amazonaws.com on 192.168.1.1:53: no such host`?
- A: Ensure the `export KUBECONFIG=...` step is done first!

***

- Q: Why do I get errors like this: `An error occurred (BadRequest) when calling the DescribeMountTargets operation: Invalid resource ID: sg-03817028e406ee84b`?
- A: The File System ID is wrong in the `eks-env.cfg` config file. Make sure `EFS_ID` is set correctly.

***

- Q: Why do I get errors like this: `Error: unknown flag: --upgrade`?
- A: The version of `helm` in use is too modern. Use helm 2.16.1 for EKS, helm 3.x for ForgeRock deployments:

***

- Q: Why do I get errors like this `error: SchemaError(io.k8s.api.authorization.v1beta1.NonResourceRule): invalid object doesn't have additional properties`?
- A: There is a version mismatch for `kubectl` between client/server. The script `eks-up.sh` must be run again and the cluster created from scratch. When this issue is fixed, the config file `~/.kube/config-eks` is generated again with the correct details. The versions in use can be seen with:

    ```
    $ kubectl version
    Client Version: version.Info{Major:"1", Minor:"17", GitVersion:"v1.17.2", GitCommit:"59603c6e503c87169aea6106f57b9f242f64df89", GitTreeState:"clean", BuildDate:"2020-01-18T23:30:10Z", GoVersion:"go1.13.5", Compiler:"gc", Platform:"linux/amd64"}
    Server Version: version.Info{Major:"1", Minor:"14+", GitVersion:"v1.14.9-eks-c0eccc", GitCommit:"c0eccca51d7500bb03b2f163dd8d534ffeb2f7a2", GitTreeState:"clean", BuildDate:"2019-12-22T23:14:11Z", GoVersion:"go1.12.12", Compiler:"gc", Platform:"linux/amd64"}
    ```

***

- Q: Why do I repeatedly see this: `Waiting for NLB to initialize DNS`?
- A: This is due to a missing role.

    The quick answer is, a call like this is required:

    ```
    $ aws iam create-service-linked-role --aws-service-name "elasticloadbalancing.amazonaws.com"
    ```

    This is because the load balancer permissions for the `eksServiceRole` are insufficient. Usually the nginx ingress controller (which is the part that's failing) has `EXTERNAL-IP` as still in a `<pending>` state which it should not be in. To see what the state is, use the following (below is what **should** be seen):

    ```
    $ kubectl --namespace nginx get services -o wide -w nginx-nginx-ingress-controller
    NAME                             TYPE           CLUSTER-IP       EXTERNAL-IP                                                                     PORT(S)                      AGE     SELECTOR
    nginx-nginx-ingress-controller   LoadBalancer   10.100.194.242   af9800a80435111eab97c02bf9b40f64-ed99c9ff5adc2131.elb.eu-west-1.amazonaws.com   80:31592/TCP,443:32696/TCP   3h22m   app=nginx-ingress,component=controller,release=nginx
    ```

    To diagnosing the problem further:

    ```
    $ kubectl --namespace nginx describe services nginx-nginx-ingress-controller
    ```

    Under the ***events*** section, this is what is seen:

    ```
    Error creating load balancer (will retry): failed to ensure load balancer for service nginx/nginx-nginx-ingress-controller: Error creating load balancer: "AccessDenied: User: arn:aws:sts::693146231573:assumed-role/eksServiceRole/1579007396872765461 is not authorized to perform: ec2:DescribeAccountAttributes\n\tstatus code: 403, request id: 8ce1c316-a129-4e89-a082-7e001cb54182"
    ```

    The AWS issue is reported here <https://forums.aws.amazon.com/thread.jspa?threadID=286810>.
    The solution is detailed here <https://stackoverflow.com/questions/51597410/aws-eks-is-not-authorized-to-perform-iamcreateservicelinkedrole>.

    **NOTE:** This has been fixed in `eks-create-service-role.sh` script.

***

- Q: Why do I get errors like this: `An error occurred (NoSuchHostedZone) when calling the ChangeResourceRecordSets operation: No hosted zone found with ID: null`?
- A: Under Route53 in AWS, a private hosted zone MUST be created and linked to the VPC in use here. Currently none of the scripts in this repository do this right now. This is a manual step.

***

- Q: When replacing a deployment with `deploy.sh -R ...`, why do I get `Error: rendered manifests contain a resource that already exists. Unable to continue with install: existing resource conflict: kind: PersistentVolume, namespace: , name: ds-backup-prod`?
- A: The persistent volume isn't cleaned up properly. This can be fixed using:

    ```
    $ kubectl delete pv ds-backup-prod
    ```

    **NOTE:** This has been fixed in `remove-all.sh` script.

***

- Q: Why won't OpenIG start up? The WAR file constantly fails to start up?
- A: There are not enough CPU/memory resources. Usually this is obvious when looking at the events using:

    ```
    $ kubectl get events --all-namespaces
    ```

***

- Q: Why is the nginx controller in a `CrashLoopBackOff` state?
- A: This is due to a bug in Kubernetes / Alpine Linux / Nginx controller and user permissions. The fix is to use `--set controller.image.tag="0.28.0"` in `eks-create-ingress-cntlr.sh`.

    To probe the nginx controller use:

    ```
    $ kubectl -n nginx get pods
    NAME                                                   READY   STATUS             RESTARTS   AGE
    nginx-nginx-ingress-controller-7ff86667cb-clnnr        0/1     CrashLoopBackOff   7          14m
    nginx-nginx-ingress-default-backend-5dd86bd697-7vxst   1/1     Running            0          14m
    ```

    Notice the **CrashLoopBackOff** state. The further find out what is going on use:

    ```
    $ kubectl -n nginx logs nginx-nginx-ingress-controller-7ff86667cb-clnnr
    -------------------------------------------------------------------------------
    NGINX Ingress controller
      Release:    0.21.0
      Build:      git-b65b85cd9
      Repository: https://github.com/aledbf/ingress-nginx
    -------------------------------------------------------------------------------

    I0130 10:59:19.037531       8 flags.go:176] Watching for Ingress class: nginx
    nginx version: nginx/1.15.6
    W0130 10:59:19.040927       8 client_config.go:548] Neither --kubeconfig nor --master was specified.  Using the inClusterConfig.  This might not work.
    I0130 10:59:19.041146       8 main.go:196] Creating API client for https://10.100.0.1:443
    I0130 10:59:19.049909       8 main.go:240] Running in Kubernetes cluster version v1.14+ (v1.14.9-eks-c0eccc) - git (clean) commit c0eccca51d7500bb03b2f163dd8d534ffeb2f7a2 - platform linux/amd64
    I0130 10:59:19.054206       8 main.go:101] Validated nginx/nginx-nginx-ingress-default-backend as the default backend.
    F0130 10:59:19.213212       8 main.go:115] Error generating self-signed certificate: could not create temp pem file /etc/ingress-controller/ssl/default-fake-certificate.pem: open /etc/ingress-controller/ssl/default-fake-certificate.pem970979531: permission denied
    ```

    It's clear looking at the logs that there are issues with the certificate generation.
    This particular problem is quite common, see <https://github.com/kubernetes/ingress-nginx/issues/3589>

    If the Nginx controller has already been installed, purge it first and manually create it using:

    ```
    $ helm delete --purge nginx
    release "nginx" deleted
    $ helm install --namespace nginx --name nginx   --set rbac.create=true   --set controller.publishService.enabled=true   --set controller.stats.enabled=true   --set controller.service.externalTrafficPolicy=Local   --set controller.service.type=LoadBalancer   --set controller.image.tag="0.28.0"   --set controller.service.annotations."service\.beta\.kubernetes\.io/aws-load-balancer-type"="nlb"   stable/nginx-ingress
    ...
    ```

    If the previous nginx instance was purged, the DNS records will not be correct any longer. To fix this, run:

    ```
    ./eks-create-ingress-cntlr.sh
    Error: unknown flag: --name
    NLB DNS is ready
    => Creating route53 records
    {
        "ChangeInfo": {
            "Status": "PENDING",
            "Comment": "UPSERT a record ",
            "SubmittedAt": "2020-01-30T15:13:43.614Z",
            "Id": "/change/C1Q1X5VYFHT2ZB"
        }
    }
    {
        "ChangeInfo": {
            "Status": "PENDING",
            "Comment": "UPSERT a record ",
            "SubmittedAt": "2020-01-30T15:13:44.903Z",
            "Id": "/change/C2M0DIHSTKPY6V"
        }
    }
    {
        "ChangeInfo": {
            "Status": "PENDING",
            "Comment": "UPSERT a record ",
            "SubmittedAt": "2020-01-30T15:13:46.237Z",
            "Id": "/change/C3QCH1T0QVAB3L"
        }
    }
    {
        "ChangeInfo": {
            "Status": "PENDING",
            "Comment": "UPSERT a record ",
            "SubmittedAt": "2020-01-30T15:13:47.519Z",
            "Id": "/change/C1DHTGAKDGJLWC"
        }
    }

    ```

    **NOTE:** This has been fixed in `eks-create-ingress-cntlr.sh` script.

## Saving costs

### Scale down EC2 instances

The least destructive way to save money seems to be by setting the EC2 instances to be `t2.small` or any instance which is cheap to run. Kubernetes spins up (or tries to) on the new EC2 instances automatically. This is certain to fail to work due to lack of resources, but the next time you want to use the deployment, just change the instance type back to `m5.4xlarge` which is recommended by ForgeRock.

### Delete deployments

Delete EKS deployments. This usually doesn't work very well and requires starting again with the entire stack because of the dependency chain involved.

You can attempt it with:

```
aws cloudformation delete-stack --stack-name fr-clust-nodes
```

### Delete clusters

This should hose the entire set up in AWS.

Use the `eks-delete-cluster.sh` script. Calling `eks-delete-cluster.sh` and deleting the cloud formation are often not enough and AWS leaves stuff behind:

1. The IAM role `eksServiceRole`. Go into IAM -> Roles and remove it.
2. The IAM role `AWSServiceRoleForElasticLoadBalancing`. Go into IAM -> Roles and remove it.
3. The IAM policy `fr-fops-01-Sync-Policy`. Go into IAM -> Policies and remove it.
4. The S3 bucket `fr-fops-01`. Go into S3 and remove it.
5. The EFS doesn't get cleaned up. Go into EFS and remove it.
6. The cloud formation can not remove security groups. To fix this, you need to remove EFS, this leads you to cleaning up everything above.
7. You may need to remove the Route53 hosted zone.

Finally, try to delete the cloud formation again after this.

**WARNING:** You must clean up ALL these areas to use the scripts to start from scratch setting up a FR environment!

## Issues Noticed

1. You can't easily disable EKS / control plane. It can be removed and re-added. The simplest thing that can be done which saves cost is to delete a deployment (EC2 instances). But there is still a charge incurred by the control plane. GKE doesn't charge for the control plane, AWS does. For more detail see <https://github.com/aws/containers-roadmap/issues/133>
2. There is nothing about AWS Fargate from the ForgeRock guys.
3. Should `helm` be set up securely? This can be done using `--tiller-tls-verify` but isn't the default. More info here <https://docs.helm.sh/using_helm/#securing-your-helm-installation>
4. Is this a problem: `Error from server (NotFound): deployments.extensions "tiller-deploy" not found`?
5. Training courses seem to focus on Google Cloud Platform Kubernetes deployments, not AWS.
6. Is this a problem: `error: error reading ../etc/cert-manager/cert-manager.json: no such file or directory`?
