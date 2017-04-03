title: 纯前端生成邮件签名图片
date: 2017-04-03 15:35:52
tags:
- dom to canvas
- blob
- saveAs
---

前些天，UED的同学制作了公司统一的邮件签名，并手动帮UED的同学全部给制作了一个精美的签名。非常耗时，要给全公司推广就很麻烦了。所以就建议我们能做一个自动生成的页面。

本着能用JS就绝不用其他语言，能前端就不麻烦后端的思想，我小小预研了一下前端相关的技术。

1. 重构签名图
> 这个对于前端同学就是小菜菜一碟。

2. 将dom转化为一张图片
> [Drawing Dom To Canvas](https://developer.mozilla.org/en-US/docs/Web/API/Canvas_API/Drawing_DOM_objects_into_a_canvas)，可以解决这个问题。因为安全问题，所有的样式和图片都需要内联，这都是小事。样式直接写进style里面，图片转成base64进行内联。

3. 将图片下载到本地
> 1. 用canvas将图转成base64传给后台，让后台生成图片。这个依赖后台，暂时不考虑。
> 2. 使用A链接的H5的新属性：download属性，可以将canvas的内容下载到本地。
![download picture](http://onlineimages.dapenggaofei.com/d35d927d52952f98c4c591db8d136dae.png)

通过上述三步，就可以实现一个纯前端的图片下载 [查看示例](http://demo.dapenggaofei.com/generate-mail-signature-with-pure-fe/example01/index.html)。

------ 
前端一直在不断地发展，愈来愈多的不可能变成了可能。如果在html4的时代，纯前端生成并下载图片就是不可能的事情，但是现在却是可能的。这就需要我们不断地接受新的挑战，并且不断学习新的知识。我之前就不知道A链接新加了一个新属性download, 可以实现下载href指向的dataURI（demo当中是用 [FileSaver.js](https://github.com/eligrey/FileSaver.js/)实现的，下次可以写一个源码解析。）



