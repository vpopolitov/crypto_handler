class Api::LicenseController < Api::ApiController
  skip_before_filter :restrict_access, only: [:manifest, :map, :token]

  def get
    keys = {
        '390eb73a2b0143faa4f036466c073e81' => '3a2a1b68dd2bd9b2eeb25e84c4776668',
        '3c9592caac1c4bda86b4a747367c4113' => '07e4d653cfb45c66158d93ffce422907'
    }

    key_ids = request.query_string.split('&').inject(Hash.new { |h, k| h[k] = [] }) do |memo, s|
      arr = s.split('=')
      memo[arr[0]].push arr[1]
      memo
    end

    mapped_keys = Hash[keys.map { |k, v| [k.gsub('=', ''), v] }]
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
end