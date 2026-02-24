# SPDX-License-Identifier: MIT
#
# Copyright (C) 2023-2026 Anya Lin <hukk1996@gmail.com>

include $(TOPDIR)/rules.mk

PKG_UPSTREAM_NAME:=natmap
PKG_NAME:=natmapt
PKG_UPSTREAM_VERSION:=20260214
PKG_UPSTREAM_GITHASH:=
PKG_VERSION:=$(PKG_UPSTREAM_VERSION)$(if $(PKG_UPSTREAM_GITHASH),~$(call version_abbrev,$(PKG_UPSTREAM_GITHASH)))
PKG_RELEASE:=1
SCRIPTS_VERSION:=0.2026.01.24

PKG_SOURCE_SUBDIR:=$(PKG_UPSTREAM_NAME)-$(PKG_UPSTREAM_VERSION)
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

ifeq ($(PKG_UPSTREAM_GITHASH),)
PKG_SOURCE_URL:=https://github.com/heiher/natmap/releases/download/$(PKG_UPSTREAM_VERSION)
PKG_HASH:=1562f16b2e222690c32ed6f69d25aa7a59a4319d00d63b1bd4b98010db035159

PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.xz
else
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/heiher/natmap.git
PKG_SOURCE_VERSION:=$(PKG_UPSTREAM_GITHASH)
PKG_MIRROR_HASH:=d1baa9250ce52cb9f0cac05508705ed4fc14a14a0dbece648a1002f9a95d594b

PKG_SOURCE:=$(PKG_SOURCE_SUBDIR)-$(PKG_SOURCE_VERSION).tar.gz
endif

PKG_MAINTAINER:=Anya Lin <hukk1996@gmail.com>, Richard Yu <yurichard3839@gmail.com>, Ray Wang <r@hev.cc>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=License

PKG_USE_MIPS16:=0
PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/natmapt
  SECTION:=net
  CATEGORY:=Network
  TITLE:=TCP/UDP port mapping tool for full cone NAT
  URL:=https://github.com/heiher/natmap
  DEPENDS:=+curl +jq +jsonfilter +bash
endef

MAKE_FLAGS += REV_ID="$(PKG_VERSION)"

define Package/natmapt/conffiles
/etc/config/natmap
endef

define Package/natmapt/prerm
#!/bin/sh
rm -f "$$IPKG_INSTROOT/usr/bin/natmap-curl"
exit 0
endef

define Package/natmapt/install
	$(CURDIR)/.prepare.sh $(VERSION) $(CURDIR) $(PKG_BUILD_DIR)/bin/natmap
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/natmap $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/natmap/
	$(INSTALL_BIN) ./files/natmap-update.sh $(1)/usr/lib/natmap/update.sh
	$(INSTALL_BIN) ./files/common.sh $(1)/usr/lib/natmap/common.sh
	$(INSTALL_DIR) $(1)/etc/config/
	$(INSTALL_CONF) ./files/natmap.config $(1)/etc/config/natmap
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/natmap.init $(1)/etc/init.d/natmap
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/natmap.defaults $(1)/etc/uci-defaults/97_natmap
	$(INSTALL_DIR) $(1)/etc/natmap/client
	$(INSTALL_BIN) ./files/client/qBittorrent $(1)/etc/natmap/client/
	$(LN)          qBittorrent                $(1)/etc/natmap/client/qBittorrent-announce_port
	$(INSTALL_BIN) ./files/client/Transmission $(1)/etc/natmap/client/
	$(INSTALL_BIN) ./files/client/Deluge       $(1)/etc/natmap/client/
	$(INSTALL_DIR) $(1)/etc/natmap/notify
	$(INSTALL_BIN) ./files/notify/ntfy       $(1)/etc/natmap/notify/
	$(INSTALL_BIN) ./files/notify/Pushbullet $(1)/etc/natmap/notify/
	$(INSTALL_BIN) ./files/notify/Pushover   $(1)/etc/natmap/notify/
	$(INSTALL_BIN) ./files/notify/Telegram   $(1)/etc/natmap/notify/
	$(INSTALL_DIR) $(1)/etc/natmap/ddns
	$(INSTALL_BIN) ./files/ddns/Cloudflare $(1)/etc/natmap/ddns/
	$(INSTALL_DIR) $(1)/etc/natmap/tools
	$(INSTALL_BIN) ./files/tools/cf-origin $(1)/etc/natmap/tools/
	$(INSTALL_BIN) ./files/tools/cf-worker $(1)/etc/natmap/tools/
endef

$(eval $(call BuildPackage,natmapt))
