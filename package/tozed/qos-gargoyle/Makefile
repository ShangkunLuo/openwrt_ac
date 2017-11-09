include $(TOPDIR)/rules.mk

PKG_NAME:=qos-gargoyle
PKG_RELEASE:=1.0

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/qos-gargoyle
    SECTION:=net
    CATEGORY:=Network
    TITLE:=A set of QoS scripts designed for use with Gargoyle Web Interface
    DEPENDS:=+tc +iptables-mod-filter +iptables-mod-imq
    VERSION:=$(PKG_RELEASE)
endef

define Package/qos-gargoyle/description
    A set of QoS scripts designed for use with Gargoyle Web Interface
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/qos-gargoyle/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/config

	$(INSTALL_BIN) ./files/qos.init $(1)/etc/init.d/qos
	$(INSTALL_DATA) ./files/qos_gargoyle.conf $(1)/etc/config/qos_gargoyle
endef

$(eval $(call BuildPackage,qos-gargoyle))
