# 参考
# https://github.com/cyu/rack-cors
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'localhost:8000','https://fujiya228.com'

    resource "*",
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
