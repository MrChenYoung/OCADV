//
//  APIMacro.h
//  OCADV
//
//  Created by MrChen on 2018/12/26.
//  Copyright © 2018 MrChen. All rights reserved.
//

#ifndef APIMacro_h
#define APIMacro_h

// 服务端ip和端口号
#define SERVERIP @"10.226.104.241"
//#define SERVERIP @"192.168.0.103"
#define SERVERPORT 6969

// 查询手机号码url
#define checkPhoneNumberUrl @"https://tcc.taobao.com/cc/json/mobile_tel_segment.htm"

// 获取微信公众平台accessToken url
#define GetAccessTokenUrl @"https://api.weixin.qq.com/cgi-bin/token"

// 上传永久素材url
#define UploadLongTimeFileUrl @"https://api.weixin.qq.com/cgi-bin/material/add_material"

// 获取永久素材素材列表
#define GetImageListUrl @"https://api.weixin.qq.com/cgi-bin/material/batchget_material"

// 删除永久素材url
#define DeleteImageUrl @"https://api.weixin.qq.com/cgi-bin/material/del_material"

// 获取微信服务器上的永久图片
#define GetImageUrl @"https://api.weixin.qq.com/cgi-bin/media/get"


#endif /* APIMacro_h */
