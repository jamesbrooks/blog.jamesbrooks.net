# Move jekyll-og-image generated images from 'image' to 'og_image'
# This prevents Chirpy from displaying them as featured images on posts
# while still using them for og:image meta tags

Jekyll::Hooks.register :posts, :pre_render do |post|
  image = post.data['image']

  # jekyll-og-image sets image as a Hash with 'path' key
  if image.is_a?(Hash) && image['path']&.include?('images/og/posts')
    # Convert to full URL for og_image (Chirpy expects absolute URL)
    post.data['og_image'] = "#{post.site.config['url']}#{image['path']}"
    post.data.delete('image')
  end
end
