title:  Velocity会议总结
date: 2015-08-19 19:52:16
tags: velocity
---

关键词：tps优化，前端加载优化，hybrid，APM(application performance monitor）。

1. https优化。
> - HttpDNS, 通过http方式向第三方的固定IP方式来获取指定域名的IP来进行DNS解析[^httpDNS]（我们可以考虑在客户端新增HttpDNS）
> - 启用HSTS[^HSTS] （我们尚未全站启用https，所以这个不太好启动）
> - 启用OCSP Stapling[^OCSP]（可以采用，但需要查看兼容性以及要及时更新签名，以及注意证书链大小）
> - 复用session，减少握手次数
> - 精确设置TLS Record Size，size过小，overhead比重增大，size过大，单record的TCP分段过多
> - TLS硬件加速
> - SPDY/HTTP2.0，可以研究，但近期可能用不上。
> - 配置Forward secrecy cipher 支持False start[^falsestart]  （可以采用，省掉一个RTT时间）
> - 升级openssl版本到最新（我们的版本是openssl-1.0.2c）
> - 确认TLS压缩禁用（nginx 1.3.x以上版本都自动关闭，不关闭有漏洞，我们nginx是1.6.3）
> - 确认SNI支持 （已支持，多个证书部署在同一个IP上）
> - 使用 **//**，来引用静态资源文件，保证http能无缝迁到https环境（我们已经使用了，但是一个360的同僚说在某些地方的移动运营商会将**//** 篡改为 **/**。但是iPhone5s 上海中国移动未发现问题）。
> ![enter image description here](http://7xkybo.com1.z0.glb.clouddn.com/IMG_0612.JPG)

2. 页面直出方法，对比？
> - nginx + lua 页面直出（京东618采用）
> ![enter image description here](http://7xkybo.com1.z0.glb.clouddn.com/IMG_0571.JPG)
> - ATS （apache traffic server）页面直出（Yahoo采用）
> - nodejs直出

3. 前端加载优化
> - ebay优化尝试：DSA（dynamic site accelerate）动态加速，加快页面加载，采用WebP格式优化图片大小（理论能优化到以前60%大小）。
> - composition layer，z-index相同导致的渲染变慢（阿里分享），可查看 [css conf](http://www.w3ctech.com/topic/1463) 360的分享有讨论此问题。

4. hybrid
> - 百度 Blend UI系统架构。通过封装统一JS UI API，如果是在百度app内部的webview，则调用的是原生的UI样式，否则调用的是JS统一的UI样式[^blendUI]
> - Yahoo 采用reactjs + [flux](https://facebook.github.io/flux/)


5. APM
> - 今年的趋势是APM（application performance monitor），赞助商基本都是APM厂商（云智慧，性能魔方，性能极客，OneAPM，野狗等）。
> - 我们正在试用[OneAPM](https://tpm.oneapm.com/tpm/account/717715137/browser/1326753/overview/#/)进行页面加载测试。

#### 总结：

##### 一些方法论：
> - 保持simplicity
> ![enter image description here](http://7xkybo.com1.z0.glb.clouddn.com/IMG_0560.JPG)
> - build high performance team
> ![enter image description here](http://7xkybo.com1.z0.glb.clouddn.com/IMG_0585.JPG)
> - 优化问题方法论
> ![enter image description here](http://7xkybo.com1.z0.glb.clouddn.com/IMG_0616.JPG)


##### 我们暂时能够跟进的：
> - 客户端采用http协议的httpDNS来加速DNS查询，能有效防止之前DNS解析问题。
> - https优化全部跟进，已将dev全部改成TLSv1.2，排期全部改造并上线。
> - CDN动态加速（DSA）咨询，并开启。
> - hybrid现阶段讨论结果是采用PhoneGap。
> - 试用OneAPM跟进数据，然后基于数据进行优化。


##### 一些有用的网站分享：
1. 关于html标准的网站。
> - [specifiction](http://specifiction.wicg.io)|[Discourse](http://discourse.wicg.io) ask question
> - Contribute tests on [testthewebforward](http://testthewebforward.org)
> - [W3 Community](http://www.w3.org/community/wicg)
> - [extensiblewebmanifesto](http://extensiblewebmanifesto.org)
> - [webcomponents](http://webcomponents.org)

2. [SSLLabs](https://ssllabs.com/) 查看你的网站https安不安全
3. [百度https实践](http://op.baidu.com/2015/04/https-s01a01/)

[^httpDNS]: 这种方式可以解释我们之前域名被加黑名单的问题，但是如果又新增加域名，得客户端随时修改，建议通过下发方式来实现新域名prefetch。

[^HSTS]: HTTP Strict Transport Security。我们现在请求http的站点时，会自动跳转到https的页面，其实这一步是存在安全风险的，但是通过HSTS，设置响应头Strict-Transport-Security: max-age=31536000; includeSubDomains，可保证用户即使输入http页面，也在浏览器级别会自动请求https页面，不需要经过服务器跳转。

[^OCSP]: 浏览器在下载服务端的证书之后会向证书发行商验证证书的合法性。因为是向国外网站验证，所以速度慢并存在着失败的可能性。所以可用的做法是在服务器端预先向服务器进行验证，然后打包证书供浏览器下载，这样浏览器就不用再去验证证书的合法性。注意，有效期大概为1个月。详见[网址](https://blog.xjpvictor.info/2013/09/nginx-ocsp-stapling/)。

[^falsestart]: 查看[网址](http://chimera.labs.oreilly.com/books/1230000000545/ch04.html)，啥是false start（抢跑）。

[^blendUI]: 百度blendUI详细如下：
![enter image description here](http://7xkybo.com1.z0.glb.clouddn.com/IMG_0593.JPG)
![enter image description here](http://7xkybo.com1.z0.glb.clouddn.com/IMG_0594.JPG)
![enter image description here](http://7xkybo.com1.z0.glb.clouddn.com/IMG_0595.JPG)
![enter image description here](http://7xkybo.com1.z0.glb.clouddn.com/IMG_0596.JPG)
![enter image description here](http://7xkybo.com1.z0.glb.clouddn.com/IMG_0597.JPG)

