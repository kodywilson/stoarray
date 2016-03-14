class Stoarray

  VERBS = {
    'post'   => Net::HTTP::Post,
    'put'    => Net::HTTP::Put
  }

  def initialize(headers: {}, meth: 'Get', params: {}, url: 'https://array/')
    @headers = headers
    @meth    = meth
    @params  = params
    @url     = url
  end

  def array
    if @url.to_s =~ /array/
      responder(verbal_gerbil)
    else
      error_text("array", @url.to_s, "array")
    end
  end

  def cally
    @url = URI.parse(@url) # URL of the call
    @call = VERBS[@meth.downcase].new(@url.path, initheader = @headers)
    @call.body = @params.to_json # Pure and Xtremio expect json parameters
    @request = Net::HTTP.new(@url.host, @url.port)
    @request.read_timeout = 30
    @request.use_ssl = true if @url.to_s =~ /https/
    @request.verify_mode = OpenSSL::SSL::VERIFY_NONE # parameterize?
    response = @request.start { |http| http.request(@call) }
  end

  def cookie(testy: false)
    if @url.to_s =~ /auth\/session/
      case testy
      when false
        response = verbal_gerbil
        all_cookies = response.get_fields('set-cookie')
      when true
        all_cookies = ['cookie time']
      end
      cookies_array = Array.new
      all_cookies.each { | cookie |
        cookies_array.push(cookie.split('; ')[0])
      }
      cookies = cookies_array.join('; ')
    else
      error_text("cookie", @url.to_s, 'auth/session')
    end
  end

  def dl33t
    response = RestClient::Request.execute(headers: @headers, method: :delete, url: @url, verify_ssl: false)
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
    # Normally I would let the code document itself, however...
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

  def getty
    response = RestClient::Request.execute(headers: @headers, method: :get, url: @url, verify_ssl: false)
  end

  def host
    if @url.to_s =~ /host/
      responder(verbal_gerbil)
    else
      error_text("host", @url.to_s, "host")
    end
  end

  def pgroup
    if @url.to_s =~ /pgroup/
      responder(verbal_gerbil)
    else
      error_text("pgroup", @url.to_s, "pgroup")
    end
  end

  def refresh
    case @url.to_s
    when /snapshot/ # Xtremio
      @params = flippy(@params)
      responder(verbal_gerbil)
    when /1.4/ # Pure, handle the interim snap automagically
      error_state = false
      url     = 'https://' + URI.parse(@url).host + '/api/1.4/pgroup'
      source  = @params['source']
      suffix  = 'interim_snap'
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
        pam   = { :eradicate => true }
        disintegrate = Stoarray.new(headers: @headers, meth: 'Delete', params: pam, url: url).pgroup
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
            "SUCCESS: Refresh completed for #{source[0]} protection group.\n",
          "status" => 201
        }
      end
    else
      error_text("refresh", @url.to_s, "snapshot or 1.4")
    end
  end

  def responder(response) # combine into one method? with error_text
    response = {
      "response" => JSON.parse(response.body),
      "status" => response.code.to_i
    }
  end

  def snap
    if @url.to_s =~ /snapshot/
      responder(verbal_gerbil)
    else
      error_text("snap", @url.to_s, "snapshot")
    end
  end

  def verbal_gerbil
    case @meth.downcase
    when 'delete'
      verby = dl33t
    when 'get'
      verby = getty
    else
      verby = cally
    end
  end

  def volume
    if @url.to_s =~ /volume/
      responder(verbal_gerbil)
    else
      error_text("volume", @url.to_s, "volume")
    end
  end

end
