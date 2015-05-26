#!/opt/sensu/embedded/bin/ruby
require 'json'

# RabbitMQ config
rabbitmq_ssl_cert = ENV['RABBITMQ_SSL_CERT'] || '/etc/sensu/ssl/cert.pem'
rabbitmq_ssl_key = ENV['RABBITMQ_SSL_KEY'] || '/etc/sensu/ssl/key.pem'
rabbitmq_host = ENV['RABBITMQ_HOST'] || 'rabbitmq.service.consul'
rabbitmq_port = ENV['RABBITMQ_PORT'] || 5671
rabbitmq_vhost = ENV['RABBITMQ_VHOST'] || '/sensu'
rabbitmq_user = ENV['RABBITMQ_USER'] || 'sensu'
rabbitmq_password = ENV['RABBITMQ_PASSWORD'] || 'sensu'

# Sensu client config
sensu_name = ENV['SENSU_NAME'] || 'default_client'
sensu_address = ENV['SENSU_ADDRESS'] || '127.0.0.1'

sensu_subscriptions = [ 'all' ]

# Read subscriptions from ENV 
if ENV['SENSU_SUBSCRIPTIONS']
  sensu_subscriptions = ENV['SENSU_SUBSCRIPTIONS'].split(":")
end

client_config = {
	"rabbitmq" => {
		"ssl" => {
			"cert_chain_file" => rabbitmq_ssl_cert,
			"private_key_file" => rabbitmq_ssl_key
		},
		"host" => rabbitmq_host,
		"port" => rabbitmq_port,
		"vhost" => rabbitmq_vhost,
		"user" => rabbitmq_user,
		"password" => rabbitmq_password
	},
	"client" => {
		"name" => sensu_name,
		"address" => sensu_address,
		"subscriptions" => sensu_subscriptions
	}
}

# puts JSON.pretty_generate(client_config)

# Write the config file
File.open("/etc/sensu/client.json","w") do |f|
  f.write(JSON.pretty_generate(client_config))
end
