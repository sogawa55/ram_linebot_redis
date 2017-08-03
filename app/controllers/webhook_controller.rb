class WebhookController < ApplicationController
  # Lineからのcallbackか認証
  protect_from_forgery with: :null_session
  #環境変数の設定
  CHANNEL_SECRET = ENV['CHANNEL_SECRET']
  OUTBOUND_PROXY = ENV['OUTBOUND_PROXY']
  CHANNEL_ACCESS_TOKEN = ENV['CHANNEL_ACCESS_TOKEN']
　#メッセージが送信されるとcallback関数が実行される
  def callback
    unless is_validate_signature
    　#エラーがあれば何も表示しない
      render :nothing => true, status: 470
    end
    
    #リクエストのタイプを取得
    event = params["events"][0]
    #リクエストに含まれるreplyTokenを格納
    replyToken = event["replyToken"]
    #ユーザーのメッセージ内容を格納
    user_words = event["message"]["text"]
    ram_text  = ""
    
    #メッセージ内容に応じて条件分岐
    if user_words =~ /好き|すき|結婚|可愛い|かわいい|綺麗|キレイ|美しい|キス|愛|あい|美人/ then 
      index = rand(1..11)
      ram_post = RamPost.find(index)
      ram_text = ram_post.words
    
    elsif user_words =~ /名前|自己紹介|なまえ/ then
      ram_text = "うち、ラムだっちゃ!!"
      
    elsif user_words =~ /浮気|女/ then
      hate_words = ["マジメな顔してどーせ女のこと考えてるっちゃ！","浮気はゆるさないっちゃ!!","ダーリンが浮気さえしなければかんしゃくなんかおこさないっちゃっ！"]
      index = rand(0..2)
      ram_text = hate_words[index]
      
    elsif user_words =~ /ピカチュウ|ぴか|ピカ/ then
      pika_words = ["ぴ、ぴかちゅう～","10万ボルトだちゃ!"] 
      index = rand(0..1)
      ram_text = pika_words[index]
    else
    #環境変数に格納したAPIキーを引数にDocomoClientをインスタンス化
    docomo_client = DocomoClient.new(api_key: ENV["DOCOMO_API_KEY"])
    
    #前回のコンテクストを取り出し格納
    from = response.body["context"]
    #前回の会話モードを取り出し格納
    mode = response.body["mode"]
    #Redisにキーとセットでコンテクストを格納
    context = $redis.set('user_id', from)
    #Redisにキーとセットで会話モードを格納
    lastmode = $redis.set('mode', mode)
    #ユーザーのメッセージとRedisに保存したmode,contextを引数にして返答データを取得
    response =  docomo_client.chat(user_words, lastmode, context)
    #取得した返答データに含まれるcontextとmodeの値をRedisに保存
    context = $redis.set('user_id', response.body["context"])
    lastmode = $redis.set('mode', response.body["mode"])
    
    #返答メッセージを格納
    message = response.body['utt'] 
    output_text = message.to_s
    mark = ["☆","★","♪"]  
    x = rand(0..4)
    gobi = ["だっちゃ","っちゃ"]
    y = rand(0..1)
    #正規表現を用いて語尾を調整
    modified_text1 = output_text.gsub(/私/, "うち")
    modified_text2 = modified_text1.gsub(/。|です|ですよ|でした|だね|よね|？/,"")
    ram_text = modified_text2 + gobi[y].to_s + mark[x].to_s
    end
    
    #LINEクライアントのインスタンス化
    client = LineClient.new(CHANNEL_ACCESS_TOKEN, OUTBOUND_PROXY)
    #返答メッセージを引数にreplyメソッドを実行
    res = client.reply(replyToken, ram_text)
    
    #replyメソッドのステータスチェック
    if res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end
    #何も出力しない
    render :nothing => true, status: :ok
  end


  private
  # verify access from LINE
  def is_validate_signature
    signature = request.headers["X-LINE-Signature"]
    http_request_body = request.raw_post
    hash = OpenSSL::HMAC::digest(OpenSSL::Digest::SHA256.new, CHANNEL_SECRET, http_request_body)
    signature_answer = Base64.strict_encode64(hash)
    signature == signature_answer
  end
end