<%--
  Created by IntelliJ IDEA.
  User: shup
  Date: 2017/6/26
  Time: 15:29
  To change this template use File | Settings | File Templates.
--%>
<!DOCTYPE HTML>
<%@ page language="java" import="java.util.*" pageEncoding="UTF-8" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + path + "/";
    String homeId = request.getParameter("homeId");
    String name = request.getParameter("name");
%>
<html>
<head>
    <base href="<%=basePath%>">
    <title>webSocket</title>
    <script type="text/javascript" src="js/jquery_2.0.3_min.js" charset="utf-8"></script>
    <script type="text/javascript" src="js/screenshot-paste.js" charset="utf-8"></script>
</head>
<style>
    #close{
        background:url(img/close.png) no-repeat;
        width:30px;
        height:30px;
        cursor:pointer;
        position:absolute;
        right:5px;
        top:5px;
        text-indent:-999em;
    }
    #mask{
        background-color:#ccc;
        opacity:0.7;
        filter: alpha(opacity=70);
        position:absolute;
        left:0;
        top:0;
        z-index:1000;
    }
    #login{
        position:fixed;
        z-index:1001;
    }
    .loginCon{
        position:relative;
        width:670px;
        height:380px;
        background:lightblue;
        border:3px solid #333;
        text-align: center;
    }
</style>

<body style="height: 100%" onload="bind()">
    <div id="message" style="width: 500px;overflow-y:auto;overflow-x:auto;"></div>
    <textarea id="text" style="resize:none;width: 360px;height: 90px"></textarea>
    <button onclick="send()">Send</button>
    <button onclick="closeWebSocket()">Close</button>
    <div id="imgPreview" style="width: auto;height: auto;max-width: 200px;max-height: 150px; margin-top:10px;display:none;"></div>
</body>
<script>
    $('#text').screenshotPaste({
        imgContainer: '#imgPreview'
    });
</script>

<script type="text/JavaScript">
    //网页当前状态判断
    var hidden, state, visibilityChange;
    if (typeof document.hidden !== "undefined") {
        hidden = "hidden";
        visibilityChange = "visibilitychange";
        state = "visibilityState";
    } else if (typeof document.mozHidden !== "undefined") {
        hidden = "mozHidden";
        visibilityChange = "mozvisibilitychange";
        state = "mozVisibilityState";
    } else if (typeof document.msHidden !== "undefined") {
        hidden = "msHidden";
        visibilityChange = "msvisibilitychange";
        state = "msVisibilityState";
    } else if (typeof document.webkitHidden !== "undefined") {
        hidden = "webkitHidden";
        visibilityChange = "webkitvisibilitychange";
        state = "webkitVisibilityState";
    }

    var websocket = null;
    var longImgVal = "";
    var flag = 0;

    //判断当前浏览器是否支持WebSocket
    if ('WebSocket' in window) {
        websocket = new WebSocket("ws://<%=basePath.substring(basePath.indexOf("//"))%>chat/<%=homeId %>");
    }
    else {
        alert('Not support websocket');
    }

    //连接发生错误的回调方法
    websocket.onerror = function () {
        setMessageInnerHTML("error");
    };

    //连接成功建立的回调方法
    websocket.onopen = function (event) {
        setMessageInnerHTML("连接成功");
    };

    //接收到消息的回调方法
    websocket.onmessage = function () {
        if (event.data == "#pv$1start"){
            flag = 1;
            return;
        } else if(event.data == "#pv$1end"){
            flag = 0;
            setMessageInnerHTML(longImgVal);
            document.getElementById('message').scrollTop = document.getElementById('message').scrollHeight;
            var imgBtn=document.getElementsByTagName("img");
            $("[name='pic']").attr("onClick","dialog(this)");

            longImgVal = "";
            if(document[state] == "hidden") message.show();
            return;
        }

        if (flag == 1)
        {
            longImgVal += event.data;
        } else {
            setMessageInnerHTML(event.data);
            // 设置滚动条滚动到最底
            document.getElementById('message').scrollTop = document.getElementById('message').scrollHeight;
        }
        if(document[state] == "hidden") message.show();
    };

    //连接关闭的回调方法
    websocket.onclose = function () {
        setMessageInnerHTML("关闭成功");
    };

    //监听窗口关闭事件，当窗口关闭时，主动去关闭websocket连接，防止连接还没断开就关闭窗口，server端会抛异常。
    window.onbeforeunload = function () {
        websocket.close();
    };

    //将消息显示在网页上
    function setMessageInnerHTML(innerHTML) {
        document.getElementById('message').innerHTML += innerHTML + '<br/>';
    }

    //关闭连接
    function closeWebSocket() {
        websocket.close();
    }

    //发送消息
    function send() {
        var imgVal = document.getElementById("imgPreview").innerHTML;
        if (imgVal != "" && imgVal != null) {
            if(imgVal.length > 8000)
            {
                websocket.send("#pv$1start");
                var imgValArray = new Array();
                var imgVals = '';
                for (var i = 0,len = imgVal.length / 8000;i < len; i++)
                {
                    imgVals = imgVal.substring(0,8000);
                    imgVal = imgVal.replace(imgVals,"");
                    websocket.send(imgVals);
                    imgValArray[i] = imgVals;
                }
                var imgVals = imgVal;
                websocket.send("#pv$1end");
            }
            websocket.send("<%=name%>:" + imgVal);
            document.getElementById("imgPreview").innerHTML = "";
        }

        var message = document.getElementById('text').value;
        if (message == null || message == "") return;
        websocket.send("<%=name%>:" + message);
        document.getElementById('text').value = ""; // 清空输入框
    }

    // Ctrl + 回车发送
    document.onkeydown = function (e) {
        var message = document.getElementById('text').value;
        // 回车查询
        var ae = (typeof event != 'undefined') ? window.event : e;
        if (event.ctrlKey && ae.keyCode == 13 && message != null && message != "") {
            send();
        }
    }

    // 弹出图片
    function dialog(obj){
        //获取页面的高度和宽度
        var sWidth=document.body.scrollWidth || document.documentElement.scrollWidth;
        var sHeight=document.body.scrollHeight || document.documentElement.scrollHeight;

        //获取页面的可视区域高度和宽度
        var wHeight=document.documentElement.clientHeight || document.body.clientHeight;

        //创建遮罩层
        var oMask=document.createElement("div");
        oMask.id="mask";
        oMask.style.height=sHeight+"px";
        oMask.style.width=sWidth+"px";
        document.body.appendChild(oMask);            //添加到body末尾

        //创建登录框
        var oLogin=document.createElement("div");
        oLogin.id="login";
        oLogin.innerHTML="<img src='" + obj.currentSrc  + "'> ";
        document.body.appendChild(oLogin);

        //获取登陆框的宽和高
        var dHeight=oLogin.offsetHeight;
        var dWidth=oLogin.offsetWidth;

        //设置登陆框的left和top
        oLogin.style.left=sWidth/2-dWidth/2+"px";
        oLogin.style.top=wHeight/2-dHeight/2+"px";

        //获取关闭按钮
        var oClose=document.getElementById("close");

        //点击关闭按钮和点击登陆框以外的区域都可以关闭登陆框
        oClose.onclick=oMask.onclick=function(){
            document.body.removeChild(oLogin);
            document.body.removeChild(oMask);
        };
    }

    // 使用message对象封装消息
    var message = {
        time: 0,
        title: document.title,
        timer: null,
        // 显示新消息提示
        show: function () {
            var title = message.title.replace("【　　　】", "").replace("【新消息】", "");
            // 定时器，设置消息切换频率闪烁效果就此产生
            message.timer = setTimeout(function () {
                message.time++;
                message.show();
                if (message.time % 2 == 0) {
                    document.title = "【新消息】" + title
                }

                else {
                    document.title = "【　　　】" + title
                };
            }, 600);
            return [message.timer, message.title];
        },
        // 取消新消息提示
        clear: function () {
            clearTimeout(message.timer);
            document.title = message.title;
        }
    };

    // 页面加载时绑定点击事件，单击取消闪烁提示
    function bind() {
        document.onclick = function () {
            message.clear();
        };
    }
</script>
</html>