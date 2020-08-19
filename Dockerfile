FROM	ubuntu:xenial
ARG	PV_CFLAGS
ARG PV_LFLAGS

RUN	apt-get -y update
RUN	apt-get -y install libpcre3-dev libgeoip-dev libssl-dev make
RUN	apt-get -y install gcc-4.8
RUN	update-alternatives --install /usr/bin/cc cc /usr/bin/gcc-4.8 10
 
# nginx
ADD	vendor/nginx/nginx-1.4.0.tar.gz /
WORKDIR	/nginx-1.4.0
RUN	./configure \
	--with-cc-opt="${PV_CFLAGS}" \
	--with-ld-opt="${PV_LFLAGS}" \
	--with-http_geoip_module \
	--with-http_ssl_module \
	--with-http_gzip_static_module \
	--with-http_stub_status_module \
	--with-http_spdy_module \
	--prefix=/etc/nginx \
	--pid-path=/var/run/nginx.pid \
	--sbin-path=/usr/local/sbin/nginx 

RUN	make install

# Configure nginx with a 100K boilerplate response
WORKDIR	/etc/nginx
COPY	html html
RUN chown www-data html
RUN sed -i -e 's/#user  nobody/user  www-data/g' ./conf/nginx.conf
#RUN	sed -i -e 's/worker_processes  1/worker_processes  4/g' ./conf/nginx.conf

# NGINX listens to port 80 and 443
EXPOSE	80 443

# Entrypoint
ENTRYPOINT nginx -g 'daemon off;'
