#THMediaPlayeCacher
#####核心功能在THMediaCachePalyer文件夹中 , 实现了对网络媒体资源进行边下边播,磁盘缓存网络媒体资源,亮点是可以缓存断点文件(一般主流视频分享app的做法是视频终端下载就不缓存了 , 而本框架可以缓存任意起始点任意长度的媒体文件), 播放音频或视频的碎片文件.

#####同时实现了播放音乐时歌词Y轴滚动,同步X轴颜色填充功能 ,歌单轮播功能 , 及后台播放功能(由于笔者业余时间有限 , 这个功能并没有抽成单独的模块,具体实现在THLrcDisplayView类中,有兴趣的可以看下)

###THMediaPlayeCacher结构
####THMediaPlayer 
对外接口类 , 使用本框架功能只要和这个类交互就够了 , 具体的调用方法都写在demo中一个叫THMusicPlayController的类中.
#####需要给这个类传的参数:
- 播放媒体文件的url
- 播放音乐时的底部控制条的superView
- 播放界面的superView(歌词 , 歌手图片 , 视频窗口需要展示在哪个view上 就是这个参数决定)
- 设置一些底部控制条的按钮回调,都是block属性 ,可以通过这些block属性得到当前播放进度, 控制条上所有按钮及进度条拖动的事件信号

####THMediaDataProvider
为THMediaPlayer提供媒体数据的类, 该类根据播放文件的url调用THMediaDataCacheManager类中的方法,得知本地有没有缓存文件, 有几段 , 是否完整, 如果是片段缓存,应该在哪一段用缓存播放, 哪一段加载网络资源 .

####MediaDataNetDownloadTask 
MediaDataNetDownloadTask是THMediaDataProvider持有的属性 ,  当THMediaDataProvider需要加载网络数据时,就用MediaDataNetDownloadTask开启下载任务 , MediaDataNetDownloadTask实时拼接下载到的数据并写入temp文件夹中的一个临时文件 , 并用代理方法通知THMediaDataProvider接收下载后的数据提供给THMediaPlayer播放,每次task完成时,将这个临时文件合并到缓存中url对应的文件夹中 , 这样可以做到断点数据的缓存 .

####THCoreDataHelper 
coreData操作工具类 , 本框架构建了一个coreData文件用来存储可用的缓存文件的索引值 , 创建日期 ,文件大小等在程序运行过程中必须的缓存文件参数, 这个类直接又下面的THMediaDataCacheManager调用

####THMediaDataCacheManager 
实现断点缓存的核心类 , 不同的媒体文件存在不同的文件夹下 , 文件夹用媒体文件的url的MD5摘要字符串命名 , 相同url下载下来的文件 有这个类合并到对应的文件夹下 , 如果两个断点文件之间有交集, 就由这个类负责将他们拼成一个文件, 并更新索引文件 . 这个类还提供基于urlKey值详细的查询方法 , 可以用url到内存中查找到可用的资源及资源的每段索引范围

###THMediaPlayeCacher运行流程
- THMediaPlayer接收Url参数, 用THMediaDataCacheManager类去缓存中查找有没有可用的媒体文件 :
-  如果有 ,并且是完成文件 , 那么就把url转为file:协议头的本地路径 , 直接播放本地文件 , 这时不会用到THMediaDataProvider和MediaDataNetDownloadTask.
-  如果有 , 但是是片段文件 , 就把url的协议头替换成自定义的其他字符串, 这样AVplayer的urlAsset通过错误的url加载不到数据,就会调用THMediaDataProvider实现的代理方法 , 在这个代理方法中 , 可以通过THMediaDataCacheManager的类方法拿到所有缓存片段文件的range值(这个值表示可用的缓存文件在整个媒体文件中的起始偏移量和长度), 通过写range值,THMediaDataProvider就能知道哪一段数据该通过MediaDataNetDownloadTask去网络下载  ,哪一段数据直接加载本地文件进行播放 , (当然 其中还涉及到了文件类型信息的获取和拼接) ,这样就实现了不完整文件的播放.
-  如果本地没有可用的缓存 , 那么直接让MediaDataNetDownloadTask开启一个下载任务去网络上下载 , 变下边存到沙盒中 , 并且在MediaDataNetDownloadTask的receive data代理方法中通知THMediaDataProvider去指定文件内读取数据提供给avplayer播放

###该项目本身就是个使用THMediaPlayeCacher的Demo , 目前仍有几个不可忽视的bug存在 , 基于笔者时间有限 , 可能尚需不少事日方能完善.