class Api::LicenseController < Api::ApiController
  skip_before_filter :restrict_access, only: [:get]

  KEYS_STORAGE_NAME = 'keys-storage.json'

  def get
    key_ids = request.query_string.split('&').inject(Hash.new { |h, k| h[k] = [] }) do |memo, s|
      arr = s.split('=')
      memo[arr[0]].push arr[1]
      memo
    end

    mapped_keys = Hash[keys_storage.map { |k, v| [k.gsub('=', ''), v] }]
    key_ids
    jwk_array = key_ids['keyid'].inject([]) do |memo, key_id|
      jwk = {
          kty: 'oct',
          alg: 'A128GCM',
          kid: [[key_id].pack('H*')].pack('m0').gsub('=', ''),
          k: [[mapped_keys[key_id]].pack('H*')].pack('m0').gsub('=', '')
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