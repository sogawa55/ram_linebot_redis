class LineClient
  #APIを格納
  END_POINT = "https://api.line.me"
　
　#イニシャライザでインスタンス変数に格納
  def initialize(channel_access_token, proxy = nil)
    @channel_access_token = channel_access_token
    @proxy = proxy
  end
　
　#
  def post(path, data)
    #FaradayでAPIを読み込んだオブジェクトを生成
    client = Faraday.new(:url => END_POINT) do |conn|
      conn.request :json
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
      conn.proxy @proxy
    end
    
　　#Faradayのpostメソッドを実行してHTTPリクエストAPIにアクセス
    res = client.post do |request|
      #apiとHTTPリクエストをマージ
      request.url path
      #リクエストヘッダーにアクセストークンを格納
      request.headers = {
        'Content-type' => 'application/json',
        'Authorization' => "Bearer #{@channel_access_token}"
      }
      #リクエストボディに返答内容を格納
      request.body = data
    end
    res
  end
  
  #replyTokenと返答用メッセージをbodyに格納
  def reply(replyToken, text)

    messages = [
      {
        "type" => "text" ,
        "text" => text
      }
    ]

    body = {
      "replyToken" => replyToken ,
      "messages" => messages
    }
    #HTTPリクエストとjson形式に変換したbodyを引数にpostメソッド実行
    post('/v2/bot/message/reply', body.to_json)
  end

end