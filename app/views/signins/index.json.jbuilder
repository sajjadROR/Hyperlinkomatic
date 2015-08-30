json.array!(@signins) do |signin|
  json.extract! signin, :id, :url
  json.url signin_url(signin, format: :json)
end
