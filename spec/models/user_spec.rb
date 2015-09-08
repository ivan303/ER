require 'rails_helper'

describe User do
	before(:each) do
		@user = FactoryGirl.create(:user, :email => "a@b.com")
		byebug
	end

	subject { @user }

	it { should validate_presence_of(:email) }	
	it { should validate_presence_of(:firstname) }
	it { should validate_presence_of(:lastname) }
	it { should validate_presence_of(:address) }

	it 'email should be returned as String' do
		expect(@user.email).to match "a@b.com"
	end

	context 'approved' do
		let(:user) { FactoryGirl.create(:user, :approved => true) }
		subject { :user }
		it { expect(user).to be_active_for_authentication }
	end

	context 'not approved' do
		let(:user) { FactoryGirl.create(:user, :approved => false) }
		subject { :user }
		it { expect(user).not_to be_active_for_authentication }
	end

end
