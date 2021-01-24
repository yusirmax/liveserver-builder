PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear 
echo -e "\033[34m================================================================\033[0m

                             系统要求: CentOS 6,7
                             一键安装 直播 服务器
                           如果不是请CTRL+C取消安装
		           请保证服务器没有安装过nginx,如有请停止或卸载
                               VERSION:1.0.0

\033[34m================================================================\033[0m"
echo 
read -r -p "回车继续安装, 或者按 Ctrl+C 停止安装"
#  START
cd /tmp
wget https://mirrors.huaweicloud.com/nginx/nginx-1.14.0.tar.gz 
# 解压缩
tar -xvzf ./nginx-1.14.0.tar.gz 
echo "下载解压NGINX完成!"
# 下载nginx-rtmp模块源码
echo "开始下载RTMP模块,可能会有点慢"
wget https://github.com/arut/nginx-rtmp-module/archive/v1.2.1.tar.gz 
# 解压缩
tar -xvzf ./v1.2.1.tar.gz
echo "下载RTMP模块完成!"
mv /tmp/nginx-rtmp-module-1.2.1 /usr/local/nginx-rtmp-module
yum -y install pcre* openssl openssl-devel
echo "依赖安装完成!"
# 创建组&创建不允许登录，无主目录的用户
groupadd nginx
useradd -s /sbin/nologin -g nginx -M nginx
# MAKE
echo "准备开始编译"
cd /tmp/nginx-1.14.0
./configure --user=nginx --group=nginx --prefix=/usr/local/nginx --with-http_stub_status_module --with-http_ssl_module --with-http_gzip_static_module --add-module=/usr/local/nginx-rtmp-module  
make & make install
read -r -p "如果没有报错就回车继续下面提示操作..."
clear 
echo -e "\033[34m================================================================\033[0m

              把nginx.conf放到/usr/local/nginx/conf文件夹
              把video.conf放到/usr/local/nginx/conf/conf.d文件夹
              把index.html放到/usr/local/nginx/html文件夹
			  把88、8888端口开放（可以在conf改88为访问网站端口,8888为推流端口）

\033[34m================================================================\033[0m"
echo 
mkdir /usr/local/nginx/conf/conf.d
mkdir /data
mkdir /data/video
mkdir /data/video/hls
chmod -R 777 /data/video/hls
mkdir /var/log/nginx
cd /var/log/nginx
touch access.log
chmod -R 777 /var/log/nginx/access.log
cd /usr/local/nginx/sbin
./nginx
echo "尝试开放防火墙"
firewall-cmd --add-port=88/tcp --permanent
firewall-cmd --add-port=8888/tcp --permanent
firewall-cmd --add-port=88/udp --permanent
firewall-cmd --add-port=8888/udp --permanent
firewall-cmd --reload
read -r -p "完成...如果提示FirewallD is not running不用理会,按回车继续"
clear
# NEW
echo "----------------------------------------------------------------------------"
echo "[OBS推流]流URL: rtmp://你的地址:端口/hls"
echo "流名称: flv"
echo "----------------------------------------------------------------------------"
echo "启动:先执行 cd /usr/local/nginx/sbin"
echo "再执行 ./nginx"
echo "脚本运行时默认启动nginx"
echo "----------------------------------------------------------------------------"
echo "推流统计地址: http://你的IP:端口/stat"
echo "----------------------------------------------------------------------------"
echo "ALL DONE!!! GOOD LUCK"