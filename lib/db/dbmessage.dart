class DbMessage {
  final int? id ; 
  final int conversationId ;
  final String senderId ; 
  final String text ; 
  final int timestamp ;


  DbMessage({
    this.id,
    required this.conversationId,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message_text': text,
      'timestamp': timestamp,
    };
  }

  factory DbMessage.fromMap(Map<String, dynamic> map) {
    return DbMessage(
      id: map['id'],
      conversationId: map['conversation_id'],
      senderId: map['sender_id'],
      text: map['message_text'],
      timestamp: map['timestamp'],
    );
  }

}