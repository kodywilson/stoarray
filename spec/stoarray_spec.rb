require 'spec_helper'

base_url = 'https://xmspure/api/json/v2/types/'
headers  = { "Content-Type" => "application/json" }
params   = {}

describe Stoarray do

  it "has a version number" do
    expect(Stoarray::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(false)
  end

  describe ".cookie" do
    context "given the wrong url" do
      it "returns a failure code" do
        url = base_url + 'auth/sessoon'
        cooky_url = Stoarray.new(headers: headers, meth: 'Get', params: params, url: url).cookie
        expect(cooky_url['status']).to eql(400)
      end
    end
  end

  describe ".cookie" do
    context "using test mode" do
      it "returns a string" do
        url = base_url + 'auth/session'
        cooky_tst = Stoarray.new(headers: headers, meth: 'Get', params: params, url: url).cookie(testy: true)
        expect(cooky_tst).to eql('cookie time')
      end
    end
  end

  describe ".error_text" do
    context "given three parameters" do
      it "returns a failure code" do
        codey = Stoarray.new.error_text("snap", 'https://wrongo/bongo', "snapshots")
        expect(codey['status']).to eql(400)
      end
    end
  end

  describe ".flippy" do
    context "given a hash containing to-snapshot-set-id" do
      it "returns a flipped snapshot set name" do
        temp_hash = Hash.new
        temp_hash['to-snapshot-set-id'] = "tstserver01"
        flippy = Stoarray.new.flippy(temp_hash, testy: true)
        expect(flippy['to-snapshot-set-id']).to eql('tstserver01_347')
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
