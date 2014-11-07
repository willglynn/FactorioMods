ActiveAdmin.register ForumPost do
  config.sort_order = "last_post_at_desc"

  controller do
    def scoped_collection
      ForumPost.includes(:mod)
    end
  end

  collection_action :scrap, method: :post do
    scraper = ForumPostsScraper.new
    posts = scraper.scrap
    ForumPost.transaction do
      posts.each(&:save!)
    end
    render json: {}
  end

  action_item do
    link_to icon('spin') + ' Scrap',
            [:scrap, :admin, :forum_posts],
            id: 'scrap-forum-posts',
            remote: true,
            method: :post,
            'data-type' => :json
  end

  scope :title_changed

  index do
    selectable_column
    id_column

    column :post_number, sortable: :post_number do |post|
      link_to post.post_number, post.url
    end

    column :title, sortable: :title do |post|
      link_to post.title, post.url
    end

    column :published_at, sortable: :published_at do |post|
      span distance_of_time_in_words_to_now(post.published_at), title: post.published_at
    end

    column :last_post_at, sortable: :last_post_at do |post|
      span distance_of_time_in_words_to_now(post.last_post_at), title: post.last_post_at
    end

    column :comments_count
    column :views_count

    column :mod do |post|
      if post.mod
        link_to post.mod.id, [:edit, :admin, post.mod]
      else
        link_to 'Create', [:new, :admin, :mod, forum_post_id: post.id]
      end
    end

    column :title_changed
  end

  # See permitted parameters documentation:
  # https://github.com/gregbell/active_admin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
  #
  # permit_params :list, :of, :attributes, :on, :model
  #
  # or
  #
  # permit_params do
  #  permitted = [:permitted, :attributes]
  #  permitted << :other if resource.something?
  #  permitted
  # end

  # collection_action
end