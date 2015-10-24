require 'optparse'
require 'mechanize'
require 'oauth'
require 'oauth/consumer'

# twicca 
CONSUMER_KEY = '7S2l5rQTuFCj4YJpF7xuTQ'
CONSUMER_SECRET = 'L9VHCXMKBPb2eWjvRvQTOEmOyGlH4W50getaQJPya4'

# Parse Option 
args = {}
OptionParser.new do |parser|
    parser.on('-u', '--username USERNAME'){|v| args[:username] = v}
    parser.on('-p', '--password PASSWORD'){|v| args[:password] = v}
    parser.parse!(ARGV)
end

username = args[:username]
password = args[:password]

agent = Mechanize.new

agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
agent.follow_meta_refresh = true
agent.user_agent = 'Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko'

# Login to Twitter
page = agent.get("https://twitter.com/")

form = page.forms[1]
form["session[username_or_email]"] = username
form["session[password]"] = password
page = form.submit

# Get Request token (use Twitter API)
consumer=OAuth::Consumer.new( CONSUMER_KEY,CONSUMER_SECRET, {
    :site=>"https://api.twitter.com"
})
request_token=consumer.get_request_token
auth_url = request_token.authorize_url

# Open request url
page = agent.get(auth_url).form_with(:id =>'oauth_form').submit 

# Parse PIN code
code = page.at('code').content

# Send PIN code
access_token = request_token.get_access_token(:oauth_verifier => code)

puts access_token.token
puts access_token.secret

