require 'dash/pssh_box'

class LicenseChecker

  POST_BODY  = 'rack.input'.freeze
  KEYS_STORAGE_NAME = 'keys-storage.json'.freeze

  def initialize(app)
    @app = app
  end

  def call(env)
    [
        200,
        {'Content-Type' => 'application/json', 'Access-Control-Allow-Origin' => '*'},
        generate_body(env)
    ]
  end

  private

  def generate_body(env)
    res = env[POST_BODY].read
    return [{}.to_json] unless res.present?

    pssh_box = Dash::PsshBox.read(res)

    mapped_keys = Hash[keys_storage.map { |k, v| [k.gsub('-', ''), v] }]
    jwk_array = pssh_box.kids.inject([]) do |memo, key_id|
      jwk = {
          kty: 'oct',
          alg: 'A128KW',
          kid: [[key_id].pack('H*')].pack('m0').gsub('=', ''),
          k: [[mapped_keys[key_id]].pack('H*')].pack('m0').gsub('=', '')
      }
      memo.push jwk
    end

    [{ keys: jwk_array }.to_json]
  end

  def keys_storage
    @keys_storage ||= JSON.load(
        ENV["KEYS_STORAGE"] || File.open(Rails.root.join(KEYS_STORAGE_NAME)))
  end
end