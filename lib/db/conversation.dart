class Conversation {
  final int id ; 
  final int startTime ; 



  Conversation({
    required this.id,
    required this.startTime,
  });


  Map<String, dynamic> toMap() {
    return {
      'conversation_id': id,
      'start_time': startTime,
    };
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['conversation_id'],
      startTime: map['start_time'],
    );
  }
}