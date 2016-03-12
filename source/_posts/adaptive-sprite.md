title: 自适应雪碧图
date: 2016-03-12 17:33:47
tags:
- compass
- adaptive
---

说起雪碧图，前端新老司机们应该都不陌生。通过将页面中琐碎的小图合成一张大图，可以减少页面请求数，加快页面加载速度。

但是对于自适应雪碧图，大家可能了解的不多。这里给大家介绍一种可以自适应的雪碧图，就是雪碧图里面的子图可以自适应不同大小的标签。[狠狠点击查看效果](https://jsfiddle.net/dapenggaofei/rjm4ykj2/)。

实现的原理其实也挺简单的，主要是应用了CSS3的 **background-size** 的属性。在用compass合并雪碧图之后，图片的background-position其实都已经算好了，将对应的class放置到我们的标签上，背景图片至少应该出现（或部分出现）在我们的标签之中，现在我们需要的就是通过background-size放大或缩小图片，将我们需要的背景图片放置在标签之中。

那是放大或缩小多少倍呢？下面我们可以看以下一个简略的推导过程（我们只推演宽度的情况，高度是同理的）。
```mathematica
1. 假设合成之后的雪碧图宽是 W1, 需要显示的子图片宽度是 W2, 以子图为背景的标签宽度是 W3，background-size的宽度是x
2. 有公式 x/W3 = W1/W2 => x = W1*W3/W2
3. 所以 background-size 的宽度值为 W1*W3/W2
```

经过上面算出来的background-size正好满足了让子图的正好出现在所需要的标签当中。标签宽度变化，只要更改background-size的值就可以了，而这一些都可以用compass去自动帮大家生成。从而实现了一个自适应的雪碧图。

大家可以去我的github上查看实现的compass的源代码和实例 ([即刻前往](https://github.com/git-patrickliu/responsive-compass-sprite))。


