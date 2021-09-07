module UsersHelper
    require 'net/http'

    # Is there a Gravatar for this email? Optionally specify :rating and :timeout.
    def gravatar?(email, options = {})
      hash = Digest::MD5.hexdigest(email.to_s.downcase)
      options = { :rating => 'x', :timeout => 2 }.merge(options)
      http = Net::HTTP.new('www.gravatar.com', 80)
      http.read_timeout = options[:timeout]
      response = http.request_head("/avatar/#{hash}?rating=#{options[:rating]}&default=http://gravatar.com/avatar")
      response.code != '302'
    rescue StandardError, Timeout::Error
      true  # Don't show "no gravatar" if the service is down or slow
    end

    # Returns the Gravatar for the given user.
    def gravatar_for(user, options = { size: 80 })
        size         = options[:size]
        gravatar_id  = Digest::MD5::hexdigest(user.email.downcase)
        gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
        image_tag(gravatar_url, alt: user.name, class: "gravatar")
      end
end