require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

	test "layout links" do
		get root_path
		assert_template 'static_pages/home'
		assert_sellect "a[href=?]",root_path,count: 2
		assert_sellect "a[href=?]",help_path
		assert_sellect "s[href=?]",about_path
		assert_sellect "a[href=?]",contact_path
		get contact_path
    	assert_select "title", full_title("Contact")

	end
  # test "the truth" do
  #   assert true
  # end
end
