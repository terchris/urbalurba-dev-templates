import React from 'react';
import { Heading } from '@digdir/designsystemet-react';
import { BlogCard } from './components/BlogCard/BlogCard';
import { blogPosts } from './data/BlogPosts.json';
import './App.css';
import '@digdir/designsystemet-css/index.css';
import '@digdir/designsystemet-theme';

const App: React.FC = () => {
  return (
    <div className="app">
      <header className="app-header">
        <Heading level={1} size="large">
          Designsystemet Blog
        </Heading>
      </header>
      <main className="blog-grid">
        {blogPosts.map((post, index) => (
          <BlogCard 
            key={post.id} 
            post={post} 
            featured={index === 0}
            level={index === 0 ? 2 : 3}
          />
        ))}
      </main>
    </div>
  );
};

export default App;