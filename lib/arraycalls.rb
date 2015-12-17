class Stoarray

  VERBS = {
    'get'    => Net::HTTP::Get,
    'post'   => Net::HTTP::Post,
    'put'    => Net::HTTP::Put,
    'delete' => Net::HTTP::Delete
  }

  def initialize(headers: {}, meth: 'Get', params: {}, url: 'https://array/')
    @url = URI.parse(url) # URL of the call
    @headers = headers
    @call = VERBS[meth.downcase].new(@url.path, initheader = @headers)
    @call.body = params.to_json # Pure and Xtremio expect json parameters
    @request = Net::HTTP.new(@url.host, @url.port)
    @request.read_timeout = 30
    @request.use_ssl = true if @url.to_s =~ /https/
    @request.verify_mode = OpenSSL::SSL::VERIFY_NONE # parameterize?
  end

  def cookie
    @response = @request.start { |http| http.request(@call) }
    all_cookies = @response.get_fields('set-cookie')
    cookies_array = Array.new
    all_cookies.each { | cookie |
      cookies_array.push(cookie.split('; ')[0])
    }
    cookies = cookies_array.join('; ')
  end

  def error_text(method_name, url, wanted)
    response = {
      "response" =>
        "ERROR: Wrong url for the #{method_name} method.\n"\
        "Sent: #{url}\n"\
        "Expected: \"#{wanted}\" as part of the url.",
      "status" => "DORKED!"
    }
  end

  def flippy(temp_hash)
    flippy = temp_hash['to-snapshot-set-id'] + '_347'
    url = 'https://sa0319xms01/api/json/v2/types/snapshot-sets'
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
      response = @request.start { |http| http.request(@call) }
      responder(response)
    else
      error_text("host", @url.to_s, "host")
    end
  end

  def refresh
    case @url.to_s
    when /snapshot/ # Xtremio
      @call.body = flippy(JSON.parse(@call.body)).to_json
    when /volume/ # Pure, handle the interim snap automagically
      # obviously not implemented yet :)
    end
    refreshy = @request.start { |http| http.request(@call) }
    responder(refreshy)
  end

  def responder(response) # combine into one method? with error_text
    response = {
      "response" => JSON.parse(response.body),
      "status" => response.code
    }
  end

  def snap
    if @url.to_s =~ /snapshot/
      response = @request.start { |http| http.request(@call) }
      responder(response)
    else
      error_text("snap", @url.to_s, "snapshot")
    end
  end

  def volume
    if @url.to_s =~ /volume/
      response = @request.start { |http| http.request(@call) }
      responder(response)
    else
      error_text("volume", @url.to_s, "volume")
    end
  end

end
