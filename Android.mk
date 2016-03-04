LOCAL_PATH := $(call my-dir)

# This is the code to bootstrap a Nginx config build for a device
ifeq ($(BOOTSTRAP_NGINX),true)
nginx_LOCAL_PATH := $(LOCAL_PATH)

include $(CLEAR_VARS)
LOCAL_MODULE       := nginx
LOCAL_MODULE_CLASS := DATA
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_PATH  := $(TARGET_OUT)
include $(BUILD_PREBUILT)

nginx_CFLAGS := $(filter-out -I build/core/combo/include/arch/linux-$(TARGET_ARCH)/,$(filter-out -include build/core/combo/include/arch/linux-$(TARGET_ARCH)/AndroidConfig.h,$(TARGET_GLOBAL_CFLAGS)))
nginx_CFLAGS += $(addprefix -I../../,$(TARGET_C_INCLUDES))
# to not use deprecated RSA_generate_key() (non existent in libcrypto)
nginx_CFLAGS += -DOPENSSL_NO_DEPRECATED
nginx_CFLAGS += -I../../external/openssl/include
nginx_CFLAGS += -I../../external/zlib
# nginx_CFLAGS += $(abspath $(TARGET_CRTBEGIN_DYNAMIC_O))
# nginx_CFLAGS += $(TARGET_GLOBAL_CFLAGS)

nginx_LDFLAGS := $(TARGET_GLOBAL_LDFLAGS)
nginx_LDFLAGS += -L../../$(TARGET_OUT_INTERMEDIATE_LIBRARIES)
nginx_LDFLAGS += -Wl,-rpath-link=../../$(TARGET_OUT_INTERMEDIATE_LIBRARIES)
# nginx_LDFLAGS += $(abspath $(TARGET_CRTEND_O))

nginx_configure_CFLAGS := $(nginx_CFLAGS)
# nginx_configure_CFLAGS += $(abspath $(TARGET_CRTBEGIN_DYNAMIC_O) $(TARGET_CRTEND_O))
nginx_configure_CFLAGS += $(nginx_LDFLAGS)
# nginx_configure_CLFAGS += $(TARGET_GLOBAL_LDFLAGS)

nginx_TOOLCHAIN := $(subst $(ANDROID_BUILD_TOP),../..,$(ANDROID_TOOLCHAIN))

.PHONY: $(LOCAL_BUILT_MODULE)
$(LOCAL_BUILT_MODULE): $(TARGET_CRTBEGIN_DYNAMIC_O) $(TARGET_CRTEND_O)
	cp $(TARGET_CRTBEGIN_DYNAMIC_O) $(nginx_LOCAL_PATH)  && \
	cp $(TARGET_CRTEND_O) $(nginx_LOCAL_PATH) && \
	cd $(nginx_LOCAL_PATH) && test -x auto/configure && \
	CFLAGS="$(nginx_CFLAGS)" CC_TEST_FLAGS="$(nginx_configure_CFLAGS)" \
	auto/configure \
			--crossbuild=android-$(TARGET_ARCH) \
			--user=root --group=root \
			--prefix=/system/nginx \
			--conf-path=/etc/nginx/nginx.conf \
			--sbin-path=/system/bin/nginx \
			--error-log-path=/tmp/nginx-error.log \
			--http-log-path=/tmp/nginx-access.log \
			--pid-path=/tmp/nginx.pid \
			--lock-path=/tmp/nginx.lock \
			--http-client-body-temp-path=/tmp/nginx_client_body_temp \
			--with-cc=$(nginx_TOOLCHAIN)/arm-linux-androideabi-gcc \
			--with-cpp=$(nginx_TOOLCHAIN)/arm-linux-androideabi-cpp \
			--with-ld-opt="$(nginx_LDFLAGS)" \
			--with-ipv6 \
			--with-http_ssl_module \
			--with-http_v2_module \
			--without-pcre \
			--without-http_auth_basic_module \
			--without-http_fastcgi_module \
			--without-http_memcached_module \
			--without-http_limit_conn_module \
			--without-http_limit_req_module \
			--without-http_empty_gif_module \
			--without-http_proxy_module \
			--without-http_rewrite_module \
			--without-http_scgi_module \
			--without-http_ssi_module \
			--without-http_upstream_hash_module \
			--without-http_upstream_ip_hash_module \
			--without-http_upstream_least_conn_module \
			--without-http_upstream_keepalive_module \
			--without-http_upstream_zone_module \
			--without-http_uwsgi_module \
			--without-stream_upstream_hash_module \
			--without-stream_upstream_least_conn_module \
			--without-stream_upstream_zone_module && \
	cd ../../ && make -C $(nginx_LOCAL_PATH)
else
# Here we just build as a normal package
include $(CLEAR_VARS)
LOCAL_MODULE       := nginx
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_CFLAGS       := -DOPENSSL_NO_DEPRECATED
LOCAL_SRC_FILES    := src/core/nginx.c \
	src/core/ngx_log.c \
	src/core/ngx_palloc.c \
	src/core/ngx_array.c \
	src/core/ngx_list.c \
	src/core/ngx_hash.c \
	src/core/ngx_buf.c \
	src/core/ngx_queue.c \
	src/core/ngx_output_chain.c \
	src/core/ngx_string.c \
	src/core/ngx_parse.c \
	src/core/ngx_parse_time.c \
	src/core/ngx_inet.c \
	src/core/ngx_file.c \
	src/core/ngx_crc32.c \
	src/core/ngx_murmurhash.c \
	src/core/ngx_md5.c \
	src/core/ngx_rbtree.c \
	src/core/ngx_radix_tree.c \
	src/core/ngx_slab.c \
	src/core/ngx_times.c \
	src/core/ngx_shmtx.c \
	src/core/ngx_connection.c \
	src/core/ngx_cycle.c \
	src/core/ngx_spinlock.c \
	src/core/ngx_rwlock.c \
	src/core/ngx_cpuinfo.c \
	src/core/ngx_conf_file.c \
	src/core/ngx_module.c \
	src/core/ngx_resolver.c \
	src/core/ngx_open_file_cache.c \
	src/core/ngx_crypt.c \
	src/core/ngx_proxy_protocol.c \
	src/core/ngx_syslog.c \
	src/event/ngx_event.c \
	src/event/ngx_event_timer.c \
	src/event/ngx_event_posted.c \
	src/event/ngx_event_accept.c \
	src/event/ngx_event_connect.c \
	src/event/ngx_event_pipe.c \
	src/os/unix/ngx_time.c \
	src/os/unix/ngx_errno.c \
	src/os/unix/ngx_alloc.c \
	src/os/unix/ngx_files.c \
	src/os/unix/ngx_socket.c \
	src/os/unix/ngx_recv.c \
	src/os/unix/ngx_readv_chain.c \
	src/os/unix/ngx_udp_recv.c \
	src/os/unix/ngx_send.c \
	src/os/unix/ngx_writev_chain.c \
	src/os/unix/ngx_channel.c \
	src/os/unix/ngx_shmem.c \
	src/os/unix/ngx_process.c \
	src/os/unix/ngx_daemon.c \
	src/os/unix/ngx_setaffinity.c \
	src/os/unix/ngx_setproctitle.c \
	src/os/unix/ngx_posix_init.c \
	src/os/unix/ngx_user.c \
	src/os/unix/ngx_dlopen.c \
	src/os/unix/ngx_process_cycle.c \
	src/core/glob.c \
	src/event/modules/ngx_select_module.c \
	src/event/modules/ngx_poll_module.c \
	src/event/ngx_event_openssl.c \
	src/event/ngx_event_openssl_stapling.c \
	src/http/ngx_http.c \
	src/http/ngx_http_core_module.c \
	src/http/ngx_http_special_response.c \
	src/http/ngx_http_request.c \
	src/http/ngx_http_parse.c \
	src/http/modules/ngx_http_log_module.c \
	src/http/ngx_http_request_body.c \
	src/http/ngx_http_variables.c \
	src/http/ngx_http_script.c \
	src/http/ngx_http_upstream.c \
	src/http/ngx_http_upstream_round_robin.c \
	src/http/ngx_http_file_cache.c \
	src/http/ngx_http_write_filter_module.c \
	src/http/ngx_http_header_filter_module.c \
	src/http/modules/ngx_http_chunked_filter_module.c \
	src/http/v2/ngx_http_v2_filter_module.c \
	src/http/modules/ngx_http_range_filter_module.c \
	src/http/modules/ngx_http_gzip_filter_module.c \
	src/http/modules/ngx_http_charset_filter_module.c \
	src/http/modules/ngx_http_userid_filter_module.c \
	src/http/modules/ngx_http_headers_filter_module.c \
	src/http/ngx_http_copy_filter_module.c \
	src/http/modules/ngx_http_not_modified_filter_module.c \
	src/http/v2/ngx_http_v2.c \
	src/http/v2/ngx_http_v2_table.c \
	src/http/v2/ngx_http_v2_huff_decode.c \
	src/http/v2/ngx_http_v2_huff_encode.c \
	src/http/v2/ngx_http_v2_module.c \
	src/http/modules/ngx_http_static_module.c \
	src/http/modules/ngx_http_autoindex_module.c \
	src/http/modules/ngx_http_index_module.c \
	src/http/modules/ngx_http_access_module.c \
	src/http/modules/ngx_http_geo_module.c \
	src/http/modules/ngx_http_map_module.c \
	src/http/modules/ngx_http_split_clients_module.c \
	src/http/modules/ngx_http_referer_module.c \
	src/http/modules/ngx_http_ssl_module.c \
	src/http/modules/ngx_http_browser_module.c \
	objs/ngx_modules.c
LOCAL_C_INCLUDES := $(LOCAL_PATH)/src/core \
	$(LOCAL_PATH)/src/event \
	$(LOCAL_PATH)/src/event/modules \
	$(LOCAL_PATH)/src/os/unix \
	$(LOCAL_PATH)/objs \
	$(LOCAL_PATH)/src/http \
	$(LOCAL_PATH)/src/http/modules \
	$(LOCAL_PATH)/src/http/v2 \
	external/openssl/include \
	external/zlib/src
LOCAL_SHARED_LIBRARIES := libdl liblog libz libcrypto libssl
include $(BUILD_EXECUTABLE)

include $(CLEAR_VARS)
LOCAL_MODULE       := nginx/nginx.conf
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := conf/nginx.conf
LOCAL_MODULE_PATH  := $(TARGET_OUT_ETC)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := nginx/mime.types
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_SRC_FILES    := conf/mime.types
LOCAL_MODULE_PATH  := $(TARGET_OUT_ETC)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := nginx/html/index.html
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := DATA
LOCAL_SRC_FILES    := docs/html/index.html
LOCAL_MODULE_PATH  := $(TARGET_OUT)
include $(BUILD_PREBUILT)

include $(CLEAR_VARS)
LOCAL_MODULE       := nginx/html/50x.html
LOCAL_MODULE_TAGS  := optional
LOCAL_MODULE_CLASS := DATA
LOCAL_SRC_FILES    := docs/html/50x.html
LOCAL_MODULE_PATH  := $(TARGET_OUT)
include $(BUILD_PREBUILT)

endif # BOOTSTRAP_NGINX,true
