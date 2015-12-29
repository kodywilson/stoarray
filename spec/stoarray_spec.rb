require 'spec_helper'

base_url = 'https://xms/api/json/v2/types/'
headers  = { "Content-Type" => "application/json" }
params   = {}

describe Stoarray do

  it "has a version number" do
    expect(Stoarray::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(false)
  end

  describe ".error_text" do
    context "given three parameters" do
      it "returns a failure code" do
        codey = Stoarray.new.error_text("snap", 'https://wrongo/bongo', "snapshots")
        expect(codey['status']).to eql(400)
      end
    end
  end

  describe ".host" do
    context "given the wrong url" do
      it "returns a failure code" do
        url = base_url + 'hast'
        hosty = Stoarray.new(headers: headers, meth: 'Get', params: params, url: url).host
        expect(hosty['status']).to eql(400)
      end
    end
  end

  describe ".refresh" do
    context "given the wrong url" do
      it "returns a failure code" do
        url = base_url + 'sillyputty'
        refreshy = Stoarray.new(headers: headers, meth: 'Get', params: params, url: url).refresh
        expect(refreshy['status']).to eql(400)
      end
    end
  end

  describe ".snap" do
    context "given the wrong url" do
      it "returns a failure code" do
        url = base_url + 'snapslots'
        snappy = Stoarray.new(headers: headers, meth: 'Get', params: params, url: url).snap
        expect(snappy['status']).to eql(400)
      end
    end
  end

  describe ".volume" do
    context "given the wrong url" do
      it "returns a failure code" do
        url = base_url + 'voluum'
        voly = Stoarray.new(headers: headers, meth: 'Get', params: params, url: url).volume
        expect(voly['status']).to eql(400)
      end
    end
  end

end
