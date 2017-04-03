title: 杜绝cookie污染，一键清空域下所有cookie
date: 2017-02-03 10:13:03
tags: 
- clearAllCookie
---

cookie对前端的重要性不言而喻，而cookie的错乱会影响用户的功能，甚至可能在cookie失效之前一直用不上我们的页面。在PC时代我们还可能去引导用户在浏览器中主动清除一下缓存和cookie, 但是在手机时代，很多时候我们都不清楚去哪里清除缓存和cookie了。所以做一个通用的清空域下的工具就势在必行了。

原因都是最近一直在做微信公众号相关的项目，而在iOS下的微信内嵌页的调试真是灾难级别的。最近就碰到了一件事情，就是测试同学打开微信公众号里我们的内嵌页一直重复授权。原因就是后台设置了正常的登录态，但是微信内嵌页传到服务器的登录态都是空的。导致一直重复授权失败。

这个原因很简单，就是后台在某一次设置登录态（后来也证明确实存在）的时候，设置错了登录态cookie的路径和域名。比如说，我们一般都设置在根域下(52shangchao.com)的，path=/下面。但是某一次设置在了二级域(mp.52shangchao.com)下, path=某一个路径(/froadmall/m/xxxxxx)下面。这样每次访问对应的那个页面，上送的登录态的cookie都有两个值，但是他们的优化级是不一样的。一般情况下更具体的domain+path会具有更高的优先级。这样错设的cookie就有更高的优化级，导致每一次后台校验登录态都是失效的。对于这个问题的处理很简单只要把后台错设的那个cookie值删除就好了。那其实有更多场景我们不知道用户的域下被错设的cookie的pathname和domain是多少。导致我们不能正确删除该cookie值。只能说浏览器还没有提供一个方法可以一次性清除域下的所有cookie。

对于了解这一块的前端同学应该知道，我们种一个cookie需要指定cookie的domain, path和expires时间（如果没有指定会取默认值），而清除cookie也要指定cookie的domain, path和expires(设置为当前时刻之前的时刻就可以了)。但是对于iOS微信这样一个黑盒子，我们是不知道当前的cookie值设置的domain和path值是多少的。通过document.domain获取的也只是有cookie的key和value值而已。

对于设置cookie来说，我们只能在本域或本域的降级域名种cookie, 以及页面pathname的子path设置cookie。所以下面想出了一个清除域下所有ookie的一个思路：

> 1. 通过document.domain取出所有的cookie名

> 2. 我们的页面域名是 *mp.52shangchao.com*,

> 3. 页面有很多比如有 */froadmall/m/home/index*

> 4. 所以上面设置cookie的组合domain x path 有:

>> [52shanghchao.com] x [/, /froadmall, /froadmall/, /froadmall/m, /froadmall/m/, /froadmall/home, /froadmall/home/, /froadmall/home/index]

>> [mp.52shangchao.com] x [/, /froadmall, /froadmall/, /froadmall/m, /froadmall/m/, /froadmall/home, /froadmall/home/, /froadmall/home/index]

下面需要的就是在业务的每一个页面下新建一个虚拟页面，如/froadmall/m/home/index/clearCookieVirtual.html， （这个页面可以在Nginx层直接rewrite到一个公用的页面）,这个页面就负责把指定的域名的上面组合都清空就好了。

在实际操作过程中发现了一个坑，就是以点开头的domain和没有点开头的domain的区别。
![domain](https://dn-dapenggaofei.qbox.me/68995c1bc3be99db35aef63579587b93.png)
在设置cookie的时候，如果没有主动指定域名，就会设置成www.52shangchao.com, 表示这个cookie仅对www.52shangchao.com有效，对x.www.52shangchao.com是无效的。 如果主动指定了www.52shangchao.com的域名，在chrome开发工具当中就会显示出.www.52shangchao.com，表示该cookie不仅对www.52shangchao.com有效，还对x.www.52shangchao.com有效。具体可以查看stackoverflow上的讨论 [unable-to-delete-cookie-from-javascript](http://stackoverflow.com/questions/5688491/unable-to-delete-cookie-from-javascript) && [what-does-the-dot-prefix-in-the-cookie-domain-mean](http://stackoverflow.com/questions/9618217/what-does-the-dot-prefix-in-the-cookie-domain-mean)。这样在清除的时候还必须考虑没有指定domain时的这个特殊情况。


[点击查看demo](http://demo.dapenggaofei.com/clear-all-cookies/example01/clearCookies.html)

