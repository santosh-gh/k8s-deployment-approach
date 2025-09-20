# Architesture

![Store Architesture](aks-store-architecture.png)

    # Store front: Web application for customers to view products and place orders.
    # Product service: Shows product information.
    # Order service: Places orders.
    # RabbitMQ: Message queue for an order queue.

# Tetechnology Stack
   
    KinD
    docker desktop
    docker hub
    git hub
    kubectl
    Flux CD   

# Docker Build and Push to Docker Hub

    # Order Service
    docker build -t order ./app/order-service 
    docker tag order:latest e880613/order:1.0.0
    docker push e880613/order:1.0.0

    docker tag order:latest e880613/order:1.0.1
    docker push e880613/order:1.0.1


    # Product Service
    docker build -t product ./app/product-service 
    docker tag product:latest e880613/product:1.0.0
    docker push e880613/product:1.0.0

    # Store Front Service
    docker build -t store-front ./app/store-front 1
    docker tag store-front:latest e880613/store-front:1.0.0
    docker push e880613/store-front:1.0.0


# Prerequisites

  Install Docker

  GitHub CLI

  Install kubectl

# Install KinD 
  
  https://kind.sigs.k8s.io/docs/user/quick-start/

  kind --version 

# Install Flux CLI

    Windows:
    choco install flux

    Mac:
    brew install fluxcd/tap/flux

    Linux:
    curl -s https://fluxcd.io/install.sh | sudo bash

    flux --version

# Create a KinD cluster

- This creates a single-node Kubernetes cluster inside a Docker container.

  kind create cluster --name demo-cluster 

  kind create cluster --name demo-cluster  --config=./cluster-config/config

  docker ps

  kubectl get nodes

  kubectl cluster-info

  kubectl cluster-info --context kind-demo-cluster

# FluxCD Prerequisites Check
  flux check --pre

# Install Flux in Cluster

# GitHub
  gh auth login
  gh repo create <repo-name> --public 

# Bootstrap Flux in the Cluster

  Creating a GitHub Personal Access Token (PAT)

  export GITHUB_USER='santosh-gh'
  export GITHUB_REPO='k8s-22-deployment'
  export GITHUB_TOKEN=<pat-token>

  flux bootstrap github \
    --owner=$GITHUB_USER \
    --repository=$GITHUB_REPO \
    --branch=main \
    --path=clusters/demo-cluster \
    --personal=true \
    --private=false

    Create a Git repo 

    Install the Flux components in Kubernetes cluster.

    Configure Flux to reconcile manifests underclusters/demo-cluster/
    
    
  kubectl get pods -n flux-system
  k get all -n flux-system

# FluxCD Components

  Flux - the primary operator (control plane), continuously monitoring the Git repository 
          and applying changes to the Kubernetes cluster.

  Kustomize Controller - supports managing Kubernetes manifests using Kustomize,
                         also enabling customize the deployments.

  Source Controller - monitors the source of the Kubernetes manifests (Git, Helm repositories, etc.) 
                      and makes them available for the other controllers.

  Helm Controller - responsible for managing Helm artifacts.

  Notification Controller - handles notifications and alerts for deployments

 # Setting Up FluxCD to Deploy the Application
    
    # Microservice Manifests
    # Create a Kustomization File
    # Link the Application Directory to FluxCD

# Commit and Push to Repository

# Verify FluxCD Reconciliation
  Trigger Reconciliation:
  flux reconcile kustomization flux-system -n flux-system

  Check Logs:
  kubectl logs -n flux-system deploy/kustomize-controller

  Check Kustomization Status:
  flux get kustomizations -n flux-system

  flux get kustomizations --watch
  flux get kustomizations -w

  flux get sources git
  flux get kustomizations

  Check that the app was created:
  kubectl get all

  flux events

# Flux Sync

  kubectl get kustomizations -n flux-system
  flux get kustomizations

# Uninstall Flux

# Delete Cluster

  kind delete cluster --name demo-cluster

# Short command for kubectl

  alias k=kubectl

# Create Namespace

  k create ns dev

# Create or Deploy the Applications

  k apply -f ./manifests/config -n dev
  k apply -f ./manifests/rabbitmq -n dev
  k apply -f ./manifests/order -n dev
  k apply -f ./manifests/product -n dev
  k apply -f ./manifests/store-front -n dev

# Expose the Application (Networking)

  k get svc -n dev

  k port-forward svc/store-front-service 8080:80 -n dev
  curl http://localhost:8080

# Inspect or Debug the Application

    - Get detailed info about a resource

      k get deployment -n dev
      k describe deployment order-service -n dev

      k get po -n dev
      k describe po order-service-56cb476565-75nlh -n dev

    - View logs from a pod

      k logs order-service-56cb476565-75nlh -n dev

    - Access a running container interactively  

      k exec -it order-service-56cb476565-75nlh -n dev -- /bin/bash 
      k exec -it product-service-6f56b5745b-ntp56 -n dev -- /bin/bash 

# Update the Application

    - Scale replicas up/down

      k scale deployment order-service --replicas=3 -n dev

    - Rolling update (change image version)

      k set image deployment/order-service order-service=order:1.0.1 -n dev

# Rollback 

    - Rollback to the Previous Version

      k rollout undo deployment order-service -n dev

    - Rollback to a Specific Revision

      k rollout undo deployment order-service --to-revision=1 -n dev

    - Check Rollout Status  

      k rollout status deployment order-service -n dev

    - Verify Rollback

      Check pods

      k get pods -o wide

      Describe deployment:

      k describe deployment order-service -n dev

    - Show all revisions

      k rollout history deployment order-service -n dev

    - Show details of a specific revision
    
      k rollout history deployment order-service -n dev --revision=2

    - Watch rollout progress 

      k rollout status deployment order-service -n dev


# Delete / Clean Up

  - Delete deployment:

    kubectl delete deployment config -n dev
    kubectl delete deployment rabbitmq -n dev
    kubectl delete deployment order -n dev
    kubectl delete deployment product -n dev
    kubectl delete deployment store-front -n dev
  
  - Delete service:

    kubectl delete svc config -n dev
    kubectl delete svc rabbitmq -n dev
    kubectl delete svc order -n dev
    kubectl delete svc product -n dev
    kubectl delete svc store-front -n dev

  - Delete all using manifests

    k delete -f ./manifests/config -n dev
    k delete -f ./manifests/rabbitmq -n dev
    k delete -f ./manifests/order -n dev
    k delete -f ./manifests/product -n dev   
    k delete -f ./manifests/store-front -n dev

# Helm?

    Helm is a package manager for Kubernetes.

    A Helm chart is a collection of YAML templates that describe Kubernetes 
    resources (Deployments, Services, ConfigMaps, etc.).

    Helm charts make Kubernetes app deployment easier, repeatable, shareable, and safer 
    by providing packaging, templating, versioning, and lifecycle management.

# helmify (Convert the plain/raw manifests to Helm Charts)

    helmify -f ./manifests/config helmchart/config
    helmify -f ./manifests/rabbitmq helmchart/rabbitmq
    helmify -f ./manifests/order helmchart/order
    helmify -f ./manifests/product helmchart/product
    helmify -f ./manifests/store-front helmchart/store-front

# Helm Charts Structure

    helmcharts/order  
    templates/                # Kubernetes YAML templates
      _helpers.tpl            # define template definitions once and reuse across the chart..
      order-deployment.yaml   # Deployment definition
      order-service.yaml      # Service definition
    .helmignore               # Works like .gitignore, but for Helm packaging
    Chart.yaml                # Metadata about the chart (name, version, etc.)
    values.yaml               # Default configuration values

# Helm Install - Deploys microservice.

    helm install config ./helmcharts/config -n dev
    helm install rabbitmq ./helmcharts/rabbitmq -n dev
    helm install order ./helmcharts/order -n dev
    helm install product ./helmcharts/product -n dev
    helm install store-front ./helmcharts/store-front -n dev

# Helm Upgrade - Rolling updates to new versions.

    helm upgrade config ./helmcharts/config -n dev
    helm upgrade rabbitmq ./helmcharts/rabbitmq -n dev
    helm upgrade order ./helmcharts/order -n dev
    helm upgrade product ./helmcharts/product -n dev
    helm upgrade store-front ./helmcharts/store-front -n dev

# Check status

    helm status  config 1 -n dev
    helm status  rabbitmq 1 -n dev
    helm status  order 1 -n dev
    helm status  product 1 -n dev
    helm status  store-front 1 -n dev
    

# Deploy to Different Environments

    We can use the same Helm chart to deploy a microservice to multiple environments such as dev, test and
    prod simply by providing different values by creating different <env>-values.yaml files

    One chart → multiple environments

    No duplication of Kubernetes manifests

    Easy overrides per environment (-f <env>-values.yaml)

    Consistent deployments across dev/test/prod

    helm install config ./helmcharts/config -f dev-values.yaml -n dev
    helm install rabbitmq ./helmcharts/rabbitmq -f dev-values.yaml -n dev
    helm install order ./helmcharts/order -f dev-values.yaml -n dev
    helm install product ./helmcharts/product -f dev-values.yaml -n dev
    helm install store-front ./helmcharts/store-front -f dev-values.yaml -n dev

    helm install config ./helmcharts/config -f test-values.yaml -n dev
    helm install rabbitmq ./helmcharts/rabbitmq -f test-values.yaml -n dev
    helm install order ./helmcharts/order -f test-values.yaml -n dev
    helm install product ./helmcharts/product -f test-values.yaml -n dev
    helm install store-front ./helmcharts/store-front -f test-values.yaml -n dev

    helm install config ./helmcharts/config -f prod-values.yaml -n dev
    helm install rabbitmq ./helmcharts/rabbitmq -f prod-values.yaml -n dev
    helm install order ./helmcharts/order -f prod-values.yaml -n dev
    helm install product ./helmcharts/product -f prod-values.yaml -n dev
    helm install store-front ./helmcharts/store-front -f prod-values.yaml -n dev

    Same for helm upgrade ...



# Helm Package 

    helm package → creates .tgz Helm chart archive

    helm push → uploads to GHCR (as OCI registry)

    helm pull & helm install → consumers can download and install directly

    helm package ./helmcharts/config 
    helm package ./helmcharts/rabbitmq 
    helm package ./helmcharts/order 
    helm package ./helmcharts/product 
    helm package ./helmcharts/store-front

# Helm Push to OCI Registry (GHCR) - Option 1

    - Charts stored like Docker images (helm push/pull).

    - Create a GitHub token

      export GITHUB_USER='santosh-gh'
      export GITHUB_TOKEN='token'

    - Login to Git Hub

      echo $GITHUB_TOKEN | helm registry login ghcr.io -u $GITHUB_USER --password-stdin

      
    - helm push <helm package> oci://ghcr.io/<github-username>/<repo-name>/<chart-name (optional)>

      helm push config-0.1.0.tgz oci://ghcr.io/santosh-gh/online-store-charts 
      helm push order-0.1.0.tgz oci://ghcr.io/santosh-gh/online-store-charts 
      helm push product-0.1.0.tgz oci://ghcr.io/santosh-gh/online-store-charts 
      helm push rabbitmq-0.1.0.tgz oci://ghcr.io/santosh-gh/online-store-charts 
      helm push store-front-0.1.0.tgz oci://ghcr.io/santosh-gh/online-store-charts

# Pull & Install from GitHub Registry

    helm pull oci://ghcr.io/santosh-gh/online-store-charts/config --version 0.1.0
    helm pull oci://ghcr.io/santosh-gh/online-store-charts/rabbitmq --version 0.1.0
    helm pull oci://ghcr.io/santosh-gh/online-store-charts/order --version 0.1.0
    helm pull oci://ghcr.io/santosh-gh/online-store-charts/product --version 0.1.0
    helm pull oci://ghcr.io/santosh-gh/online-store-charts/store-front --version 0.1.0

    helm install config ./config-0.1.0.tgz
    helm install rabbitmq ./rabbitmq-0.1.0.tgz
    helm install order ./order-0.1.0.tgz
    helm install product ./product-0.1.0.tgz
    helm install store-front ./store-front-0.1.0.tgz


# Hosting Helm Charts on GitHub Pages - Option 2

    - Static Helm repo with index.yaml and .tgz files, browsable via HTTPS.

    - Create a repo on GitHub (say online-helm-chart).

      Clone it locally.

      Copy the packaged chart into the repo.

    - Generate the Helm index

      helm repo index . --url https://santosh-gh.github.io/online-store-helmcharts

      This creates/updates index.yaml with metadata about your charts.

    - Push to GitHub

    - Enable GitHub Pages

      Go to Settings → Pages in your repo.

      Select branch (main) and folder (/root or /docs if you store charts there).

      Save — GitHub Pages will give you a UR

      https://santosh-gh.github.io/online-store-helmcharts/

    - Add repo in Helm
      
      $ helm repo add online-store-helmcharts  https://santosh-gh.github.io/online-store-helmcharts                                                                             
      "online-store-helmcharts" has been added to your repositories

    $ helm repo update
      Hang tight while we grab the latest from your chart repositories...
      ...Successfully got an update from the "online-store-helmcharts" chart repository
      ...Successfully got an update from the "ingress-nginx" chart repository
      ...Successfully got an update from the "bitnami" chart repository
      ...Successfully got an update from the "grafana" chart repository
      ...Successfully got an update from the "prometheus-community" chart repository
      ...Unable to get an update from the "stable" chart repository (https://charts.helm.sh/stable):
              read tcp [2a00:23c7:9647:1801:410c:d382:32ad:fac3]:59849->[2606:50c0:8002::153]:443: wsarecv: A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond.
      Update Complete. ⎈Happy Helming!⎈

    $ helm search repo online-store-helmcharts
      WARNING: Repo "stable" is corrupt or missing. Try 'helm repo update'.
      WARNING: open C:\Users\HOME\AppData\Local\Temp\helm\repository\stable-index.yaml: The system cannot find the file specified.
      NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
      online-store-helmcharts/config          0.1.0           0.1.0           A Helm chart for Kubernetes
      online-store-helmcharts/order           0.1.0           0.1.0           A Helm chart for Kubernetes
      online-store-helmcharts/product         0.1.0           0.1.0           A Helm chart for Kubernetes
      online-store-helmcharts/rabbitmq        0.1.0           0.1.0           A Helm chart for Kubernetes
      online-store-helmcharts/store-front     0.1.0           0.1.0           A Helm chart for Kubernetes

# Install from GitHub Pages

    helm install config online-store-helmcharts/config --version 0.1.0
    helm install rabbitmq online-store-helmcharts/rabbitmq --version 0.1.0
    helm install order online-store-helmcharts/order --version 0.1.0
    helm install product online-store-helmcharts/product --version 0.1.0
    helm install store-front online-store-helmcharts/store-front --version 0.1.0


# Helm Rollback - Quickly revert if something goes wrong.

    helm rollback   config -n dev
    helm rollback   rabbitmq -n dev
    helm rollback   order -n dev
    helm rollback   product -n dev
    helm rollback   store-front -n dev

    
   Rolls back to the last stable version.

# Helm Uninstall - Removal of resources.

    helm uninstall config -n dev
    helm uninstall rabbitmq -n dev
    helm uninstall order -n dev
    helm uninstall product -n dev
    helm uninstall store-front -n dev

# Helm Lifecycle

                                      ┌───────────────────────┐
                                      │   Start with Chart    │
                                      │ (YAML templates +     │
                                      │   values.yaml)        │
                                      └───────────┬───────────┘
                                                  │
                                                  ▼
                                          ┌────────────────┐
                                          │   INSTALL      │
                                          │ helm install   │
                                          └───────┬────────┘
                                                  │
                                                  ▼
                                        ┌────────────────────┐
                                        │ Kubernetes objects │
                                        │ created: Deployment│
                                        │ Service, Ingress…  │
                                        └─────────┬──────────┘
                                                  │
                                ┌─────────────────┼──────────────────┐
                                │                 │                  │
                                ▼                 ▼                  ▼
                          ┌─────────────┐   ┌─────────────┐   ┌─────────────────┐
                          │   UPGRADE   │   │  ROLLBACK   │   │   DELETE        │
                          │ helm upgrade│   │helm rollback│   │ helm uninstall│ |
                          └──────┬──────┘   └──────┬──────┘   └───────┬─────────┘
                                 │                 │                  │
                                 ▼                 ▼                  ▼
                          ┌─────────────┐   ┌───────────────┐   ┌───────────────────┐
                          │ New release │   │ Previous      │   │ All resources     │
                          │ deployed    │   │ version       │   │ removed from      │
                          │ (e.g. v2)   │   │ restored      │   │ cluster           │
                          └─────────────┘   └───────────────┘   └───────────────────┘

# Advantages

    - Reusability

      Helm charts are templated YAMLs, so instead of copy-pasting Kubernetes manifests for each environment, 
      we define templates once and override with values.yaml.

      This enforces best practices and consistency across teams.

    - Parameterization with Values

      Configurations (image versions, replicas, ports, resource limits) are externalized 
      in values.yaml.

      Makes it easy to:

      Use the same chart in dev, dev and prod.

      Change configs without editing raw YAML.

    - Versioned Releases & Rollbacks

      Every helm install or helm upgrade creates a release version.

      We can easily rollback to a previous working version if an upgrade fails

    - Sharing & Community Ecosystem

      Helm has a huge ecosystem of prebuilt charts (like MySQL, Redis, Nginx, Prometheus).

      Saves time: we can install complex apps in minutes

    - Packaging & Distribution

      Charts are versioned, packaged (.tgz), and stored in Helm repositories.

      Just like npm or apt for apps → Helm is a package manager for Kubernetes.

    - Consistency Across Environments

      Same chart can be deployed with different values → ensures your app runs consistently 
      in dev, test, and prod.

# Advantages of Helm over kubectl

    - Packaging & Reuse

      kubectl: You must maintain multiple YAML files manually.

      helm: Bundles everything into a chart (like npm package). Easy to share and reuse.

    - Templating

      kubectl: YAML is static. If you want to change replicas from 2 → 5, you edit YAML directly.

      helm: YAML files are templates. Configs are passed via values.yaml → easier to manage across environments.

    - Versioning & Rollback

      kubectl: No concept of app versions. To rollback, you must manually reapply old YAML.

      helm: Maintains release history. You can rollback easily.

    - Configuration Management

      kubectl: Hard to manage multiple environments (dev, staging, prod) — you often duplicate YAMLs.

      helm: One chart → multiple environments via different values.yaml.

    - App Lifecycle Management

      kubectl: Limited to create/update/delete resources.

      helm: Full lifecycle (install, upgrade, rollback, uninstall) in a structured, predictable way.

    - Community & Prebuilt Charts

      kubectl: We must write every YAML ourself.

      helm: Thousands of ready-to-use charts (e.g., MySQL, Redis, Prometheus). Saves tons of time.

# Kustomize plane/raw manifests

# Review

    kustomize build ./manifests/order/overlays/dev

    kubectl kustomize ./manifests/config/base/
    kubectl kustomize ./manifests/rabbitmq/overlays/dev
    kubectl kustomize ./manifests/order/overlays/dev
    kubectl kustomize ./manifests/product/overlays/dev
    kubectl kustomize ./manifests/store-front/overlays/dev

    kubectl kustomize ./manifests/config/base/
    kubectl kustomize ./manifests/rabbitmq/overlays/test
    kubectl kustomize ./manifests/order/overlays/test
    kubectl kustomize ./manifests/product/overlays/test
    kubectl kustomize ./manifests/store-front/overlays/test

    kubectl kustomize ./manifests/config/base/
    kubectl kustomize ./manifests/rabbitmq/overlays/prod
    kubectl kustomize ./manifests/order/overlays/prod
    kubectl kustomize ./manifests/product/overlays/prod
    kubectl kustomize ./manifests/store-front/overlays/prod

# Apply Patches

    kustomize build ./manifests/order/overlays/dev | kubectl apply -f . -n dev

    kubectl apply -k ./manifests/config/base/ -n dev
    kubectl apply -k ./manifests/rabbitmq/overlays/dev -n dev
    kubectl apply -k ./manifests/order/overlays/dev -n dev
    kubectl apply -k ./manifests/product/overlays/dev -n dev
    kubectl apply -k ./manifests/store-front/overlays/dev -n dev

    kubectl apply -k ./manifests/config/base/ -n test
    kubectl apply -k ./manifests/rabbitmq/overlays/test -n test
    kubectl apply -k ./manifests/order/overlays/test -n test
    kubectl apply -k ./manifests/product/overlays/test -n test
    kubectl apply -k ./manifests/store-front/overlays/test -n test

    kubectl apply -k ./manifests/config/base/ -n prod
    kubectl apply -k ./manifests/rabbitmq/overlays/prod -n prod
    kubectl apply -k ./manifests/order/overlays/prod -n prod
    kubectl apply -k ./manifests/product/overlays/prod -n prod
    kubectl apply -k ./manifests/store-front/overlays/prod -n prod

# Using Helm and Kustomize togeteher
  
    There are 2 approches for using Helm and Kustomize togeteher:

    1. Template First

      Pros: Can fully utilize helm features.

      Cons: No release versioning and rollbacks.

    2. Overlay First

      Pros: Helm’s packaging and versioning
            Release versioning and rollbacks

        Cons: Limited helm benefits


# Kustomize Helm Charts (template first)

# Generate output template (deploy.yaml)

    helm template ./kustomize-helmcharts/config > ./kustomize-helmcharts/config/base/deploy.yaml
    helm template ./kustomize-helmcharts/order > ./kustomize-helmcharts/order/base/deploy.yaml
    helm template ./kustomize-helmcharts/product > ./kustomize-helmcharts/product/base/deploy.yaml
    helm template ./kustomize-helmcharts/rabbitmq > ./kustomize-helmcharts/rabbitmq/base/deploy.yaml
    helm template ./kustomize-helmcharts/store-front > ./kustomize-helmcharts/store-front/base/deploy.yaml

# Review deploy manifest (apply patches)    

    kustomize build ./kustomize-helmcharts/order/overlays/dev
    kustomize build ./kustomize-helmcharts/order/overlays/test
    kustomize build ./kustomize-helmcharts/order/overlays/prod        

    kubectl kustomize ./kustomize-helmcharts/config/base/
    kubectl kustomize ./kustomize-helmcharts/rabbitmq/overlays/dev
    kubectl kustomize ./kustomize-helmcharts/order/overlays/dev
    kubectl kustomize ./kustomize-helmcharts/product/overlays/dev
    kubectl kustomize ./kustomize-helmcharts/store-front/overlays/dev

    kubectl kustomize ./kustomize-helmcharts/config/base/
    kubectl kustomize ./kustomize-helmcharts/rabbitmq/overlays/test
    kubectl kustomize ./kustomize-helmcharts/order/overlays/test
    kubectl kustomize ./kustomize-helmcharts/product/overlays/test
    kubectl kustomize ./kustomize-helmcharts/store-front/overlays/test

    kubectl kustomize ./kustomize-helmcharts/config/base/
    kubectl kustomize ./kustomize-helmcharts/rabbitmq/overlays/prod
    kubectl kustomize ./kustomize-helmcharts/order/overlays/prod
    kubectl kustomize ./kustomize-helmcharts/product/overlays/prod
    kubectl kustomize ./kustomize-helmcharts/store-front/overlays/prod

# Apply the manifest

    kustomize build ./kustomize-helmcharts/order/overlays/dev | kubectl apply -f . -n dev

    kubectl apply -k ./kustomize-helmcharts/config/base/ -n dev
    kubectl apply -k ./kustomize-helmcharts/rabbitmq/overlays/dev -n dev
    kubectl apply -k ./kustomize-helmcharts/order/overlays/dev -n dev
    kubectl apply -k ./kustomize-helmcharts/product/overlays/dev -n dev
    kubectl apply -k ./kustomize-helmcharts/store-front/overlays/dev -n dev

    kubectl apply -k ./kustomize-helmcharts/config/base/ -n test
    kubectl apply -k ./kustomize-helmcharts/rabbitmq/overlays/test -n test
    kubectl apply -k ./kustomize-helmcharts/order/overlays/test -n test
    kubectl apply -k ./kustomize-helmcharts/product/overlays/test -n test
    kubectl apply -k ./kustomize-helmcharts/store-front/overlays/test -n test

    kubectl apply -k ./kustomize-helmcharts/config/base/ -n prod
    kubectl apply -k ./kustomize-helmcharts/rabbitmq/overlays/prod -n prod
    kubectl apply -k ./kustomize-helmcharts/order/overlays/prod -n prod
    kubectl apply -k ./kustomize-helmcharts/product/overlays/prod -n prod
    kubectl apply -k ./kustomize-helmcharts/store-front/overlays/prod -n prod

# Helmize Kustomization (Overlay first)

# Update base and overlays template manifests to generate the helm template (deploy.yaml)

    kustomize build ./helmize-kustmization/config/base > ./helmize-kustmization/config/templates/deploy.yaml
    kustomize build ./helmize-kustmization/rabbitmq/overlays/dev > ./helmize-kustmization/rabbitmq/templates/deploy.yaml
    kustomize build ./helmize-kustmization/order/overlays/dev > ./helmize-kustmization/order/templates/deploy.yaml
    kustomize build ./helmize-kustmization/product/overlays/dev > ./helmize-kustmization/product/templates/deploy.yaml
    kustomize build ./helmize-kustmization/store-front/overlays/dev > ./helmize-kustmization/store-front/templates/deploy.yaml

    kustomize build ./helmize-kustmization/rabbitmq/overlays/test > ./helmize-kustmization/rabbitmq/templates/deploy.yaml
    kustomize build ./helmize-kustmization/order/overlays/test > ./helmize-kustmization/order/templates/deploy.yaml
    kustomize build ./helmize-kustmization/product/overlays/test > ./helmize-kustmization/product/templates/deploy.yaml
    kustomize build ./helmize-kustmization/store-front/overlays/test > ./helmize-kustmization/store-front/templates/deploy.yaml

    kustomize build ./helmize-kustmization/rabbitmq/overlays/prod > ./helmize-kustmization/rabbitmq/templates/deploy.yaml
    kustomize build ./helmize-kustmization/order/overlays/prod > ./helmize-kustmization/order/templates/deploy.yaml
    kustomize build ./helmize-kustmization/product/overlays/prod > ./helmize-kustmization/product/templates/deploy.yaml
    kustomize build ./helmize-kustmization/store-front/overlays/prod > ./helmize-kustmization/store-front/templates/deploy.yaml


# Review deploy manifest (apply patches)    

    helm template ./helmize-kustmization/config
    helm template ./helmize-kustmization/rabbitmq
    helm template ./helmize-kustmization/order
    
    helm template ./helmize-kustmization/product
    helm template ./helmize-kustmization/store-front

# Apply the helm chart

    helm install config ./helmize-kustmization/config -n dev
    helm install rabbitmq ./helmize-kustmization/rabbitmq -n dev
    helm install order ./helmize-kustmization/order -n dev
    helm install product ./helmize-kustmization/product -n dev
    helm install store-front ./helmize-kustmization/store-front -n dev

    helm install config ./helmize-kustmization/config -n test
    helm install rabbitmq ./helmize-kustmization/rabbitmq -n test
    helm install order ./helmize-kustmization/order -n test
    helm install product ./helmize-kustmization/product -n test
    helm install store-front ./helmize-kustmization/store-front -n test

    helm install config ./helmize-kustmization/config -n prod
    helm install rabbitmq ./helmize-kustmization/rabbitmq -n prod
    helm install order ./helmize-kustmization/order -n prod
    helm install product ./helmize-kustmization/product -n prod
    helm install store-front ./helmize-kustmization/store-front -n prod