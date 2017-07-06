class WebhookController < ApplicationController
  # Lineからのcallbackか認証
  protect_from_forgery with: :null_session

  CHANNEL_SECRET = ENV['CHANNEL_SECRET']
  OUTBOUND_PROXY = ENV['OUTBOUND_PROXY']
  CHANNEL_ACCESS_TOKEN = ENV['CHANNEL_ACCESS_TOKEN']

  def callback
    unless is_validate_signature
      render :nothing => true, status: 470
    end
    
    
    event = params["events"][0]
    replyToken = event["replyToken"]
    user_words = event["message"]["text"]
    ram_text  = ""
    
   if /好き||大好き||結婚||可愛い||かわいい||美しい||愛||キレイ||綺麗||キス||すき/ =~ user_words then
      @post = RamPost.offset(rand(RamPost.count)).first
      ram_text = @post.words
    
   elsif /名前||自己紹介||なまえ/ =~ user_words then
      ram_text = "うち、ラムだっちゃ!!"
    
   elsif /浮気||女/ =~ user_words then
     hate_words = ["ダーリンが浮気さえしなければかんしゃくなんかおこさないっちゃっ！","浮気はゆるさないっちゃ!!","うちは、ダーリンの妻だっちゃ!!"]
     index = rand(0..2)
     ram_text = hate_words[index]
    
   else
    docomo_client = DocomoClient.new(api_key: ENV["DOCOMO_API_KEY"])
    
    from = response.body["context"]
    mode = response.body["mode"]
    context = $redis.set('user_id', from)
    lastmode = $redis.set('mode', mode)
    response =  docomo_client.chat(user_words, mode, context)
    context = $redis.set('user_id', response.body["context"])
    lastmode = $redis.set('mode', response.body["mode"])
    
   
    message = response.body['utt'] 
     
    output_text = message.to_s
    mark = ["☆","★","♪"]  
    x = rand(0..4)
    gobi = ["だっちゃ","っちゃ"]
    y = rand(0..1)
    modified_text1 = output_text.gsub(/私/, "うち")
    modified_text2 = modified_text1.gsub(/。|です|ですよ|でした|だね|よね|？/,"")
    ram_text = modified_text2 + gobi[y].to_s + mark[x].to_s
   end
    
    client = LineClient.new(CHANNEL_ACCESS_TOKEN, OUTBOUND_PROXY)
    res = client.reply(replyToken, ram_text)


    if res.status == 200
      logger.info({success: res})
    else
      logger.info({fail: res})
    end

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