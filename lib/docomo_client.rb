require 'docomoru'
 
class DocomoClient
  def initialize(api_key = nil)
    @api_key = api_key
  end
  
  def chat(message, mode=nil,context=nil)
    client = Docomoru::Client.new(api_key: ENV["DOCOMO_API_KEY"])
    #Docomoruのcreate_daialogueメソッドを実行して返答内容取得
    response = client.create_dialogue(message, { 'mode':mode, 'context':context, 'sex':"男", 'bloodtype':"B" })
 
    return response
  end
end