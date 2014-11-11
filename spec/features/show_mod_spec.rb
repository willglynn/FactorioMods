require 'rails_helper'
include Warden::Test::Helpers

feature 'Display full mod information' do
  scenario 'Mod with just name and category' do
    category = create :category, name: 'Potato category'
    create :mod, name: 'Super Mod', category: category
    visit '/mods/potato-category/super-mod'
    expect(page).to have_content 'Super Mod'
    expect(page).to have_content 'Potato category'
  end

  scenario 'Mod with name, category and media links' do
    category = create :category, name: 'Potato category'
    create :mod, name: 'Super Mod', category: category, media_links_string: "http://i.imgur.com/qLpt6gI.jpg\nhttp://gfycat.com/EthicalZanyHuman"
    visit '/mods/potato-category/super-mod'
    expect(page).to have_content 'Super Mod'
    expect(page).to have_content 'Potato category'
    expect(page).to have_css 'img[src="http://i.imgur.com/qLpt6gI.jpg"]'
    expect(page).to have_css 'img[src="http://i.imgur.com/qLpt6gIs.jpg"]'
    expect(page).to have_css 'img[src="https://thumbs.gfycat.com/EthicalZanyHuman-poster.jpg"]'
  end

  scenario 'Visiting the mod page as the owner of the mod should display a link to edit the mod' do
    category = create :category, name: 'Potato category'
    create :mod, name: 'Super Mod', category: category
    visit '/mods/potato-category/super-mod'
    expect(page).to have_link 'Edit mod', '/mods/super-mod/edit'
  end
  # expect(page).to have_content 'Mah super mod'
  # expect(page).to have_content 'Potato category'
  # expect(page).to have_link 'factorio-mods/mah-super-mod', href: 'http://github.com/factorio-mods/mah-super-mod'
  # expect(page).to have_link href: 'http://www.factorioforums.com/forum/viewtopic.php?f=14&t=5971&sid=1786856d6a687e92f6a12ad9425aeb9e'
  # expect(page).to have_content 'Lorem ipsum description potato salad simulator'
  # expect(page).to have_summary 'This is a small mod for testing'
  # expect(page).to have_css 'img', src: 'http://i.imgur.com/qLpt6gI.jpg'
  # expect(page).to have_css 'img', src: 'http://i.imgur.com/qLpt6gIs.jpg'
  # expect(page).to have_css 'img', src: 'http://i.imgur.com/qLpt6gIs.jpg'
end