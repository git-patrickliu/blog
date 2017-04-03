title: 微信内嵌页返回键控制
date: 2017-02-10 18:26:06
tags:
- 返回键控制
- 微信内嵌页
---

### 微信内嵌页的返回键控制

最近我们组一直在做微信公众号相关的产品。在开发过程中，大家对于微信的返回键有着愈来愈多的不满，进而想从技术层面对它进行控制（比如，注册成功页，点击返回不是回到注册页面，而是希望进入用户个人中心页）。

当然直接像原生App一样控制这个返回键是不可能的，因为微信没有开放返回键的JS SDK接口。和同事讨论了一下，决定从H5的history API作为切入点来进行控制。

### 一、api介绍
我们知道H5的history API新增了以下三个方法:
1. pushState
2. replaceState
3. onpopState

下面我们分别对这三个方法进行说明。
1. pushState. 
```javascript
var stateObj = { foo: "bar" };
history.pushState(stateObj, "page 2", "bar.html");
```
假设当前页面url为/foo.html, 执行此方法之后，页面的url会变成/bar.html, 但是页面没有刷新，和之前页面完成一样，页面url却变了， stateObj是用于用户触发popState之后，传给页面使用的数据。"page 2"是设置的页面title。
pushState给history的栈里面push了一个新的项。用户点击返回，会返回到foo.html。

2. replaceState
```javascript
var stateObj = { foo: "bar" };
history.replaceState(stateObj, "page 2", "bar.html");
```
执行此方法之后，页面的url也会变成/bar.html, 和上面不同的是，bar.html替换掉了foo.html, 点击返回不是返回foo.html, 而是返回到foo.html之前的页面。这个replaceState有什么作用呢？我经常使用的场景是这样的：把一个有多tab的页面做成一个单页，但是用户点击不同的tab，我会使用replaceState来修改页面的请求参数值，这样保证用户在其他tab刷新之后，也是定位到当前的tab，而不是每一次刷新都会到第一个tab。当然这个要和后台一起合作，当tab＝X的时候，就返回X对应的数据。

3. onpopstate
```javascript
window.addEventListener("popstate", function(e) {

    var state = e.state,
        url = state && state.url;
    /* do something here */
});
```
MDN上面是这么描述popstate的。
> The popstate event is fired when the active history entry changes. If the history entry being activated was created by a call to history.pushState() or was affected by a call to history.replaceState(), the popstate event's state property contains a copy of the history entry's state object.

也就是说并不是每一次返回都会触发popstate，只有由pushState或是replaceState创建的history entry才会触发这个事件。这一点是需要特别注意的。

### 二、解决方法

在了解完api之后，我们封装了一个统一方法backURL来统一控制微信的history的返回。
```javascript
function backURL(url) {
    if(!url) {
        return;
    }
    
    var currentUrl = window.location.href;
    
    window.history.replaceState({
        url: url
    }, '', url);
    window.history.pushState({}, '', currentUrl);
}

window.addEventListener("popstate", function(e) {

    var state = e.state,
        url = state && state.url;

    if (!url) {
        return;
    }

    window.location.href = url;
});

```
在需要指定返回的时候，只需要调用backURL的方法，就能保证点击微信的系统返回键，会返回到指定的页面。

比如：用户当前在index1.html, 正常点击进入index2.html, 然后我们希望用户在点击返回的时候, 能够返回到index3.html，我们在index2.html中调用了backURL('index3.html'), 此时history中的栈信息为
**['index1.html', 'index3.html', 'index2.html']**。

这样用户在index2.html页面点击返回的时候, 将返回到index3.html, 而不是之前的index1.html页面.

有同学会问，到了index3.html的时候再点击返回，不是又回到了index1.html吗？这种情况怎么解决呢？

针对这种情况，我们在index2.html页面调用backURL方法的时候，传入的是index3.html?backURL=encodeURIComponent(homepage.html?cantGoBack=true)，这样在index3.html中js初始化的时候，发现有传backURL的参数，就再次调用backURL('homepage.html?cantGoBack=true')。到了首页发现有传cantGoBack=true, 就调用backURL传入我们的一个中转页，每次到中转页就自动又跳到当前页面 backURL('urlProxy.html?jumpUri=homepage.html')。这样就首页点击返回就一直都是首页了。[查看示例demo](http://demo.dapenggaofei.com/wechat-return-button/example01/index1.html)

### 三、存在的问题
其实这种方法还存在着一个问题还没有解决。就是我们这一套都是基于JS实现的，如果用户点击过快，还是可以绕过我们设置的障碍，跳到我们不希望用户查看到的页面去了。这个还没有想到比较好的解决方案....

