import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { BlogCard } from './BlogCard';

describe('BlogCard', () => {
  it('renders blog post information correctly', () => {
    const testPost = {
      id: '1',
      title: 'Test Blog Post',
      excerpt: 'This is a test excerpt',
      date: '2024-01-01',
      imageUrl: '/images/test-image.webp'
    };

    render(<BlogCard post={testPost} />);

    // Check if title is rendered
    expect(screen.getByText('Test Blog Post')).toBeInTheDocument();
    
    // Check if excerpt is rendered
    expect(screen.getByText('This is a test excerpt')).toBeInTheDocument();
    
    // Check if date is rendered
    expect(screen.getByText('2024-01-01')).toBeInTheDocument();
  });

  it('renders image with correct alt text', () => {
    const testPost = {
      id: '1',
      title: 'Test Blog Post',
      excerpt: 'This is a test excerpt',
      date: '2024-01-01',
      imageUrl: '/images/test-image.webp'
    };

    render(<BlogCard post={testPost} />);
    
    const image = screen.getByRole('img');
    expect(image).toHaveAttribute('src', '/images/test-image.webp');
    expect(image).toHaveAttribute('alt', 'Test Blog Post');
  });
}); 