title: NGINX+LUA实现简单的灰度发布
date: 2016-06-11 07:28:27
tags:
- NGINX
- LUA
------
感谢国人agentzh，让我们能够以一种更加简单的方式来控制Nginx。即：使用脚本语言LUA来嵌入到Nginx当中来进行编程。

我们一期实现的灰度功能比较简单。原理是通过读取用户请求cookie(如uuid)是否在redis的白名单当中，来让用户定向到不同的Web后端机器。

```lua
-- read cookie & set to ctx.clientUID
local cookieName = ngx.ctx.cookieName
local ck = require "resty.cookie"
local cookie, err = ck:new()
if not cookie then
    -- new resty.cookie failed
    ngx.log(ngx.ERR, "new cookie failed", err)
    ngx.exec("@defaultProxy")
    return
end
local field, err = cookie:get(cookieName)
if not field then
    -- uid is nil
    -- set ngx.ctx.clientUID to nil
    ngx.ctx.clientUID = nil
else
-- uid is not nil
-- set ngx.ctx to field value
    ngx.ctx.clientUID = field
end

-- query the clientUID in redis and decide which upstream to go
local clientUID = ngx.ctx.clientUID
local redisKey = ngx.ctx.redisKey
if not clientUID then
    -- directly upstream to online module
    ngx.exec("@defaultProxy")
else
    -- clientUID is not empty

    function putIntoPool (redCon)
        local ok, err = redCon:set_keepalive(10000, 100)
        if not ok then
            ngx.log(ngx.ERR, "redis set keepalive failed", err)
        end
    end

    function closeCon (redCon)
        local ok, err = redCon:close()
        if not ok then
            ngx.log(ngx.ERR, "close redis connection failed", err)
        end
    end

    -- request redis
    local redis = require "resty.redis"
    local red, err = redis:new()
    red:set_timeout(1000)

    if not red then
       ngx.log(ngx.ERR, "new redis error", err)
       ngx.exec("@defaultProxy")
       return
    end

    -- redis config
    local redisIP = ngx.ctx.redisIP
    local redisPort = ngx.ctx.redisPort
    local ok, err = red:connect(redisIP, redisPort)
    if not ok then
       ngx.log(ngx.ERR, "connect redis error", err)
       ngx.exec("@defaultProxy")
       return
    end
    -- red:sismember(redisKey, clientUID)
    -- if return 1, upstream to gray
    -- else if return 0, upstream to online module
    local isGray, err = red:sismember(redisKey, clientUID)
    if isGray ~= 1 then
        -- put into connection pool
        putIntoPool(red)

        -- not in redis
        if isGray == 0 then
            ngx.log(ngx.ERR, redisKey.." "..clientUID.." is not in gray")
            ngx.exec("@defaultProxy")
        else
            ngx.log(ngx.ERR, " sismember error ", err)
            ngx.exec("@defaultProxy")
        end
        return
    end
    ngx.log(ngx.ERR, redisKey.." "..clientUID.." is in gray")

    -- put into connection pool
    putIntoPool(red)

    -- navigate to grayProxy
    ngx.exec("@grayProxy")
end
```

[查看ppt](http://ppt.dapenggaofei.com/md/introductionToNginxLua.md)
