require 'rails_helper'
require 'spec_helper'
require 'utilities/pusher_utilities'

RSpec.describe PusherUtilities do
  describe "#broadcast_vote" do
    it "should return empty hash" do 
      expect(PusherUtilities::broadcast_vote('test_channel', 'test_vote')).to eq({})
    end
  end
  describe "#broadcast_current_track" do
    it "should return empty hash" do 
      expect(PusherUtilities::broadcast_current_track('test_channel', 'test_track')).to eq({})
    end
  end
  describe "#broadcast_host_presence" do
    it "should return empty hash" do 
      expect(PusherUtilities::broadcast_host_presence('test_channel', true)).to eq({})
    end
  end
  describe "#broadcast_vote_status" do
    it "should return empty hash" do 
      expect(PusherUtilities::broadcast_vote_status('test_channel', 'test_status')).to eq({})
    end
  end
  describe "#broadcast_next_track" do
    it "should return empty hash" do 
      expect(PusherUtilities::broadcast_next_track('test_channel', 'test_track')).to eq({})
    end
  end
end