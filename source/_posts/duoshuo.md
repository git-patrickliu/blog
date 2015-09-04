title: 接入多说评论
date: 2015-09-04 17:22:16
tags: 多说
---

我这个blog是基于[hexo](http://hexo.io)构建的，是纯静态html的。所以评论就是一个问题，在网上搜了一下发现[多说](http://dev.duoshuo.com/)，可以实现评论的功能。
多说是通过在你的页面当中内嵌一个多说的JS来实现评论的功能。所以我们需要将多说的JS内嵌到我们的hexo创建的博客当中。

### 1. 多说添加网站
当然，首先我们需要在多说添加一个网站，http://duoshuo.com/create-site/，在此页面添加你自己的网站信息。

### 2. 拷贝通用代码
然后进入对应的管理后台，选择 `工具` -- `获取代码` -- `通用代码`, 然后可以查看到多说需要你在你的页面中插入的代码。

### 3. 修改_config.xml
到hexo你的博客的根目录，在_config.xml里面新增一个变量，如duoshuo_shortname: your-short-name-in-duo-shuo。这个变量名是随便起的，但是要跟下一步对应起来。变量值，是你在第1步当中输入的多说域名。

### 4. 修改主题中评论代码
到hexo当中找到你选用的themes的文件夹，比如我用的是light的主题，则在themes/light/layout/_partial/comment.ejs, 其实不同的主题，对应的文件是不一样的，这一步就需要大家稍微去看一下里面的代码。比如我这边light主题comment.ejs里面其实已经有light主题内置的facebook或disqus评论组件，然并卵，这是一个不存在的网站。
原始代码是：
```javascript
<% if (page.comments){ %>
<section id="comment">
  <h1 class="title"><%= __('comment') %></h1>

  <% if (theme.comment_provider == "facebook") {
      if (theme.facebook) { %>
      <%- partial('_partial/facebook_comment', {fbConfig: theme.facebook}) %>
      <% } %>
  <% } else if(config.disqus_shortname) { %>
  <div id="disqus_thread">
    <noscript>Please enable JavaScript to view the <a href="//disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
  </div>
  <% } %>
</section>
<% } %>
```
在度娘搜示例的时候，里面出现的变量是post，如果二话不说，将代码直接替换，hexo编译的时候会出问题。如[多说官方](http://dev.duoshuo.com/threads/541d3b2b40b5abcd2e4df0e9)提供了这个示例。
```javascript
<% if (!index && post.comments && config.duoshuo_shortname){ %>
  <section id="comments">
    <!-- 多说评论框 start -->
    <div class="ds-thread" data-thread-key="<%= post.layout %>-<%= post.slug %>" data-title="<%= post.title %>" data-url="<%= page.permalink %>"></div>
    <!-- 多说评论框 end -->
    <!-- 多说公共JS代码 start (一个网页只需插入一次) -->
    <script type="text/javascript">
    var duoshuoQuery = {short_name:'<%= config.duoshuo_shortname %>'};
      (function() {
        var ds = document.createElement('script');
        ds.type = 'text/javascript';ds.async = true;
        ds.src = (document.location.protocol == 'https:' ? 'https:' : 'http:') + '//static.duoshuo.com/embed.js';
        ds.charset = 'UTF-8';
        (document.getElementsByTagName('head')[0]
         || document.getElementsByTagName('body')[0]).appendChild(ds);
      })();
      </script>
    <!-- 多说公共JS代码 end -->
  </section>
  <% } %>
```
相信熟悉ejs模板语言的都清楚，如果调用comment.ejs的地方没有传入post参数，则在当前页面不能调用这个值。我们看一下发现在article.ejs当中有调用comment.ejs。最下面一行，`<%- partial('comment') %>`，在页面当中有传入item的值，并且我们简单看了一下item的一些属性值和post有点像，我们大胆地将最后一行改成`<%- partial('comment', { post: item }) %>`，然后运行一下` hexo g `，发现可行。这样就改好了。

其实对于其他类型的themes其实也是一样的。看一下代码改改变量就ok了。
按照之上几步就可以在hexo博客当中插入多说评论。大家有问题欢迎评论。谢谢：)。
