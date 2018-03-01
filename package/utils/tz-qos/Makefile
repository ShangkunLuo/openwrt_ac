
include $(TOPDIR)/rules.mk



PKG_NAME:=tz-qos
PKG_VERSION:=1
PKG_RELEASE:=6






include $(INCLUDE_DIR)/package.mk

define Package/tz-qos
SECTION:=utils
CATEGORY:=Utilities
TITLE:=install tz-qos
endef


define Build/Compile
endef

define Package/tz-qos/description
TZ QOS for AC
endef


define Package/tz-qos/install
	$(INSTALL_DIR) $(1)/usr
	$(CP) ./files/usr/* $(1)/usr
	$(INSTALL_DIR) $(1)/sbin
	$(CP)   ./files/sbin/* $(1)/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(CP) ./files/etc/* $(1)/etc/

endef


$(eval $(call BuildPackage,tz-qos))



