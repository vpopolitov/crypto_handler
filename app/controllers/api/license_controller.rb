class Api::LicenseController < Api::ApiController
  skip_before_filter :restrict_access, only: [:post]

  KEYS_STORAGE_NAME = 'keys-storage.json'

  def post
    mapped_keys = Hash[keys_storage.map { |k, v| [k.gsub('-', ''), v] }]
    kids = params['kids'].map do |kid|
      Base64.decode64(kid.gsub('-', '+').gsub('_', '/')).unpack('H*').first
    end

    jwk_array = kids.inject([]) do |memo, key_id|
      jwk = {
          kty: 'oct',
          alg: 'A128KW',
          kid: [[key_id].pack('H*')].pack('m0').gsub('=', '').gsub('+', '-').gsub('/', '_'),
          k: [[mapped_keys[key_id]].pack('H*')].pack('m0').gsub('=', '').gsub('+', '-').gsub('/', '_')
      }
      memo.push jwk
    end

    render json: { keys: jwk_array }, status: :ok
  end

  private

  def keys_storage
    @keys_storage ||= JSON.load(
        ENV["KEYS_STORAGE"] || File.open(Rails.root.join(KEYS_STORAGE_NAME)))
  end
end