class Message {
  final int _id = DateTime.now().microsecondsSinceEpoch;
  final String data;

  Message(this.data);
}
