require 'rails_helper'

RSpec.describe 'Feature: User Authentication', type: :feature do
  describe 'New users can register' do
    before(:each) do
      User.destroy_all
    end

    %w[crest].each do |strategy|
      scenario "with #{strategy}" do
        visit '/'
        click_link 'login'
        expect( page ).to have_content "Successfully authenticated"
      end
    end
  end

  describe 'Existing users can sign in' do
    let!(:user) { create(:user_sicks) }

    %w[crest].each do |strategy|
      scenario "with #{strategy}" do
        visit '/'
        click_link 'login'

        expect( page ).to have_content "Successfully authenticated"
        expect( page ).to have_content user.name
      end
    end
  end

  context 'Signed in Users' do
    let!(:user) { create(:user_sicks) }

    def log_in
      visit '/'
      click_link 'login'
    end

    describe 'Users with only one char' do
      before(:each) do
        user.chars.offset(1).destroy_all
        log_in
      end

      scenario 'cannot delete their only char' do
        click_link user.name
        click_link 'account'
        expect( page ).to_not have_button "delete char #{user.chars.first.name}"
      end

      scenario 'can add another char' do
        OmniAuth.config.mock_auth[:crest] = OmniAuth::AuthHash.new({
          provider: "crest",
          uid: 2076199677,
          info: {
            name: "Doctor Boki",
            character_id: 2076199677,
            character_owner_hash: "0ILVMUgY3CU0RSsU4I0oefUR5c4="
          }})
        click_link user.name
        click_link 'account'
        click_link 'add char'
        expect( page ).to have_content "Added character auth"
      end
    end

    describe 'Users with more than one char' do
      before(:each) do
        user.chars.create( attributes_for :crest_char )
        log_in
      end

      scenario "can delete a char" do
        click_link user.name
        click_link 'account'
        click_button "delete char #{user.chars.second.name}"
        expect( page ).to have_content "#{user.chars.second.name} Deleted"
      end
    end
  end
end
