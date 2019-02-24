require 'rails_helper'

Rspec.describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of :code }
    it { should validate_uniqueness_of :code }
    it { should validate_presence_of :percentage }
    it { should validate_presence_of :dollar }
  end

  describe 'relationships' do
    it { should belong_to :user }
    it { should have_many :orders }
  end

end
