# TypeScript Basic Webserver

A simple Express server written in TypeScript.

## Getting started

```bash
npm install
npm run dev
```

```plaintext
typescript-basic-webserver/
├── app/
│   └── index.ts                 # Express server with Hello World
├── Dockerfile                   # Container build for app
├── manifests/
│   ├── deployment.yaml          # K8s deployment
│   └── kustomization.yaml       # For ArgoCD compatibility
├── .devcontainer/
│   └── project-setup.sh         # Project-specific setup (see below)
├── .github/
│   └── workflows/
│       └── build-and-push.yaml  # GitHub Actions CI
├── package.json
├── tsconfig.json
└── README.md
```
