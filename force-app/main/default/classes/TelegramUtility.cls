public class TelegramUtility {
  public static String BOT_KEY = '6173079356:AAFZYGiNAwCR8sEYdO1cD3nXfqH9gsUloGg';

  public static void sendMessage(Message message) {
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    request.setMethod('POST');
    request.setHeader('Content-Type', 'application/json');
    request.setHeader('Accept', 'application/json');
    request.setEndpoint('https://api.telegram.org/bot' + BOT_KEY + '/sendMessage');
    String body = JSON.serialize(Message);
    request.setBody(body);
    HttpResponse response = http.send(request);
  }

  public class Message {
    public String chat_id;
    public String text;

    public Message(String chat_id, String text) {
      this.chat_id = chat_id;
      this.text = text;
    }
  }
}