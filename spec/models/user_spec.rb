require 'rails_helper'

RSpec.describe User, type: :model do
  describe "#persist_spotify_data" do
    it "should update the record with the supplied data" do
      subject.persist_spotify_data('test')
      expect(subject.spotify_user_data).to eq('test')
    end
  end
end