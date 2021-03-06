Time.zone = 'Tokyo'

page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

set :site_url, 'https://rono23.com'
set :site_title, 'rono23'
set :site_author, 'rono23'

set :markdown_engine, :redcarpet
set :markdown, hard_wrap: true,
               autolink: true,
               no_intra_emphasis: true,
               tables: true,
               space_after_headers: true,
               lax_spacing: true,
               fenced_code_blocks: true,
               strikethrough: true,
               footnotes: true

set :css_dir, 'stylesheets'
set :js_dir, 'javascripts'
set :images_dir, 'images'

activate :blog do |blog|
  blog.prefix = 'posts'
  blog.sources = '{year}-{month}-{day}-{num}.html'
  blog.permalink = '{slug}.html'
  blog.taglink = 'tags/:tag.html'
  blog.tag_template = "#{blog.prefix}/tag.html"
end

activate :directory_indexes

page 'posts/feed.xml', layout: false

configure :development do
  activate :livereload
end

configure :build do
  activate :minify_css
  activate :minify_javascript
  activate :asset_hash
end

activate :deploy do |deploy|
  deploy.deploy_method = :git
  deploy.branch = 'master'
end
