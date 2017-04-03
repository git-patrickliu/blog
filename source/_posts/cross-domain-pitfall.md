title: 跨域调用之iOS safari坑
date: 2017-04-03 10:17:37
tags: 
- cross domain
- ios
- safari
---

跨域调用对于前端来说真是老生常谈的一件事情, 最经常使用的场景比如是, 调用第三方支付, 第三方支付成功之后需要将状态再传回到主页面上来.

跨域调用有好几种方法，在这里我们不讨论。只讨论直接通过调用 **top.func** 的方式。

一般情况，我们会在主页面上iframe内嵌第三方web支付的页面，第三方支付在成功之后回调一个我们给他们的中间页面url, 我们的页面再通过top && top.successCallback() 将成功/失败状态回传给我们的主页面。按说一般都没有问题，但是我们的中间页面因为要给公司里的不同域名的好几个业务公用，所以代码就写成下面这样
```javascript
try {
    if(top && top.successCallback) {
         top.successCallback(xxxxxx);
    } else {
        top.postMessage(xxxxxxx);
    }
} catch(e) {
    top.postMessage(xxxxx);
}
```

按说一切都没有问题，也考虑足够全面。但是iOS下的微信却
但是在iOS下的微信执行逻辑却有问题。google了一下，发现是iOS对于跨域直接访问**top && top.func** 并不会抛出异常。[点击查看详情](http://stackoverflow.com/questions/28241940/safari-not-catching-exception-when-trying-to-access-parent-window-object-with-ja)。

解决方案如下：
```javascript
try {
	if (top && top.document) {
		if (top.successCallback) {
			top.kamiPayCallback(xxxxxx);
		} else {
		
	} else {
		// iPhone http://stackoverflow.com/questions/28241940/safari-not-catching-exception-when-trying-to-access-parent-window-object-with-ja
		top.postMessage(xxxxxx);
	}
} catch(e) {
	top.postMessage(xxxxxx);
}
```
增加 **top && top.document** 来判断是否是iOS内嵌页。

