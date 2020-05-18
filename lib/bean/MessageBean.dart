class MessageBean{



  MessageBean(this.isRead,this.isShowTime,this.msg,this.msgSendState,this.msgSource,this.msgTime,this.msgType);
  ///消息类型
  int msgType;
  ///消息来源
  int msgSource;
  ///消息
  String msg;
  ///消息发送状态
  int msgSendState;
  ///消息时间
  String msgTime;
  ///消息阅读状态
  String isRead;
  ///是否显示时间
  String isShowTime;

  String sendId;

  String receiveId;

}