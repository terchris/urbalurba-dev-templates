# C# Basic Webserver

filename: templates/csharp-basic-webserver/README-csharp-basic-webserver.md

A simple ASP.NET Core web server written in C#.
Purpose is to demonstrate how to develop a simple web server that can be deployed to your local Kubernetes using ArgoCD and GitHub Actions.
See the repo https://github.com/terchris/urbalurba-infrastructure for setting up local kubernetes and ArgoCD.

## Prerequisites

The devcontainer-toolbox sets up everything you need to run this project locally.
See the repo https://github.com/norwegianredcross/devcontainer-toolbox on how to set it up.
When you have the devcontainer-toolbox set up, type the following command in your terminal:

```bash
.devcontainer/dev/dev-template.sh
```

Then you select this template from the list:

```plaintext
1. csharp-basic-webserver
````

## Getting started

Once you have installed the template, run these commands to build and run the server locally:

```bash
dotnet restore src/WebApplication/WebApplication.csproj
dotnet watch run --project src/WebApplication
```

You will see the following output:

```plaintext
Building...
info: Microsoft.Hosting.Lifetime[14]
      Now listening on: http://0.0.0.0:3000
info: Microsoft.Hosting.Lifetime[0]
      Application started. Press Ctrl+C to shut down.
````

The server runs on port 3000. Access it at http://localhost:3000 in your browser to see:

"Hello world! Template: csharp-basic-webserver" with current time/date

Edit src/WebApplication/Program.cs and save changes - the server will auto-reload with dotnet watch.

## Deploying to Kubernetes on your local machine

TODO: Add instructions for deploying to Kubernetes on your local machine.

## File structure

The file structure of the project is as follows:

```plaintext
templates/csharp-basic-webserver/
├── src/
│   └── WebApplication/
│       ├── Program.cs          # ASP.NET Core entry point
│       └── WebApplication.csproj  # Project dependencies
├── Dockerfile                  # .NET multi-stage build
├── manifests/
│   ├── deployment.yaml         # K8s deployment (port 80)
│   ├── ingress.yaml            # Traefik ingress
│   └── kustomization.yaml      # ArgoCD configuration
├── .dockerignore               # C# specific ignores
├── .gitignore                  
├── .github/
│   └── workflows/
│       └── build-and-push.yaml # .NET CI/CD pipeline
└── README-csharp-basic-webserver.md    # this file
```
