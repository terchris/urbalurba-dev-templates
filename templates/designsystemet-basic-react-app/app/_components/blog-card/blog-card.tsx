import { Card, CardBlock, Heading, Paragraph, Tag } from '@digdir/designsystemet-react';
import { BlogPost } from '../../types/blog';
import './blog-card.css';

type BlogCardProps = {
  post: BlogPost;
  featured?: boolean;
  level?: 2 | 3;
  tagText?: string;
  tagColor?: 'brand1' | 'brand2' | 'brand3';
} & React.HTMLAttributes<HTMLDivElement>;

export const BlogCard = ({
  post,
  featured = false,
  level = 3,
  className,
  tagText,
  tagColor = 'brand1',
  ...props
}: BlogCardProps) => {
  return (
    <Card
      data-featured={featured}
      className={`blog-card ${className || ''}`}
      data-color="neutral"
      {...props}
    >
      <CardBlock>
        <img src={post.imageUrl} alt={post.title} className="blog-card-image" />
      </CardBlock>
      <CardBlock>
        {tagText && (
          <Tag className="blog-card-tag" data-color={tagColor} data-size="sm">
            {tagText}
          </Tag>
        )}
        <Heading level={level} data-size={featured ? 'lg' : 'sm'}>
          {post.title}
        </Heading>
        <Paragraph data-size={featured ? 'lg' : 'sm'}>{post.excerpt}</Paragraph>
        <Paragraph data-size={featured ? 'md' : 'xs'} className="blog-card-meta">
          <time dateTime={post.date}>{new Date(post.date).toLocaleDateString()}</time>
          {post.author && (
            <>
              <span aria-hidden className="blog-card-meta-square" />
              <span>{post.author}</span>
            </>
          )}
        </Paragraph>
      </CardBlock>
    </Card>
  );
};

export default BlogCard; 