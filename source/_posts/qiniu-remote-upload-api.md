title: 七牛base64上传以及远程上传API
date: 2015-09-27 16:03:10
tags:
- 七牛
- remote-upload
- chrome扩展
---

[上一篇](http://blog.dapenggaofei.com/2015/09/17/qiniu-add-to-favourite/) 文章我们讲到了利用七牛API来实现直接在网页上爬图的功能。主要是用到了下面两个API，在官方文档也找了大半天，没找到一个真正能用的例子，这里就将官方例子丰富一下，以便下次使用的时候能查到。

### 1. base64上传
刚开始有做这个chrome扩展的时候，最初就是想着七牛有没有提供base64上传的功能。这样的话，就可以直接将这个功能搞定了，现在想想当时还是太naive。在七牛文档也没搜到base64上传的API，倒是直接在百度搜索的时候搜到了。[前往七牛查看API](http://kb.qiniu.com/5rroxdgb)。发现竟然在知识库，而不在开发者文档专区，也是奇怪。
```javascript
function putb64(){

    var pic = "填写你的base64后的字符串"; // 这里有一个坑，请除去MIME和base64以及逗号
    var url = "http://up.qiniu.com/putb64/20264"; //如果不想计算文件大小，可以改成http://up.qiniu.com/putb64/-1
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange=function(){
        if (xhr.readyState==4){
            document.getElementById("myDiv").innerHTML=xhr.responseText;
        }
    }
    xhr.open("POST", url, true);
    xhr.setRequestHeader("Content-Type", "application/octet-stream");
    xhr.setRequestHeader("Authorization", "UpToken  填写你从服务端获取的上传token"); //UpToken其实有挺多问题
    xhr.send(pic);
}
```
上面是官方给的JS示例，注释是我加的。有着以下几个问题：

1. 传的pic的值，一定要是base64之后去掉MIME前面几个字符，以及base64加逗号那几个字符才是正常传的值。

![base64字符串](http://7xkybo.com1.z0.glb.clouddn.com/qiniu-remote-upload-1.png?v=1)

2. 如果不想算大小的话，比如我，直接在url当中改成-1。
3. 重点来了，UpToken，其算法在[官网](http://developer.qiniu.com/docs/v6/api/reference/security/put-policy.html)写得非常清楚 ，但是呢，我一直在scope里面传`<bucket>:<key>`，一直是返回401，说是授权不合法。后来尝试了一下scope只传`<bucket>`，但是在saveKey当中传想要的key值，才能授权正常，也是醉了。

核心代码如下：
```javascript
 var genUpToken = function(accessKey, secretKey, putPolicy) {

                //SETP 2
                var put_policy = JSON.stringify(putPolicy);

                //SETP 3
                var encoded = base64encode(utf16to8(put_policy));

                //SETP 4
                var hash = CryptoJS.HmacSHA1(encoded, secretKey);
                var encoded_signed = hash.toString(CryptoJS.enc.Base64);

                //SETP 5
                var upload_token = accessKey + ":" + safe64(encoded_signed) + ":" + encoded;

                return upload_token;
            };

var upToken =
                    genUpToken(
                        YOUR-ACCESS-KEY,
                        YOUR-SECRET-KEY,
                        {
                            scope: YOUR-BUCKET,
                            deadline: parseInt(new Date()/1000, 10) + 3600, // 1小时有效期
                            saveKey: YOUR-FILENAME
                        });
```

### 2. 远程上传
我以为用base64就已经没问题了（通过Canvas在线将图片转在base64），但是在百度爬图的时候，却出现了下面的这个安全错误。
> SecurityError: Failed to execute 'toDataURL' on 'HTMLCanvasElement': Tainted canvases may not be exported.

网上查了一下，如果图片没有设置`access-control-allow-origin`，则使用Canvas是不能将其转为base64的。看来单纯用base64解决不了此种情况了，那么便有了下面这个方法。前往 [官方文档](http://developer.qiniu.com/docs/v6/api/reference/rs/fetch.html)。

官方文档其实也是有点坑人的。如下：
```javascript
POST /fetch/<EncodedURL>/to/<EncodedEntryURI> HTTP/1.1
Host:           iovip.qbox.me
Content-Type:   application/x-www-form-urlencoded
Authorization:  QBox <AccessToken>
```

这边`<EncodedEntryURI>`，官方中写着可以为`<bucket>:<key>`，也可以是`<bucket>`，其实后来我测下来，只能是`<bucket>:<key>`，要不然又是401授权失败...

完整代码如下：
```javascript
        var genAccessToken = function(accessKey, secretKey, bucket, srcUrl) {

            var signingStr = "/fetch/" + safe_base64_encode(srcUrl) + "/to/" + safe_base64_encode(bucket + ':' + YOUR-FILENAME) + '\n'; //记得加\n

            var hash = CryptoJS.HmacSHA1(signingStr, secretKey);
            var encoded_signed = hash.toString(CryptoJS.enc.Base64);

            var accessToken = accessKey + ":" + safe64(encoded_signed);

            return accessToken;
        };
 var accessToken =
                    genAccessToken(
                        YOUR-ACCESS-KEY,
                        YOUR-SECRET-KEY,
                        YOUR-BUCKET,
                        IMAGE-URL
                    );

```

有兴趣可以去安装一下[【七牛在线存图】](https://chrome.google.com/webstore/detail/ojgilmgaopbpimndoelnhacamaabdpni)，体验一下在线爬图片的感觉，再也不用担心美图溜走了。[github](https://github.com/git-patrickliu/QINIU-save-online-images)里面有详细的上传代码。


