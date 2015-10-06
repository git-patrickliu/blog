title: 如何科学上网
date: 2015-10-06 07:09:45
tags:
- 科学上网
- APN

---

`科学上网`，真是具有中国特色的一个词汇。但是除非真弄成了大中华局域网，否则又怎么能防止有心的同学不去X外瞧一瞧呢？

想自搭科学上网工具的同学，需要准备以下几个`硬`作案工具。

 1. 国外VPS（如linode）[必选]
 2. 国内中转VPS（如腾讯云，阿里云等）[可选]

如果不需要将socks5转为http请求的话，就不需要国内中转VPS。

### 国外VPS配置[必选]
国外VPS当然可以自由访问国外任何资源。我们要在国外VPS上安装一个Shadowsocks的server端。
```shell
pip install shadowsocks
```
pip是安装python的一个命令。如何安装`pip`，大家可以百度一下。

在安装完`shadowsocks`之后，大家启动shadowsocks的server端。
```shell
sudo ssserver -p [your-port] -k [your-password] -m rc4-md5 -d start
```
上面中的[your-port]，[your-password] 大家可以替换成想要的端口号和自定义的密码。后面的rc4-md5，大家可以用这个加密方式，也可以替换成其他的。但是一定要和后面安装的`shadowsocks`的客户端的加密方式一致。

### 国内VPS配置[可选]
选配一个国内VPS的作用，就是在国内VPS上安装一个`shadowsocks`的客户端，并且使用`privoxy`将socks5转为http协议。这样我们在电脑或手机上使用起来就更加方便了。

#### 1. 安装shadowsocks local
同样使用`pip` 来安装pip。然后再install `shadowsocks`。不过local的启动方式和server是不一样的。

配置一个本地的config.json（如果直拷的话，注释需要去掉）
```json
{
        "server": "[server-ip]", // 第1步当中的server-ip
        "server_port": [server-port], // 第1步当中的server-port
        "local_address":"127.0.0.1", //本地映射IP
        "local_port":1080, // 本地映射IP,可填其他值
        "password":"[server-ssserver-password]",// 第1步当中的password
        "timeout":300,
        "method":"rc4-md5", // 第1步当中的设置的加密方式
        "fast_open":false,
        "workers":1
}
```
然后使用sslocal来启动。
```shell
sslocal config.json
```

这样就完成了一个`sslocal`的启动。

#### 2. 安装privoxy

这一步，我们继续在国内VPS中进行配置，通过privoxy将socks5转成http协议。大家先安装privoxy。
```shell
yum install privoxy // in CentOS
```
在安装完`privoxy`之后，我们编辑`/etc/privoxy/config`
```html
user-manual /usr/share/doc/privoxy/user-manual
confdir /etc/privoxy
logdir /var/log/privoxy
actionsfile match-all.action
actionsfile default.action
actionsfile user.action
filterfile default.filter
filterfile user.filter
logfile logfile
listen-address  :8118  # 转成http之后的监听端口
toggle  1
enable-remote-toggle  0
enable-remote-http-toggle  0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
forwarded-connect-retries  0
accept-intercepted-requests 0
allow-cgi-request-crunching 0
split-large-forms 0
keep-alive-timeout 5
socket-timeout 300
forward-socks5 / 127.0.0.1:1080 .    # 上面sslocal映射的端口
```

然后使用`privoxy` 进行启动。
```shell
/usr/sbin/privoxy --pidfile /var/run/privoxy.pid --user privoxy /etc/privoxy/config
```

到此为止，就设置了一个国内IP:8118的http代理。只要在电脑当中进行设置就可以进行代理了。再编辑一个pac就可以在手机WIFI网络下进行代理上网了。如何使用pac进行代理，大家可以进行搜索。

### 无国内VPS，直连方案

要是没有国内VPS，就需要在本地安装shadowsocks了。可以参考 [这里](http://www.jianshu.com/p/8ca5501ce556)。


### 进阶

上面实现了PC端，手机WIFI端的设置。如果需要在手机蜂窝网络下配置的话，需要使用`APN`技术。

大家下载[iPhone配置工具](http://down.tech.sina.com.cn/content/50517.html)，并且按照中国移动此链接 http://www.sn.10086.cn/iphone/y12.html 进行配置。需要将其IP和端口，换成第二步中设置的IP:port。就可以实现蜂窝网络下的`APN`配置。


## 参考链接

http://tingxueren.com/blog/2014/01/10/jian-yi-http-proxy-da-jian/

http://www.jianshu.com/p/8ca5501ce556

https://www.v2ex.com/t/220006

http://www.sn.10086.cn/iphone/y12.html

