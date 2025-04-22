export interface BlogPost {
    id: string;
    title: string;
    excerpt: string;
    date: string;
    imageUrl: string;
    author?: string;
  }

export interface BlogCardProps {
  post: BlogPost;
}