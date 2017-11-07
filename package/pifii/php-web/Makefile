include $(TOPDIR)/rules.mk

PKG_NAME:=php-web
PKG_VERSION:=1.0.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).zip
#PKG_SOURCE_URL:=@GNU/$(PKG_NAME)
#PKG_MD5SUM:=c52d65fdee0712af6f77eb2b60974ac7
#PKG_MAINTAINER:=<iweb.dl.sourceforge.net>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/php-web
  SECTION:=pifii
  CATEGORY:=PiFii
  TITLE:=php-web
  DEPENDS:=+php7 +nginx +mysql-server
endef

define Package/php-web/install
	$(INSTALL_DIR) $(1)/etc/nginx
	$(CP) $(PKG_BUILD_DIR)/nginx/* $(1)/etc/nginx/
	$(INSTALL_DIR) $(1)/etc
	$(CP) $(PKG_BUILD_DIR)/php/* $(1)/etc/
	$(INSTALL_DIR) $(1)/www2
	$(CP) $(PKG_BUILD_DIR)/www2/ac_m5 $(1)/www2/
	$(INSTALL_DIR) $(1)/etc/config/mysql/mysql
	$(CP) $(PKG_BUILD_DIR)/mysql_data/* $(1)/etc/config/mysql/mysql/
endef
$(eval $(call BuildPackage,php-web))
