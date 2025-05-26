class ChannelModel {
  final int id;
  final int userId0;
  final int userId1;

  ChannelModel({
    required this.id,
    required this.userId0,
    required this.userId1,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: json['id'] as int,
      userId0: json['user_id0'] as int,
      userId1: json['user_id1'] as int,
    );
  }
}
