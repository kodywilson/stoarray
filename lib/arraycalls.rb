class Stoarray

  def initialize(headers: {}, meth: 'Get', params: {}, url: 'https://array/')
    @url = URI.parse(url) # URL of the call
    case # Set verb, default is GET
    when meth=='Delete'
      @call =  Net::HTTP::Delete.new(@url.path, initheader = headers)
    when meth=='Get'
      @call =  Net::HTTP::Get.new(@url.path, initheader = headers)
    when meth=='Post'
      @call =  Net::HTTP::Post.new(@url.path, initheader = headers)
    when meth=='Put'
      @call =  Net::HTTP::Put.new(@url.path, initheader = headers)
    else
      # handle meth=="something else" and Get is safe
      @call =  Net::HTTP::Get.new(@url.path, initheader = headers)
    end
    @call.body = params.to_json # Pure and XMS expect json parameters
    @request = Net::HTTP.new(@url.host, @url.port)
    @request.read_timeout = 30
    @request.use_ssl = true # if @url =~ /https/
    @request.verify_mode = OpenSSL::SSL::VERIFY_NONE # Another parameter?
  end

  def cookie
    @response = @request.start { |http| http.request(@call) }
    # Put cookies in a usable format
    all_cookies = @response.get_fields('set-cookie')
    cookies_array = Array.new
    all_cookies.each { | cookie |
      cookies_array.push(cookie.split('; ')[0])
    }
    cookies = cookies_array.join('; ')
  end

  def host
    # Add some verification that this is a host call
    @response = @request.start { |http| http.request(@call) }
  end

  def volume
    # Add some verification that this is a volume call
    @response = @request.start { |http| http.request(@call) }
  end

end
