module ArticlesHelper

require 'uri'
require 'open-uri'
require 'net/http'
require 'openssl'

    def resolveUrl(url, agent = 'curl/7.43.0', max_attempts = 4, timeout = 6)
        attempts = 0
        cookie = nil

        until attempts >= max_attempts
            attempts += 1
            uri = URI.parse(url)
            http = Net::HTTP.new(uri.host, uri.port)
            http.open_timeout = timeout
            http.read_timeout = timeout
            #path = uri.path
            #path = '/' if path == ''
            #path += '?' + uri.query unless uri.query.nil?

            params = { 'User-Agent' => agent, 'Accept' => '*/*' }
            params['Cookie'] = cookie unless cookie.nil?

            if uri.instance_of?(URI::HTTPS)
                http.use_ssl = true
                http.verify_mode = OpenSSL::SSL::VERIFY_NONE
            end

            request = Net::HTTP::Head.new(uri, params)
            response = http.request(request).header

        case response
            when Net::HTTPSuccess then
                response['uri'] = uri
                return response
                break
            when Net::HTTPRedirection then
                location = response['Location']
                cookie = response['Set-Cookie']
                new_uri = URI.parse(location)
                uri_str = if new_uri.relative?
                    uri + location
                else
                    new_uri.to_s
                end
            else
                raise 'Unexpected response: ' + response.inspect
        end

    end
    raise 'Too many http redirects' if attempts == max_attempts
  end
end
