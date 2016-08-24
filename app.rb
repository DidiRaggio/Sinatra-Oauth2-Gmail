require 'sinatra'
require 'oauth2'
require 'json'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
enable :sessions

# Scopes are space separated strings
SCOPES = [
    'https://mail.google.com/',
    'https://www.googleapis.com/auth/userinfo.email'
].join(' ')


def client
  # if client script run independently, You must specify the G_CLIENT_SECRET and G_CLIENT_ID env veriables
  client ||= OAuth2::Client.new(G_CLIENT_ID, G_CLIENT_SECRET, {
                :site => 'https://accounts.google.com', 
                :authorize_url => "/o/oauth2/auth", 
                :token_url => "/o/oauth2/token"
              })
end

get '/' do
  haml :index
end

get '/clientForm' do
  haml :clientForm
end

post '/clientForm' do

  G_CLIENT_ID = params[:client_id]
  G_CLIENT_SECRET = params[:client_secret]
  File.delete('env.yaml') if File.exist?('env.yaml')
  redirect '/auth'
  
end


get "/auth" do
  redirect client.auth_code.authorize_url(:redirect_uri => redirect_uri,:scope => SCOPES,:access_type => "offline")
end

get '/oauth2callback' do
  access_token = client.auth_code.get_token(params[:code], :redirect_uri => redirect_uri)
  session[:access_token] = access_token.token
  session[:refresh_token] = access_token.refresh_token
  @message = "Successfully authenticated with the server"
  @access_token = session[:access_token]
  @refresh_token = session[:refresh_token]
  
  # parsed is a handy method on an OAuth2::Response object that will 
  # intelligently try and parse the response.body
  @email = access_token.get('https://www.googleapis.com/userinfo/email?alt=json').parsed

  #saved tokens
  env = Hash[ 'client_id' => G_CLIENT_ID, 'client_secret' => G_CLIENT_SECRET, 'access_token' => @access_token, 'refresh_token' => @refresh_token, 'username' => @email["data"]["email"]]
  File.open('env.yaml', 'w') { |fo| fo.puts env.to_yaml }
  haml :success
 
end

def redirect_uri
  uri = URI.parse(request.url)
  uri.path = '/oauth2callback'
  uri.query = nil
  uri.to_s
end


def refresh_the_token( client_id, client_secret, refresh_token)

client = OAuth2::Client.new(client_id, client_secret, {:site => 'https://accounts.google.com', :authorize_url => '/o/oauth2/auth', :token_url => '/o/oauth2/token', :ssl => {:verify => false}})
access_token = OAuth2::AccessToken.from_hash(client, :refresh_token => refresh_token).refresh!

@token = access_token.token


end

get '/gmailForm' do
  haml :gmailForm
end

post '/gmailForm' do
  contents = YAML.load_file('env.yaml')
  @client_id = contents["client_id"]
  @client_secret = contents["client_secret"]
  @refresh_token = contents["refresh_token"]
  @username = contents["username"]
  refresh_the_token( @client_id, @client_secret, @refresh_token)
  @sender = params[:sender]
  @filename = params[:filename]
  gmail_scraper( @username, @token, @sender, @filename)
  haml :gmailSuccess
  
end



def gmail_scraper ( username, token, sender, filename)

  require 'gmail'

  #Log in with oauth2, haven't automated token generation yet.
  Gmail.connect(:xoauth2, username, token) do |gmail|
    
    #Checkes login status
    # puts gmail.logged_in?

    #Goes through emails from specific sender
    # gmail.inbox.emails(:unread, from: "sender@example.com").each do |inbox_email| 
      
    #   puts "gets emails"
    #   puts "INBOX EMAIL: #{inbox_email.message}" 

    # end

    #Saves attachement to specific folder
    folder_path = "scrapes/output" #scrapes/output
    email = gmail.inbox.find(:unread, from: sender).first
    attachment = email.attachments[0]
    File.write(File.join(folder_path, filename), attachment.body.decoded)
      
  end
end



