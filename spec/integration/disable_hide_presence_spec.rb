require "rails_helper"

RSpec.describe "disable-hide-presence" do
	let(:user) { Fabricate(:user, trust_level: 1) }
	let(:user_hidden_presence) { Fabricate(:user, trust_level: 1) }
	
	let(:viewer) { Fabricate(:user, trust_level: 2) }
	let(:viewer_admin) { Fabricate(:admin) }
	
	let(:hider) { Fabricate(:user, trust_level: 2) }

	before do
		user_hidden_presence.user_option.update!(hide_profile_and_presence: true)
	end

	def check_can_see_profile(target_user, expected_result: true)
		get "/u/#{target_user.username}.json"
		data = JSON.parse(response.body)

		if expected_result
			expect(data['user']['profile_hidden']).to be_blank
		else
			expect(data['user']['profile_hidden']).to eq(true)
		end
	end

	def check_can_update_setting(target_user, starting_value: false, expect_change: true)
		target_user.user_option.update!(hide_profile_and_presence: starting_value)
		target_user.user_option.update!(external_links_in_new_tab: true)
		
		put "/u/#{target_user.username}.json", params: {
			hide_profile_and_presence: !starting_value,
			external_links_in_new_tab: false # check that this does get changed
		}

		get "/u/#{target_user.username}.json"
		data = JSON.parse(response.body)

		expect(data['user']['user_option']['hide_profile_and_presence']).to eq(expect_change ? !starting_value : starting_value)
		expect(data['user']['user_option']['external_links_in_new_tab']).to eq(false)
	end

	def check_can_hide_profile(target_user, expected_result: true)
		check_can_update_setting(target_user, starting_value: false, expect_change: expected_result)
	end

	def check_can_unhide_profile(target_user, expected_result: true)
		check_can_update_setting(target_user, starting_value: true, expect_change: expected_result)
	end

	context "disabled" do

		before do
			SiteSetting.disable_hide_presence_enabled = false
		end

		context "as user wanting to hide profile" do

			before do
				sign_in(hider)
			end

			it "should allow requests to change setting" do
				check_can_hide_profile(hider)
				check_can_unhide_profile(hider)
			end

		end

		context "as user with hidden profile" do

			before do
				sign_in(user_hidden_presence)
			end

			it "should allow viewing own profile" do
				check_can_see_profile(user_hidden_presence)
			end

		end

		context "as logged-in viewer" do

			before do
				sign_in(viewer)
			end

			it "should allow viewing non-hidden profiles" do
				check_can_see_profile(user)
			end

			it "should not allow viewing hidden profiles" do
				check_can_see_profile(user_hidden_presence, expected_result: false)
			end

		end

		context "as staff viewer" do

			before do
				sign_in(viewer_admin)
			end

			it "should allow viewing non-hidden profiles" do
				check_can_see_profile(user)
			end

			it "should allow viewing hidden profiles" do
				check_can_see_profile(user_hidden_presence)
			end

		end

		context "as anonymous viewer" do

			it "should allow viewing non-hidden profiles" do
				check_can_see_profile(user)
			end

			it "should not allow viewing hidden profiles" do
				check_can_see_profile(user_hidden_presence, expected_result: false)
			end

		end

	end

	context "enabled" do

		before do
			SiteSetting.disable_hide_presence_enabled = true
		end

		context "as user wanting to hide profile" do

			before do
				sign_in(hider)
			end

			it "should ignore requests to change setting" do
				check_can_hide_profile(hider, expected_result: false)
				check_can_unhide_profile(hider, expected_result: false)
			end

		end

		context "as user with hidden profile" do

			before do
				sign_in(user_hidden_presence)
			end

			it "should allow viewing own profile" do
				check_can_see_profile(user_hidden_presence)
			end

		end

		context "as logged-in viewer" do

			before do
				sign_in(viewer)
			end

			it "should allow viewing non-hidden profiles" do
				check_can_see_profile(user)
			end

			it "should allow viewing hidden profiles" do
				check_can_see_profile(user_hidden_presence)
			end

		end

		context "as staff viewer" do

			before do
				sign_in(viewer_admin)
			end

			it "should allow viewing non-hidden profiles" do
				check_can_see_profile(user)
			end

			it "should allow viewing hidden profiles" do
				check_can_see_profile(user_hidden_presence)
			end

		end

		context "as anonymous viewer" do

			it "should allow viewing non-hidden profiles" do
				check_can_see_profile(user)
			end

			it "should allow viewing hidden profiles" do
				check_can_see_profile(user_hidden_presence)
			end

		end

	end
end
