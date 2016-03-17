class Stoarray

  VERBS = {
    'delete' => :Delete,
    'get'    => :Get,
    'post'   => :Post,
    'put'    => :Put
  }

  def initialize(headers: {}, meth: 'Get', params: {}, url: 'https://array/')
    @headers = headers
    @meth    = meth
    @params  = params
    @url     = url
  end

  def array
    if @url.to_s =~ /array/
      responder(make_call)
    else
      error_text("array", @url.to_s, "array")
    end
  end

  def make_call
    @params = @params.to_json unless @meth.downcase == 'get' || @meth.downcase == 'delete'
    begin
      response = RestClient::Request.execute(headers: @headers,
                                             method: VERBS[@meth.downcase],
                                             payload: @params,
                                             timeout: 30,
                                             url: @url,
                                             verify_ssl: false)
    rescue => e
      e.response
    else
      response
    end
  end

  def cookie
    if @url =~ /auth\/session/
      response = make_call
      raise 'There was an issue getting a cookie!' unless response.code == 200
      cookie = (response.cookies.map{|key,val| key + '=' + val})[0]
    else
      error_text("cookie", @url.to_s, 'auth/session')
    end
  end

  def error_text(method_name, url, wanted)
    response = {
      "response" =>
        "ERROR: Wrong url for the #{method_name} method.\n"\
        "Sent: #{url}\n"\
        "Expected: \"#{wanted}\" as part of the url.",
      "status" => 400
    }
  end

  def flippy(temp_hash)
    # This method is to get around a "feature" of Xtremio where it renames the
    # target snapshot set. We flip between name and name_347. Comprende?
    flippy = temp_hash['to-snapshot-set-id'] + '_347'
    url = 'https://' + URI.parse(@url).host + '/api/json/v2/types/snapshot-sets'
    x = Stoarray.new(headers: @headers, meth: 'Get', params: {}, url: url).snap
    if x['response']['snapshot-sets'].any? { |y| y['name'].include?(flippy) }
      temp_hash['snapshot-set-name']  = temp_hash['to-snapshot-set-id']
      temp_hash['to-snapshot-set-id'] = flippy
    else
      temp_hash['snapshot-set-name']  = flippy
    end
    temp_hash['no-backup'] = true
    temp_hash
  end

  def host
    if @url.to_s =~ /host/
      responder(make_call)
    else
      error_text("host", @url.to_s, "host")
    end
  end

  def pgroup
    if @url.to_s =~ /pgroup/
      responder(make_call)
    else
      error_text("pgroup", @url.to_s, "pgroup")
    end
  end

  def refresh
    case @url.to_s
    when /snapshot/ # Xtremio
      tgt     = @params['to-snapshot-set-id']
      @params = flippy(@params)
      src     = @params['from-consistency-group-id']
      cln     = responder(make_call)
      if cln['status'] == 201
        cln['response'] = 'SUCCESS: Xtremio refresh completed from consistency group ' \
                          + src + ' to snapshot set ' + tgt + '.'
        cln
      else
        cln
      end
    when /1.4/ # Pure, handle the interim snap automagically
      error_state = false
      url     = 'https://' + URI.parse(@url).host + '/api/1.4/pgroup'
      source  = @params['source']
      suffix  = 'interim'
      pam     = { :snap => true, :source => source, :suffix => suffix }
      snap    = Stoarray.new(headers: @headers, meth: 'Post', params: pam, url: url).pgroup
      respond = {
        "response" => {
          "snap" => {
            "response" => snap['response']
          }
        },
        "status" => {
          "snap" => {
            "status" => snap['status']
          }
        }
      }
      if snap['status'] >= 200 && snap['status'] <= 299
        @params['snap_pairs'].each do |key, val|
          tgt = 'clone_' + val # used only for logging!
          src = source[0] + '.' + suffix + '.' + key
          pam = { :overwrite => true, :source => src }
          url = 'https://' + URI.parse(@url).host + '/api/1.4/volume/' + val
          clone = Stoarray.new(headers: @headers, meth: 'Post', params: pam, url: url).volume
          respond['response'][tgt] = {
            "response" => clone['response']
          }
          respond['status'][tgt] = {
            "status" => clone['status']
          }
        end
        url   = 'https://' + URI.parse(@url).host + '/api/1.4/pgroup/' + source[0] + '.' + suffix
        zappy = Stoarray.new(headers: @headers, meth: 'Delete', params: {}, url: url).pgroup
        respond['response']['destroy'] = {
          "response" => zappy['response']
        }
        respond['status']['destroy'] = {
          "status" => zappy['status']
        }
        url = url + '?eradicate=true'
        disintegrate = Stoarray.new(headers: @headers, meth: 'Delete', params: {}, url: url).pgroup
        respond['response']['eradicate'] = {
          "response" => disintegrate['response']
        }
        respond['status']['eradicate'] = {
          "status" => disintegrate['status']
        }
      end
      respond['status'].each do |key, val|
        error_state = true if val.any? { |status, code| code.to_i < 200 || code.to_i > 299 }
      end
      if error_state == true
        respond
      else
        response = {
          "response" =>
            "SUCCESS: Pure refresh completed from #{source[0]} protection group.\n",
          "status" => 201
        }
      end
    else
      error_text("refresh", @url.to_s, "snapshot or 1.4")
    end
  end

  def responder(response)
    response = {
      "response" => JSON.parse(response.body),
      "status" => response.code.to_i
    }
  end

  def snap
    if @url.to_s =~ /snapshot/
      responder(make_call)
    else
      error_text("snap", @url.to_s, "snapshot")
    end
  end

  def volume
    if @url.to_s =~ /volume/
      responder(make_call)
    else
      error_text("volume", @url.to_s, "volume")
    end
  end

end
