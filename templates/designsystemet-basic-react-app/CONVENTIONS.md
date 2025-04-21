# Project Conventions

## File and Directory Naming

### Components
- Use PascalCase for component files and directories
- Example: `BlogCard/BlogCard.tsx`, `BlogCard/BlogCard.css`
- Co-locate tests with components: `BlogCard/BlogCard.test.tsx`

### Stories
- Use PascalCase for story files
- Match the component name: `BlogCard.stories.tsx`

### Types
- Use PascalCase for type definition files
- Example: `Blog.ts`, `User.ts`

### Data Files
- Use PascalCase for data files
- Example: `BlogPosts.json`, `UserData.json`

## Directory Structure
```
app/
├── components/          # All components (not _components)
│   └── BlogCard/       # Component directory
│       ├── BlogCard.tsx
│       ├── BlogCard.css
│       └── BlogCard.test.tsx
├── stories/            # Storybook stories
│   └── BlogCard.stories.tsx
├── types/              # TypeScript type definitions
│   └── Blog.ts
└── data/              # Data files
    └── BlogPosts.json
```

## Import Conventions
- Use relative paths for local imports
- Use explicit file extensions for non-TypeScript files (e.g., `.css`, `.json`)
- Example:
  ```typescript
  import { BlogCard } from '../components/BlogCard/BlogCard';
  import { BlogPost } from '../types/Blog';
  import './BlogCard.css';
  ```

## Component Structure
- One component per file
- Match file name to component name
- Export both named and default exports
- Example:
  ```typescript
  export const BlogCard = () => { ... };
  export default BlogCard;
  ``` 