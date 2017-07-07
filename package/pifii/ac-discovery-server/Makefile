include $(TOPDIR)/rules.mk

PKG_NAME:=ac-discovery-server
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)
#PKG_KCONFIG:=RALINK_MT7620 RALINK_MT7621 RALINK_MT7628
#PKG_CONFIG_DEPENDS:=$(foreach c, $(PKG_KCONFIG),$(if $(CONFIG_$c),CONFIG_$(c)))


include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/ac-discovery-server
  SECTION:=pifii
  CATEGORY:=PiFii
  TITLE:=AC discovery server
endef

define Package/ac-discovery-server/description
  An ac-discovery-server program .
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
endef

define Package/ac-discovery-server/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ac-discovery-server $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ac-discovery-server.init $(1)/etc/init.d/ac-discovery-server
endef

$(eval $(call BuildPackage,ac-discovery-server))
