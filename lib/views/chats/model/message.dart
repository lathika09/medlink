class Message {
  Message({
    required this.toId,
    required this.senderId,
    required this.read,
    required this.type,
    required this.message,
    required this.sent,
  });
  late final String toId;
  late final String senderId;
  late final String read;
  late final Type type;
  late final String message;
  late final String sent;

  Message.fromJson(Map<String, dynamic> json){
    toId = json['toId'].toString();
    senderId = json['senderId'].toString();
    read = json['read'].toString();
    type = json['type'].toString() == Type.image.name ? Type.image : Type.text;
    message = json['message'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['toId'] = toId;
    _data['senderId'] = senderId;
    _data['read'] = read;
    _data['type'] = type.name;
    _data['message'] = message;
    _data['sent'] = sent;
    return _data;
  }
}
//for msg type
enum Type {text,image}