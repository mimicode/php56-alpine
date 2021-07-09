FROM arm64v8/php:5.6.40-fpm-alpine
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories \
&& apk update && apk add --no-cache libmcrypt-dev freetype-dev libjpeg-turbo-dev libpng-dev icu-dev \
    && echo "[PHP]\ndate.timezone = PRC\nmax_execution_time = 30\nmax_input_time = 60\nmemory_limit = 128M\nerror_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT\nlog_errors = On\nerror_log = /tmp/php56_error_log.log\nvariables_order = \"GPCS\"\nrequest_order = \"GPC\"\npost_max_size = 128M\nfile_uploads = On\nupload_max_filesize = 128M\nmax_file_uploads = 20" > /usr/local/etc/php/php.ini \
    && echo "[global]\ndaemonize = no\n[www]\nuser = www-data\ngroup = www-data\nlisten = [::]:9056\nlisten.owner = www-data\nlisten.group = www-data\nlisten.mode = 0660\npm = dynamic\npm.max_children = 10\npm.start_servers = 2\npm.min_spare_servers = 1\npm.max_spare_servers = 3" > /usr/local/etc/php-fpm.d/www.conf \
    && docker-php-ext-configure gd --with-freetype --with-jpeg && docker-php-ext-install -j$(nproc) gd \
    && docker-php-ext-configure mcrypt && docker-php-ext-install -j$(nproc) mcrypt pcntl sockets bcmath pdo_mysql mysqli exif intl zip opcache
RUN printf "no\nno\n" | pecl install redis-4.2.0   && docker-php-ext-enable redis \
    && printf "yes\nno\n" | pecl install apcu-4.0.10 && docker-php-ext-enable  apcu \
EXPOSE 9056
CMD ["php-fpm","-c","/usr/local/etc/php/php.ini","-y","/usr/local/etc/php-fpm.d/www.conf"]
