require 'spec_helper'

xtrm_url = 'https://demo7139290.mockable.io/api/json/v2/types/'
pure_url = 'https://demo7139290.mockable.io/api/1.4/'
headers  = { "Content-Type" => "application/json" }
params   = {}

describe Stoarray do

  it "has a version number" do
    expect(Stoarray::VERSION).not_to be nil
  end

  describe ".array" do
    context "given the wrong url" do
      it "returns a failure code" do
        url = pure_url + 'uhrray'
        arrr = Stoarray.new(headers: headers, meth: 'Get', params: params, url: url).array
        expect(arrr['status']).to eql(400)
      end
    end
  end

  describe ".array" do
    context "when asked for the array name" do
      it "returns the array name" do
        url = pure_url + 'array'
        array_name = Stoarray.new(headers: headers, meth: 'Get', params: {}, url: url).array
        expect(array_name['status']).to eql(200)
      end
    end
  end

  describe ".cookie" do
    context "given the wrong url" do
      it "returns a failure code" do
        url = pure_url + 'auth/sessoon'
        cooky_url = Stoarray.new(headers: headers, meth: 'Get', params: params, url: url).cookie
        expect(cooky_url['status']).to eql(400)
      end
    end
  end

  describe ".cookie" do
    context "using test mode" do
      it "returns a string" do
        url = pure_url + 'auth/session'
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
        url = xtrm_url + 'snapshot-sets'
        flippy = Stoarray.new(headers: headers, url: url).flippy(temp_hash)
        expect(flippy['snapshot-set-name']).to eql('tstserver01_347')
      end
    end
  end

  describe ".flippy" do
    context "given a hash containing to-snapshot-set-id" do
      it "returns a flipped snapshot set name" do
        temp_hash = Hash.new
        temp_hash['to-snapshot-set-id'] = "tstserver02"
        url = xtrm_url + 'snapshot-sets'
        flippy = Stoarray.new(headers: headers, url: url).flippy(temp_hash)
        expect(flippy['to-snapshot-set-id']).to eql('tstserver02_347')
      end
    end
  end

  describe ".host" do
    context "given the wrong url" do
      it "returns a failure code" do
        url = pure_url + 'hast'
        hosty = Stoarray.new(headers: headers, meth: 'Get', params: params, url: url).host
        expect(hosty['status']).to eql(400)
      end
    end
  end

  describe ".host" do
    context "when asked to change a host name" do
      it "returns a 200 on success" do
        url = pure_url + 'host/purehost01'
        hosty = Stoarray.new(headers: headers, meth: 'Put', params: { "name" => "purehost02" }, url: url).host
        expect(hosty['status']).to eql(200)
      end
    end
  end

  describe ".pgroup" do
    context "given the wrong url" do
      it "returns a failure code" do
        url = pure_url + 'pgruop'
        pdaddy = Stoarray.new(headers: headers, meth: 'Get', params: params, url: url).pgroup
        expect(pdaddy['status']).to eql(400)
      end
    end
  end

  describe ".pgroup" do
    context "when asked to snapshot a pgroup" do
      it "returns a 201 on success" do
        params = { :snap => true, :source => 'purevolprd', :suffix => 'interim_snap' }
        url = pure_url + 'pgroup'
        pdaddy = Stoarray.new(headers: headers, meth: 'Post', params: params, url: url).pgroup
        expect(pdaddy['status']).to eql(201)
      end
    end
  end

  describe ".refresh" do
    context "given the wrong url" do
      it "returns a failure code" do
        url = xtrm_url + 'sillyputty'
        refreshy = Stoarray.new(headers: headers, meth: 'Get', params: params, url: url).refresh
        expect(refreshy['status']).to eql(400)
      end
    end
  end

  describe ".refresh" do
    context "asked to refresh an Xtremio snapshot set" do
      it "returns a 201 on success" do
        url = xtrm_url + 'snapshots'
        params = { "from-consistency-group-id" => "prdserver01",
                   "to-snapshot-set-id" => "tstserver01" }
        refreshy = Stoarray.new(headers: headers, meth: 'Post', params: params, url: url).refresh
        expect(refreshy['status']).to eql(201)
      end
    end
  end

  describe ".refresh" do
    context "asked to refresh a Pure clone set" do
      it "returns a 201 on success" do
        url = pure_url
        params = { "snap_pairs" => {
                   "purevol_1_src" => "purevol_1_des"
                  },
                  "source" => ["purevolprd"]
                  }
        refreshy = Stoarray.new(headers: headers, meth: 'Post', params: params, url: url).refresh
        expect(refreshy['status']).to eql(201)
      end
    end
  end

  describe ".refresh" do
    context "asked to refresh a Pure clone set" do
      it "returns status 400 on failure" do
        url = pure_url
        params = { "snap_pairs" => {
                   "purevol_1_src" => "purevol_2_des"
                  },
                  "source" => ["purevolprd"]
                  }
        refreshy = Stoarray.new(headers: headers, meth: 'Post', params: params, url: url).refresh
        expect(refreshy['status']['clone_purevol_2_des']['status']).to eql(404)
      end
    end
  end

  describe ".snap" do
    context "given the wrong url" do
      it "returns a failure code" do
        url = xtrm_url + 'snapslots'
        snappy = Stoarray.new(headers: headers, meth: 'Get', params: {}, url: url).snap
        expect(snappy['status']).to eql(400)
      end
    end
  end

  describe ".snap" do
    context "when asked to show snapshot sets" do
      it "returns a 200 on success" do
        url = xtrm_url + 'snapshot-sets'
        snappy = Stoarray.new(headers: headers, meth: 'Get', params: {}, url: url).snap
        expect(snappy['status']).to eql(200)
      end
    end
  end

  describe ".snap" do
    context "when asked to show snapshot sets" do
      it "displays the snapshot sets on the array" do
        url = xtrm_url + 'snapshot-sets'
        snappy = Stoarray.new(headers: headers, meth: 'Get', params: {}, url: url).snap
        x = snappy['response']['snapshot-sets'].any? { |y| y['name'].include?('tstserver01') }
        expect(x).to eql(true)
      end
    end
  end

  describe ".volume" do
    context "given the wrong url" do
      it "returns a failure code" do
        url = xtrm_url + 'voluum'
        voly = Stoarray.new(headers: headers, meth: 'Get', params: {}, url: url).volume
        expect(voly['status']).to eql(400)
      end
    end
  end

  describe ".volume" do
    context "when asked to create a new volume" do
      it "returns a 201 on success" do
        url = pure_url + 'volume/newpurevol01'
        voly = Stoarray.new(headers: headers, meth: 'Post', params: { "size" => "5G" }, url: url).volume
        expect(voly['status']).to eql(201)
      end
    end
  end

end
