  require 'oauth2'
  require 'gmail'
###############################
#EXECUTABLE FUNCTION, YOU MUST CREATE OAUTH2 TOKENS BEFORE RUNNING

def get_attachment_from( sender_email_address, outputted_file_name )

  if File.exist?('env.yaml')
    contents = YAML.load_file('env.yaml')
    @client_id = contents["client_id"]
    @client_secret = contents["client_secret"]
    @refresh_token = contents["refresh_token"]
    @username = contents["username"]
    # refresh_the_token( @client_id, @client_secret, @refresh_token)
    client = OAuth2::Client.new(@client_id, @client_secret, {:site => 'https://accounts.google.com', :authorize_url => '/o/oauth2/auth', :token_url => '/o/oauth2/token', :ssl => {:verify => false}})
    access_token = OAuth2::AccessToken.from_hash(client, :refresh_token => @refresh_token).refresh!
    @token = access_token.token
    @sender = sender_email_address
    @filename = outputted_file_name

    Gmail.connect(:xoauth2, @username, @token) do |gmail|
    
    #Goes through emails from specific sender
    # gmail.inbox.emails(:unread, from: "sender@example.com").each do |inbox_email| 
      
    #   puts "gets emails"
    #   puts "INBOX EMAIL: #{inbox_email.message}" 

    # end

    #Saves attachement to specific folder
    folder_path = "scrapes/output" #scrapes/output
    email = gmail.inbox.find(:unread, from: @sender).first
    attachment = email.attachments[0]
    File.write(File.join(folder_path, @filename), attachment.body.decoded)
      
    end
  else 
    puts 'you have to create the oauth2 tokens for the email first!'
  end
end

# def refresh_the_token( client_id, client_secret, refresh_token)



# @token = access_token.token


# end