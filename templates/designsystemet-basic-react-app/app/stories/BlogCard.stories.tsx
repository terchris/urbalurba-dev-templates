import type { Meta, StoryObj } from '@storybook/react';
import { BlogCard } from '../components/BlogCard/BlogCard';
import { blogPosts } from '../data/BlogPosts.json';

const meta: Meta<typeof BlogCard> = {
  title: 'Components/Blog Card',
  component: BlogCard,
  parameters: {
    layout: 'centered',
  },
  tags: ['autodocs'],
};

export default meta;
type Story = StoryObj<typeof BlogCard>;

export const Default: Story = {
  args: {
    post: blogPosts[0],
  },
};

export const Featured: Story = {
  args: {
    post: blogPosts[0],
    featured: true,
    level: 2,
  },
};

export const WithTag: Story = {
  args: {
    post: blogPosts[1],
    tagText: 'Theming',
    tagColor: 'brand2',
  },
}; 