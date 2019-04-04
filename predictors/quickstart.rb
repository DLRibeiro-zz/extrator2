require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'mime'
include MIME

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'Gmail API Ruby Quickstart'.freeze
CREDENTIALS_PATH = 'credentials.json'.freeze
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_SEND

##
# Ensure valid credentials, either by restoring from the saved credentials
# files or intitiating an OAuth2 authorization. If authorization is required,
# the user's default browser will be launched to approve the request.
#
# @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials
def authorize
  client_id = Google::Auth::ClientId.from_file(CREDENTIALS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in the browser and enter the ' \
         "resulting code after authorization:\n" + url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end
  credentials
end

# Initialize the API
service = Google::Apis::GmailV1::GmailService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# Show the user's labels
user_id = 'me'
# result = service.list_user_labels(user_id)
# puts 'Labels:'
# puts 'No labels found' if result.labels.empty?
# result.labels.each { |label| puts "- #{label.name}" }

msg = Mail.new
msg.date = Time.now
msg.subject = "teste"
msg.body = Text.new("teste")
msg.from = "danilo.ribeiro13@gmail.com"
msg.to   = "dlr4@cin.ufpe.br"

message_object = Google::Apis::GmailV1::Message.new(raw:msg.to_s)
service.send_user_message(user_id, message_object)
puts "Email sent"
# @email = @google_api_client.execute(
#     api_method: service.users.messages.to_h['gmail.users.messages.send'],
#     body_object: {
#         raw: Base64.urlsafe_encode64(msg.to_s)
#     },
#     parameters: {
#         userId: 'me',
#     }
# ) 