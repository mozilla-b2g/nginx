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
LOCAL_CFLAGS       :=
LOCAL_SRC_FILES    :=
LOCAL_C_INCLUDES   :=
LOCAL_SHARED_LIBRARIES :=
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
