Below is the formatted markdown document that includes both the original GraphQL queries and their Ruby examples using Shopify's GraphQL client.

---

# Blogs and Articles

This document provides GraphQL queries to list blogs and articles in a Shopify store, along with Ruby examples that execute these queries using Shopify's GraphQL client.

---

## GraphQL Queries

### 1. List All Blogs

To retrieve a list of all blogs in the store, use the following GraphQL query:

```gql
query ListBlogs {
  blogs(first: 50) {
    nodes {
      id
      title
      handle
      createdAt
      updatedAt
    }
  }
}
```

This query fetches up to 50 blogs with their `id`, `title`, `handle`, `createdAt`, and `updatedAt` fields.

### 2. List Articles for a Specific Blog

To retrieve articles for a specific blog, use this GraphQL query:

```graphql
query ListArticlesForBlog($id: ID!) {
  blog(id: $id) {
    id
    articles(first: 10) {
      nodes {
        id
        title
        handle
        author {
          firstName
          lastName
        }
        createdAt
      }
    }
  }
}
```

Replace `$id` with the ID of the blog you want to query. This query fetches up to 10 articles for the specified blog, including their `id`, `title`, `handle`, `author`, and `createdAt` fields.

### 3. List All Articles Across Blogs

To retrieve all articles across all blogs, use the following query:

```graphql
query ListAllArticles {
  articles(first: 10) {
    edges {
      node {
        id
        title
        handle
        blog {
          title
        }
        createdAt
      }
    }
  }
}
```

This query fetches up to 10 articles across all blogs, including their `id`, `title`, `handle`, the blog's `title`, and `createdAt` fields.

> **Note:** Adjust the `first` parameter to control the number of results returned per request. For pagination, use the `after` or `before` cursors provided in the `pageInfo` field.

#### Related Resources

- [Blogs Query Documentation](#)
- [Articles Query Documentation](#)

---

## Ruby Examples

Below are the Ruby examples that use Shopify's GraphQL client to execute the queries above.

### 1. List All Blogs

To retrieve all blogs in the store:

```ruby
require 'shopify_api'

query = <<~GRAPHQL
  query {
    blogs(first: 50) {
      nodes {
        id
        title
        handle
        createdAt
        updatedAt
      }
    }
  }
GRAPHQL

response = ShopifyAPI::GraphQL.client.query(query)
puts response.data.blogs.nodes
```

This fetches up to 50 blogs with their `id`, `title`, `handle`, `createdAt`, and `updatedAt` fields.

### 2. List Articles for a Specific Blog

To retrieve articles for a specific blog:

```ruby
require 'shopify_api'

blog_id = "gid://shopify/Blog/123456789" # Replace with your blog ID

query = <<~GRAPHQL
  query {
    blog(id: "#{blog_id}") {
      id
      articles(first: 10) {
        nodes {
          id
          title
          handle
          author {
            firstName
            lastName
          }
          createdAt
        }
      }
    }
  }
GRAPHQL

response = ShopifyAPI::GraphQL.client.query(query)
puts response.data.blog.articles.nodes
```

Replace `blog_id` with the ID of the blog you want to query. This fetches up to 10 articles for the specified blog.

### 3. List All Articles Across Blogs

To retrieve all articles across all blogs:

```ruby
require 'shopify_api'

query = <<~GRAPHQL
  query {
    articles(first: 10) {
      edges {
        node {
          id
          title
          handle
          blog {
            title
          }
          createdAt
        }
      }
    }
  }
GRAPHQL

response = ShopifyAPI::GraphQL.client.query(query)
puts response.data.articles.edges.map(&:node)
```

This fetches up to 10 articles across all blogs, including their `id`, `title`, `handle`, the blog's `title`, and `createdAt` fields.

> **Tip:** Adjust the `first` parameter to control the number of results returned, and use pagination if needed.

---

*Was this answer useful?* [Yes] [No]