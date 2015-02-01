Contentbirdme::Application.routes.draw do
  root 'home#index'
  get  'robots.txt'					  => 'home#robots'
  get  'p'                            => 'social_contents#index', as: 'social_contents'
  get  'p/:id'                        => 'social_contents#show',  as: 'social_content'
  get  'permalink/:content_slug'      => 'contents#permalink',    as: 'content_permalink'
  get  '/:section_slug/contents/new'  => 'contents#new',          as: 'new_content'
  post '/:section_slug/contents'      => 'contents#create',       as: 'create_content'
  get  '/:section_slug'               => 'contents#index',        as: 'contents'
  get  '/:section_slug/:content_slug' => 'contents#show',         as: 'content'
end