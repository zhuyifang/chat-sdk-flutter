import 'dart:io';
import 'dart:typed_data';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:example/im/friendSelector.dart';
import 'package:example/im/groupSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_online_url.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';
import 'package:universal_html/html.dart' as html;

class SendImageMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SendImageMessageState();
}

class SendImageMessageState extends State<SendImageMessage> {
  Map<String, dynamic>? resData;
  List<String> receiver = List.empty(growable: true);
  List<String> groupID = List.empty(growable: true);
  MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_DEFAULT;
  bool onlineUserOnly = false;
  bool isExcludedFromUnreadCount = false;
  File? image;
  Uint8List? fileContent;
  String? fileName;
  final picker = ImagePicker();
  sendImageMessage() async {
    html.Node? inputElem;
    if (kIsWeb) {
      inputElem = html.document
          .getElementById("__image_picker_web-file-input")
          ?.querySelector("input");
    }

    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createImageMessage(
                imagePath: image!.path, inputElement: inputElem);
    String id = createMessage.data!.id!;

    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendMessage(
            id: id,
            receiver: receiver.length > 0 ? receiver.first : "",
            groupID: groupID.length > 0 ? groupID.first : "",
            priority: priority,
            onlineUserOnly: onlineUserOnly,
            isExcludedFromUnreadCount: isExcludedFromUnreadCount,
            localCustomData: imt("自定义localCustomData(sendImageMessage)"));
    V2TimValueCallback<V2TimMessageOnlineUrl> ddd = await TencentImSDKPlugin
        .v2TIMManager
        .getMessageManager()
        .getMessageOnlineUrl(msgID: res.data!.msgID ?? "");
    V2TimCallback fff = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .downloadMessage(
          msgID: res.data!.msgID ?? "",
          imageType: 0,
          messageType: 1,
          isSnapshot: false,
        );
    print(ddd.toJson());
    setState(() {
      resData = res.toJson();
    });
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    final imageContent = await pickedFile!.readAsBytes();
    final iamgeName = pickedFile.name;
    setState(() {
      image = File(pickedFile.path);
      fileContent = imageContent;
      fileName = iamgeName;
    });
  }

  Widget imageRender() {
    if (kIsWeb) {
      return Image.memory(
        fileContent!,
        width: 40,
        height: 40,
      );
    }
    return Image.file(
      image!,
      width: 40,
      height: 40,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                child: ElevatedButton(
                  onPressed: getImage,
                  child: Text(imt("选择图片")),
                ),
                margin: EdgeInsets.only(right: 12),
              ),
              image == null ? Text(imt(imt("未选择"))) : imageRender(),
            ],
          ),
          Row(
            children: [
              FriendSelector(
                onSelect: (data) {
                  setState(() {
                    receiver = data;
                  });
                },
                switchSelectType: true,
                value: receiver,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                      receiver.length > 0 ? receiver.toString() : imt("未选择")),
                ),
              )
            ],
          ),
          Row(
            children: [
              GroupSelector(
                onSelect: (data) {
                  setState(() {
                    groupID = data;
                  });
                },
                switchSelectType: true,
                value: groupID,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                      groupID.length > 0 ? groupID.toString() : imt("未选择")),
                ),
              )
            ],
          ),
          Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black45,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: ElevatedButton(
                    onPressed: () {
                      showAdaptiveActionSheet(
                        context: context,
                        title: Text(imt("优先级")),
                        actions: <BottomSheetAction>[
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_DEFAULT'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_DEFAULT;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_HIGH'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_HIGH;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_LOW'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_LOW;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_NORMAL'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_NORMAL;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                        cancelAction: CancelAction(
                          title: const Text('Cancel'),
                        ), // onPressed parameter is optional by default will dismiss the ActionSheet
                      );
                    },
                    child: Text(imt("选择优先级")),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: Text("已选：$priority"),
                )
              ],
            ),
          ),
          Row(
            children: [
              Text(imt("是否仅在线用户接受到消息")),
              Switch(
                value: onlineUserOnly,
                onChanged: (res) {
                  setState(() {
                    onlineUserOnly = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Text(imt("发送消息是否不计入未读数")),
              Switch(
                value: isExcludedFromUnreadCount,
                onChanged: (res) {
                  setState(() {
                    isExcludedFromUnreadCount = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: sendImageMessage,
                  child: Text(imt("发送图片消息")),
                ),
              )
            ],
          ),
          SDKResponse(resData),
        ],
      ),
    );
  }
}
