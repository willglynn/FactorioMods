module ApplicationHelper
  def filter_params
    @filter_params ||= begin
      filter_params_array = [:v, :q]
      filter_params = params.select{ |k,v| filter_params_array.include? k.to_sym }
      filter_params
    end
  end

  def all_categories_mods_count
    Mod.count
  end

  ### Misc helpers:
  ####################

  def link_wrap_if(link_condition, *options, &block)
    if link_condition
      link_to link_condition, *options, &block
    else
      capture &block
    end
  end

  def missing_img(size, img_tag_options = {})
    img_tag_options = img_tag_options.reverse_merge({
      src: missing_img_url(size),
      title: t('helpers.no_image_available')
    })
    tag :img, img_tag_options
  end

  def mod_img(mod, size)
    tag :img,
      src: mod_img_url(mod, size),
      class: 'mod-img',
      title: (t('helpers.no_image_available') if !mod.imgur)
  end

  def mod_img_url(mod, size)
    mod.imgur(size).presence || missing_img_url(size)
  end

  def missing_img_url(size)
    root_path + "images/missing_#{size}.png"
  end

  def if_na(value, result = nil, na = nil, &block)
    na = na || t('helpers.not_available')
    use_na = (!!value == value) ? !value : value.blank?
    if use_na
      na
    else
      if block_given?
        capture(&block)
      else
        result.nil? ? value : result
      end
    end
  end

  def body_controller_classes
    controller_path = params[:controller].split('/')
    controller_path.each_index.map{|i| controller_path[0..i].join('-')} << params[:action]
  end

  ### Content helpers:
  ####################

  def title(page_title = nil, options = {suffix: true})
    @title ||= ''
    @title = page_title.to_s + @title unless page_title.nil?
    @title = @title + t('layouts.application.title.suffix') if options[:suffix]
    @title = @title.strip
    content_for :title, @title[0].upcase + @title[1..-1]
  end

  def title_append(page_title_section)
    @title ||= ''
    @title = page_title_section.to_s + @title
  end

  ### Urls helpers:
  ####################

  def sort_url(sort)
    polymorphic_path([sort, (@category if params[:action] == 'index'), :mods], filter_params)
  end

  def category_filter_url(category)
    polymorphic_path([@sort, category, :mods], filter_params)
  end

  def version_filter_url(version)
    version_number = version ? version.number : nil
    polymorphic_path([@sort, @category, :mods], filter_params.merge(v: version_number))
  end

  def search_form_url
    polymorphic_path([@sort, @category, :mods])
  end

  def search_filter_url(query)
    polymorphic_path([@sort, @category, :mods], filter_params.merge(q: query))
  end

  ### Links helpers
  ####################

  def sort_link(sort, &block)
    link_to sort_url(sort), class: sort_active_class(sort), &block
  end

  def category_link(category, &block)
    link_to category_filter_url(category), class: category_filter_active_class(category), &block
  end

  def version_filter_option(version, &block)
    content_tag :option,
                t('.for_game_version', version: version.number),
                value: version_filter_url(version),
                selected: version_filter_selected_state(version)
  end

  def search_form(&block)
    content_tag(:form, action: search_form_url, method: 'get') do
      tag(:input, type: 'hidden', name: :v, value: params[:v]) +
      capture(&block)
    end
  end

  ### Active state helpers
  ####################

  def sort_active_class(sort)
    (@sort == sort) ? 'active' : nil
  end

  def category_filter_active_class(category)
    (@category == category) ? 'active' : nil
  end

  def version_filter_selected_state(version)
    (@game_version == version) ? 'selected' : nil
  end
end
