# Designsystemet Basic React App

File: templates/designsystemet-basic-react-app/README-designsystemet-basic-react-app.md

This is a simple React application template that integrates the [Designsystemet](https://github.com/digdir/designsystemet) from Digdir to create a blog page. The template displays a list of blog posts as cards, each with a title, excerpt, date, and an image, sourced from a JSON file.

## Purpose

The purpose of this template is to provide a minimal starting point for developers who want to build a blog page using Designsystemet's components and styling. It demonstrates how to set up a React app with Designsystemet, use its components (e.g., Card, Heading, Paragraph), and structure data for a blog using a JSON file.

## Features

- Blog page displaying posts as cards with images, titles, excerpts, and dates.
- Uses Designsystemet's CSS and React components for consistent, accessible UI.
- Data sourced from a `blog-posts.json` file for easy content updates.
- Built with Vite and React for fast development and modern tooling.
- TypeScript support for type-safe development.
- Inter font integration as recommended by Designsystemet.
- Storybook integration for previewing Designsystemet components.

## Prerequisites

The devcontainer-toolbox sets up everything you need to run this project locally.
See the repo https://github.com/norwegianredcross/devcontainer-toolbox on how to set it up.
When you have the devcontainer-toolbox set up, you type the following command in your terminal:

```bash
.devcontainer/dev/dev-template.sh
```

Then you select this template from the list:

```plaintext
1. designsystemet-basic-react-app
```

## Getting Started

Once you have installed the template you are ready to start developing.

Run the following commands to build and run the server locally:

```bash
npm install
npm run dev
```

You will see the following output:

```plaintext
TODO: Add output
```

This means the server is running and listening on port 3000. You can access it by navigating to `http://localhost:3000` in your web browser.
You will see the sample list of blog posts.

### Storybook

TODO: Add instructions for how to use Storybook to preview Designsystemet components.

```bash
npm run storybook
```

Open http://localhost:6006 in your browser to access the Storybook interface. Here, you can explore the components used in this template (e.g., Card, Heading, Paragraph) and see their props and variations as provided by Designsystemet's Storybook documentation.

### Adding blog posts

Blog Data: The blog posts are stored in app/data/blog-posts.json. Update this file to add or modify posts. Each post includes:

- id: Unique identifier (string).
- title: Post title (string).
- excerpt: Short summary (string).
- date: Publication date (string, e.g., "2025-04-20").
- imageUrl: URL or path to the post's image (string).

Example:

```json
[
  {
    "id": "1",
    "title": "Exploring Designsystemet",
    "excerpt": "A look into Digdir's Designsystemet for building accessible UIs.",
    "date": "2025-04-20",
    "imageUrl": "/images/exploring-designsystemet.webp"
  }
]
```

### Changing the blog page

- **Customizing the UI**: Modify app/App.tsx to adjust the blog page layout or add new components. Use Designsystemet's components from @digdir/designsystemet-react (e.g., Card, Heading, Paragraph) and styles from @digdir/designsystemet-css.
- **Theming**: The template uses Designsystemet's default digdir theme. To create a custom theme, visit the Designsystemet Theme Builder and follow the instructions to generate and import your theme.
- **Using Storybook**: Storybook provides a sandbox to explore Designsystemet components. After running npm run storybook, navigate to the Storybook URL (http://localhost:6006). You can:
  - View component documentation and props.
  - Test different component states and variants.
  - Use the components listed in Designsystemet's Storybook to build new features or customize the blog page.


## Deploying to Kubernetes on your local machine

TODO: Add instructions for deploying to Kubernetes on your local machine.

## File structure

```plaintext
templates/designsystemet-basic-react-app/
├── package.json
├── tsconfig.json
├── vite.config.ts
├── .storybook/
│   └── main.ts
├── public/
│   └── images/
│       ├── exploring-designsystemet.webp
│       ├── creating-custom-themes.webp
│       └── accessible-components.webp
├── app/
│   ├── App.tsx
│   ├── main.tsx
│   ├── app.css
│   ├── data/
│   │   └── blog-posts.json
│   ├── _components/
│   │   └── blog-card/
│   │       ├── blog-card.tsx
│   │       └── blog-card.css
│   ├── stories/
│   │   └── blog-card.stories.tsx
│   └── types/
│       └── blog.ts
├── .dockerignore                # Ignore files for Docker build
├── .gitignore                  # Ignore files for Git
├── .github/
│   └── workflows/
│       └── urbalurba-build-and-push.yaml  # GitHub Actions CI
├── Dockerfile                   # Container build for app
├── manifests/
│   ├── deployment.yaml          # K8s deployment
│   ├── ingress.yaml             # Traefik ingress
│   └── kustomization.yaml       # For ArgoCD compatibility
└── README-designsystemet-basic-react-app.md
```
