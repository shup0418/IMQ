(function ($) {
    $.fn.screenshotPaste=function(options){
        var me = this;

        if(typeof options =='string'){
            var method = $.fn.screenshotPaste.methods[options];

            if (method) {
                return method();
            } else {
                return;
            }
        }

        var defaults = {
            imgContainer: '',  //预览图片的容器
            imgHeight:200    //预览图片的默认高度
        };

        options = $.extend(defaults,options);
        var imgReader = function( item ){
            var file = item.getAsFile();
            var reader = new FileReader();

            reader.readAsDataURL( file );
            reader.onload = function( e ){
                var img = new Image();

                img.src = e.target.result;
                img.name = "pic";

                $(img).css({ height:"auto" ,"max-height":defaults.imgHeight});
                $(document).find(options.imgContainer)
                    .html('')
                    .show()
                    .append(img);
            };
        };
        //事件注册
        $(me).bind('paste',function(e){
            var clipboardData = e.originalEvent.clipboardData;
            var items, item, types;

            if( clipboardData ){
                items = clipboardData.items;

                if( !items ){
                    return;
                }

                item = items[0];
                types = clipboardData.types || [];

                for(var i=0 ; i < types.length; i++ ){
                    if( types[i] === 'Files' ){
                        item = items[i];
                        break;
                    }
                }

                if( item && item.kind === 'file' && item.type.match(/^image\//i) ){
                    imgReader( item );
                }
            }
        });

        $.fn.screenshotPaste.methods = {
            getImgData: function () {
                var src = $(document).find(options.imgContainer).find('img').attr('src');

                if(src==undefined){
                    src='';
                }

                return src;
            }
        };
    };
})(jQuery);