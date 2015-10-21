require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

	def setup
		@user = users(:michael)
	end

	test "micropost interface" do 
		log_in_as(@user)																			# log in
		get root_path																					# navigate to home page
		assert_select 'div.pagination'												# check pagination
 
		assert_no_difference 'Micropost.count' do 						# check invalid submission
			post microposts_path, micropost: { content: "" }
		end
		assert_select 'div#error_explanation'

		content = "lorem ipsum"
		assert_difference 'Micropost.count', 1 do 					# make valid submission
			post microposts_path, micropost: { content: content }
		end

		assert_redirected_to root_url
		follow_redirect!
		assert_match content, response.body # what does this line do?

		assert_select 'a', text: 'delete'

		assert_difference 'Micropost.count', -1 do 										# delete post
			first_micropost = @user.microposts.paginate(page: 1).first
			delete micropost_path(first_micropost)
		end

		get user_path(users(:lana))						# visit other user's page

		assert_select "a", text: "delete", count: 0					# make sure there are no delete links
	end
end
