-- --------------------------------------------------------
-- 主机:                           172.16.1.1
-- 服务器版本:                        5.1.73 - Source distribution
-- 服务器操作系统:                      openwrt-linux-gnu
-- HeidiSQL 版本:                  9.4.0.5174
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- 导出 ac_m 的数据库结构
CREATE DATABASE IF NOT EXISTS `ac_m` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `ac_m`;

-- 导出  表 ac_m.pi_admin 结构
CREATE TABLE IF NOT EXISTS `pi_admin` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(50) NOT NULL DEFAULT '',
  `password` varchar(50) NOT NULL DEFAULT '',
  `salt` varchar(50) NOT NULL DEFAULT '',
  `power` text NOT NULL,
  `shop` text NOT NULL,
  `restrict` varchar(50) NOT NULL DEFAULT '',
  `add_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_admin 的数据：1 rows
/*!40000 ALTER TABLE `pi_admin` DISABLE KEYS */;
INSERT INTO `pi_admin` (`id`, `username`, `password`, `salt`, `power`, `shop`, `restrict`, `add_time`) VALUES
	(1, 'admin', 'a374debf5f64c0d93e372d7e511c2b2d', '5941f639355a0', '', '', '', 0);
/*!40000 ALTER TABLE `pi_admin` ENABLE KEYS */;

-- 导出  表 ac_m.pi_ap 结构
CREATE TABLE IF NOT EXISTS `pi_ap` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `mac` varchar(100) NOT NULL DEFAULT '' COMMENT 'MAC地址',
  `ap_name` varchar(100) NOT NULL DEFAULT '' COMMENT 'AP名称',
  `ip` varchar(100) NOT NULL DEFAULT '' COMMENT 'IP地址',
  `is_2g` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '有2.4G无线',
  `is_5g` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '有5G无线',
  `model` varchar(100) NOT NULL DEFAULT '0' COMMENT 'AP型号',
  `firmware_version` varchar(100) NOT NULL DEFAULT '0' COMMENT '固件版本',
  `cpu` int(11) NOT NULL DEFAULT '0' COMMENT 'CPU使用率',
  `ram_free` int(11) NOT NULL DEFAULT '0' COMMENT '内存剩余',
  `run_time` int(11) NOT NULL DEFAULT '0' COMMENT '运行时间',
  `location` varchar(200) NOT NULL DEFAULT '' COMMENT '所在位置',
  `group_id` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '归属组',
  `telnet_account` varchar(100) NOT NULL DEFAULT '' COMMENT 'Telnet管理账号',
  `telnet_password` varchar(100) NOT NULL DEFAULT '' COMMENT 'Telnet管理密码',
  `online_users` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '在线用户数',
  `flow_in` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '网络流量下载',
  `flow_out` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '网络流量上传',
  `signal` int(10) NOT NULL DEFAULT '0' COMMENT 'AP的信号强度',
  `status` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '当前状态：0.不在线 1.在线',
  `act_sign` varchar(50) NOT NULL DEFAULT '' COMMENT 'AP确认标识',
  `act_reboot` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '重启AP：1.重启，AP端接收后置0。',
  `act_reset` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '重置AP：1.重置，AP端接收后置0。',
  `act_setwifi` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '设置Wifi：1.设置，AP端接收后置0。',
  `act_upgrade` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '更新固件：1.更新，AP端接收后置0。',
  `heartbeat_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最后的连线时间',
  `add_time` int(10) unsigned NOT NULL DEFAULT '0',
  `config_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '配置变更时间，影响AP配置的要更新此时间',
  PRIMARY KEY (`id`),
  KEY `mac` (`mac`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_ap 的数据：0 rows
/*!40000 ALTER TABLE `pi_ap` DISABLE KEYS */;
/*!40000 ALTER TABLE `pi_ap` ENABLE KEYS */;

-- 导出  表 ac_m.pi_ap_group 结构
CREATE TABLE IF NOT EXISTS `pi_ap_group` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `group_name` varchar(100) NOT NULL DEFAULT '' COMMENT 'AP组名称',
  `add_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `group_name` (`group_name`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=utf8 COMMENT='AP的分组';

-- 正在导出表  ac_m.pi_ap_group 的数据：1 rows
/*!40000 ALTER TABLE `pi_ap_group` DISABLE KEYS */;
INSERT INTO `pi_ap_group` (`id`, `group_name`, `add_time`) VALUES
	(0, '[默认组]', 0);
/*!40000 ALTER TABLE `pi_ap_group` ENABLE KEYS */;

-- 导出  表 ac_m.pi_ap_radio 结构
CREATE TABLE IF NOT EXISTS `pi_ap_radio` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ap_id` int(10) unsigned NOT NULL DEFAULT '0',
  `2g_channel` int(11) DEFAULT '0' COMMENT '2g无线信道',
  `2g_signal` int(11) DEFAULT '0' COMMENT '2g信号强度',
  `2g_bandwidth` int(11) DEFAULT '0' COMMENT '2g无线频率带宽',
  `2g_identify_critical` int(11) DEFAULT '0' COMMENT '2g认证/踢人临界值',
  `2g_travel_join_critical` int(11) DEFAULT '0' COMMENT '2g慢游接入临界值',
  `2g_travel_trigger_critical` int(11) DEFAULT '0' COMMENT '2g漫游触发临界值',
  `2g_minimum_rate_control` int(11) DEFAULT '0' COMMENT '2g最低速率控制',
  `2g_minimum_join_critical` int(11) DEFAULT '0' COMMENT '2g最低接入阀值',
  `2g_identify_refuse_num` int(11) DEFAULT '0' COMMENT '2g认证拒绝次数',
  `5g_channel` int(11) DEFAULT '0' COMMENT '5g无线信道',
  `5g_signal` int(11) DEFAULT '0' COMMENT '5g信号强度',
  `5g_bandwidth` int(11) DEFAULT '0' COMMENT '5g无线频率带宽',
  `5g_identify_critical` int(11) DEFAULT '0' COMMENT '5g认证/踢人临界值',
  `5g_travel_join_critical` int(11) DEFAULT '0' COMMENT '5g慢游接入临界值',
  `5g_travel_trigger_critical` int(11) DEFAULT '0' COMMENT '5g漫游触发临界值',
  `5g_minimum_join_critical` int(11) DEFAULT '0' COMMENT '5g最低接入阀值',
  `identify_control` varchar(50) NOT NULL DEFAULT '' COMMENT '认证开启控制',
  `probe_control` varchar(50) NOT NULL DEFAULT '' COMMENT '探针开启控制',
  `probe_ip` varchar(50) NOT NULL DEFAULT '' COMMENT '探针配置IP',
  `probe_port` varchar(50) NOT NULL DEFAULT '' COMMENT '探针配置PORT',
  `probe_scan_interval` int(11) DEFAULT '0' COMMENT '定时扫描间隔',
  `probe_critical` int(11) DEFAULT '0' COMMENT '探针阀值',
  `identify_intercept_addr` varchar(50) NOT NULL DEFAULT '' COMMENT '认证拦截配置地址',
  `identify_intercept_port` varchar(50) NOT NULL DEFAULT '' COMMENT '认证拦截配置端口',
  `identify_intercept_path` varchar(50) NOT NULL DEFAULT '' COMMENT '认证拦截配置路径',
  PRIMARY KEY (`id`),
  KEY `ap_id` (`ap_id`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_ap_radio 的数据：0 rows
/*!40000 ALTER TABLE `pi_ap_radio` DISABLE KEYS */;
/*!40000 ALTER TABLE `pi_ap_radio` ENABLE KEYS */;

-- 导出  表 ac_m.pi_client 结构
CREATE TABLE IF NOT EXISTS `pi_client` (
  `mac` varchar(100) NOT NULL DEFAULT '',
  `ap_id` int(10) unsigned NOT NULL DEFAULT '0',
  `ssid` varchar(100) NOT NULL DEFAULT '' COMMENT 'WIFI名称',
  `signal` smallint(6) NOT NULL DEFAULT '0' COMMENT '设备的信号强度值',
  `signal_rank` smallint(6) NOT NULL DEFAULT '0' COMMENT '设备的信号级别；强:≥-40，中:-85≤val<-40，弱:val<-85',
  `update_time` int(10) unsigned NOT NULL DEFAULT '0',
  `add_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`mac`),
  KEY `ap_id` (`ap_id`),
  KEY `ssid` (`ssid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='连接上AP的设备';

-- 正在导出表  ac_m.pi_client 的数据：0 rows
/*!40000 ALTER TABLE `pi_client` DISABLE KEYS */;
/*!40000 ALTER TABLE `pi_client` ENABLE KEYS */;

-- 导出  表 ac_m.pi_config 结构
CREATE TABLE IF NOT EXISTS `pi_config` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '',
  `value` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_config 的数据：2 rows
/*!40000 ALTER TABLE `pi_config` DISABLE KEYS */;
INSERT INTO `pi_config` (`id`, `name`, `value`) VALUES
	(1, 'batch_upgrade_switch', 'on'),
	(2, 'db_ver', '1.0.2');
/*!40000 ALTER TABLE `pi_config` ENABLE KEYS */;

-- 导出  表 ac_m.pi_defense 结构
CREATE TABLE IF NOT EXISTS `pi_defense` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '',
  `value` mediumtext,
  `title` varchar(100) DEFAULT '',
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=MyISAM AUTO_INCREMENT=8 DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_defense 的数据：7 rows
/*!40000 ALTER TABLE `pi_defense` DISABLE KEYS */;
INSERT INTO `pi_defense` (`id`, `name`, `value`, `title`) VALUES
	(1, 'arp', NULL, 'ARP表项'),
	(2, 'url_filter', '{"list":[{"id":1510308233,"url":"http:\\/\\/www.test.com","remarks":"dfgdf"}],"switch":"off"}', 'url过滤'),
	(3, 'mac_filter', '{"list":[{"id":1509952503,"mac":"54.67.235.665.t45","remarks":"hfghdfgh.54646456"},{"id":1509953494,"mac":"33.23.34.222","remarks":"555"}],"switch":"off"}', 'mac过滤'),
	(4, 'black_list', '{"list":[{"id":1509956737,"host_ip":"192.168.11.234","remarks":"\\u5907\\u6ce8\\u5907\\u6ce8\\u5907\\u6ce8\\u5907\\u6ce811111"}],"switch":"off"}', '黑名单'),
	(5, 'white_list', '{"list":[{"id":1509957353,"host_ip":"23.42.21.33","remarks":"\\u5907\\u6ce87788888"}],"switch":"off"}', '白名单'),
	(6, 'ipmac', '', 'IPMAC绑定'),
	(7, 'limit_speed', '{"list":[{"id":1513057641,"ip_start":"172.16.45.120","ip_end":"172.16.45.130","limit_down":"1000","limit_up":"1000","remarks":""}],"switch":"on","global_up":"53443","global_down":"674"}', '限速');
/*!40000 ALTER TABLE `pi_defense` ENABLE KEYS */;

-- 导出  表 ac_m.pi_defense_ipmac 结构
CREATE TABLE IF NOT EXISTS `pi_defense_ipmac` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ip` varchar(50) NOT NULL DEFAULT '',
  `mac` varchar(50) NOT NULL DEFAULT '',
  `is_bind` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '静态绑定',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_defense_ipmac 的数据：0 rows
/*!40000 ALTER TABLE `pi_defense_ipmac` DISABLE KEYS */;
/*!40000 ALTER TABLE `pi_defense_ipmac` ENABLE KEYS */;

-- 导出  表 ac_m.pi_group_wifi 结构
CREATE TABLE IF NOT EXISTS `pi_group_wifi` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `group_id` int(10) unsigned NOT NULL DEFAULT '0',
  `wifi_id` int(10) unsigned NOT NULL DEFAULT '0',
  `vlan_id` int(10) unsigned NOT NULL DEFAULT '0',
  `vlan_dhcp` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=56 DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_group_wifi 的数据：1 rows
/*!40000 ALTER TABLE `pi_group_wifi` DISABLE KEYS */;
INSERT INTO `pi_group_wifi` (`id`, `group_id`, `wifi_id`, `vlan_id`, `vlan_dhcp`) VALUES
	(1, 0, 1, 0, '');
/*!40000 ALTER TABLE `pi_group_wifi` ENABLE KEYS */;

-- 导出  表 ac_m.pi_logs 结构
CREATE TABLE IF NOT EXISTS `pi_logs` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `controller` varchar(250) NOT NULL DEFAULT '' COMMENT '操作模块Controller',
  `action` varchar(250) NOT NULL DEFAULT '' COMMENT '操作模块Action',
  `origin_data` text NOT NULL COMMENT '原始数据',
  `object_data` text NOT NULL COMMENT '新的数据',
  `log_info` varchar(1000) NOT NULL DEFAULT '' COMMENT '日志内容',
  `log_time` int(11) NOT NULL DEFAULT '0' COMMENT '日志时间',
  `log_ip` varchar(50) NOT NULL DEFAULT '' COMMENT '日志IP',
  `user_id` int(11) NOT NULL DEFAULT '0' COMMENT '用户ID',
  `username` varchar(50) NOT NULL DEFAULT '' COMMENT '用户名',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COMMENT='系统操作日志表';

-- 正在导出表  ac_m.pi_logs 的数据：13 rows
/*!40000 ALTER TABLE `pi_logs` DISABLE KEYS */;
INSERT INTO `pi_logs` (`id`, `controller`, `action`, `origin_data`, `object_data`, `log_info`, `log_time`, `log_ip`, `user_id`, `username`) VALUES
	(1, 'AntiAttackPi', 'limit_speed_del', '', '', '删除一条IP限速', 1513049503, '172.16.45.125', 1, 'admin'),
	(2, 'AntiAttackPi', 'limit_speed_del', '', '', '删除一条IP限速', 1513049505, '172.16.45.125', 1, 'admin'),
	(3, 'AntiAttackPi', 'limit_speed_del', '', '', '删除一条IP限速', 1513049507, '172.16.45.125', 1, 'admin'),
	(4, 'AntiAttackPi', 'limit_speed_del', '', '', '删除一条IP限速', 1513049509, '172.16.45.125', 1, 'admin'),
	(5, 'AntiAttackPi', 'limit_speed_del', '', '', '删除一条IP限速', 1513049510, '172.16.45.125', 1, 'admin'),
	(6, 'AntiAttackPi', 'limit_speed_del', '', '', '删除一条IP限速', 1513049513, '172.16.45.125', 1, 'admin'),
	(7, 'AntiAttackPi', 'limit_speed_add', '', '', '添加一条IP限速', 1513049583, '172.16.45.125', 1, 'admin'),
	(8, 'AntiAttackPi', 'limit_speed_add', '', '', '添加一条IP限速', 1513050038, '172.16.45.125', 1, 'admin'),
	(9, 'AntiAttackPi', 'limit_speed_del', '', '', '删除一条IP限速', 1513050118, '172.16.45.125', 1, 'admin'),
	(10, 'AntiAttackPi', 'limit_speed_del', '', '', '删除一条IP限速', 1513050429, '172.16.45.125', 1, 'admin'),
	(11, 'AntiAttackPi', 'limit_speed_add', '', '', '添加一条IP限速', 1513057478, '172.16.45.125', 1, 'admin'),
	(12, 'AntiAttackPi', 'limit_speed_del', '', '', '删除一条IP限速', 1513057611, '172.16.45.125', 1, 'admin'),
	(13, 'AntiAttackPi', 'limit_speed_add', '', '', '添加一条IP限速', 1513057641, '172.16.45.125', 1, 'admin');
/*!40000 ALTER TABLE `pi_logs` ENABLE KEYS */;

-- 导出  表 ac_m.pi_logs_client 结构
CREATE TABLE IF NOT EXISTS `pi_logs_client` (
  `mac` varchar(50) NOT NULL DEFAULT '',
  `ap_id` int(10) unsigned NOT NULL DEFAULT '0',
  `ssid` varchar(50) NOT NULL DEFAULT '',
  `shop_id` int(10) unsigned NOT NULL DEFAULT '0',
  `up_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '上线时间',
  `down_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '下线时间；在下一次没有收到此mac时，视为下线。',
  KEY `shop_id` (`shop_id`),
  KEY `ap_id` (`ap_id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_logs_client 的数据：0 rows
/*!40000 ALTER TABLE `pi_logs_client` DISABLE KEYS */;
/*!40000 ALTER TABLE `pi_logs_client` ENABLE KEYS */;

-- 导出  表 ac_m.pi_patch_files 结构
CREATE TABLE IF NOT EXISTS `pi_patch_files` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `file_name` varchar(50) NOT NULL DEFAULT '' COMMENT '文件名',
  `file_path` varchar(250) NOT NULL DEFAULT '' COMMENT '文件存放路径',
  `file_md5` varchar(50) NOT NULL DEFAULT '' COMMENT '文件的MD5',
  `file_size` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '文件大小',
  `firmware_model` varchar(50) NOT NULL DEFAULT '' COMMENT '设备型号',
  `firmware_version` varchar(50) NOT NULL DEFAULT '' COMMENT '设备版本',
  `add_time` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '添加时间',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_patch_files 的数据：0 rows
/*!40000 ALTER TABLE `pi_patch_files` DISABLE KEYS */;
/*!40000 ALTER TABLE `pi_patch_files` ENABLE KEYS */;

-- 导出  表 ac_m.pi_port_map 结构
CREATE TABLE IF NOT EXISTS `pi_port_map` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `map` varchar(50) NOT NULL DEFAULT '',
  `inner_ip` varchar(50) NOT NULL DEFAULT '',
  `inner_port` int(10) unsigned NOT NULL DEFAULT '0',
  `out_ip` varchar(50) NOT NULL DEFAULT '',
  `out_eth` int(10) unsigned NOT NULL DEFAULT '0',
  `out_port` int(10) unsigned NOT NULL DEFAULT '0',
  `protocol` varchar(50) NOT NULL DEFAULT '',
  `add_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_port_map 的数据：0 rows
/*!40000 ALTER TABLE `pi_port_map` DISABLE KEYS */;
/*!40000 ALTER TABLE `pi_port_map` ENABLE KEYS */;

-- 导出  表 ac_m.pi_rules 结构
CREATE TABLE IF NOT EXISTS `pi_rules` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '',
  `groups` varchar(50) NOT NULL DEFAULT '',
  `signs` varchar(50) NOT NULL DEFAULT '',
  `actions` varchar(250) NOT NULL DEFAULT '',
  `orders` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `sign` (`signs`),
  KEY `actions` (`actions`)
) ENGINE=MyISAM AUTO_INCREMENT=14 DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_rules 的数据：13 rows
/*!40000 ALTER TABLE `pi_rules` DISABLE KEYS */;
INSERT INTO `pi_rules` (`id`, `name`, `groups`, `signs`, `actions`, `orders`) VALUES
	(1, '系统首页', '', 'system_index', 'Index/stability_eg', 0),
	(2, '接口配置', '1.网络配置', 'interface_config', 'NetConfig/interface_conf', 0),
	(3, '端口映射', '1.网络配置', 'port_mapping', 'NetConfig/nat_pi', 0),
	(4, '无线管理首页', '2.无线管理', 'wireless_index', 'WuXianGuanLi/home', 0),
	(5, '无线网络', '2.无线管理', 'wireless_network', 'WuXianGuanLi/wlan', 0),
	(6, 'AP管理', '2.无线管理', 'ap_manage', 'WuXianGuanLi/ap_manage', 0),
	(7, 'AP升级', '2.无线管理', 'ap_upgrade', 'WuXianGuanLi/update_ap', 0),
	(8, '高级配置', '2.无线管理', 'advanced_config', 'WuXianGuanLi/network_adjust', 0),
	(9, '系统设置', '3.高级选项', 'system_settings', 'SystemSet/sysset_menu', 0),
	(10, '系统升级', '3.高级选项', 'system_upgrade', 'SystemSet/setsys_update', 0),
	(11, '管理员权限', '3.高级选项', 'admin_rights', 'SystemSet/auth', 0),
	(12, '检测网络', '3.高级选项', 'detect_network', 'SystemSet/detect_menu', 0),
	(13, '系统日志', '3.高级选项', 'system_log', 'SystemSet/sys_logo_menu', 0);
/*!40000 ALTER TABLE `pi_rules` ENABLE KEYS */;

-- 导出  表 ac_m.pi_shop 结构
CREATE TABLE IF NOT EXISTS `pi_shop` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `shop_name` varchar(50) NOT NULL DEFAULT '',
  `add_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `shop_name` (`shop_name`)
) ENGINE=MyISAM AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_shop 的数据：2 rows
/*!40000 ALTER TABLE `pi_shop` DISABLE KEYS */;
INSERT INTO `pi_shop` (`id`, `shop_name`, `add_time`) VALUES
	(1, '门店111111111', 1503043281),
	(2, '门店2222211111', 1503044035);
/*!40000 ALTER TABLE `pi_shop` ENABLE KEYS */;

-- 导出  表 ac_m.pi_shop_ap 结构
CREATE TABLE IF NOT EXISTS `pi_shop_ap` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `shop_id` int(10) unsigned NOT NULL DEFAULT '0',
  `ap_id` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=16 DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_shop_ap 的数据：3 rows
/*!40000 ALTER TABLE `pi_shop_ap` DISABLE KEYS */;
INSERT INTO `pi_shop_ap` (`id`, `shop_id`, `ap_id`) VALUES
	(13, 2, 22),
	(14, 2, 20),
	(15, 2, 19);
/*!40000 ALTER TABLE `pi_shop_ap` ENABLE KEYS */;

-- 导出  表 ac_m.pi_wifi 结构
CREATE TABLE IF NOT EXISTS `pi_wifi` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `wifi_name` varchar(100) NOT NULL DEFAULT '' COMMENT 'WIFI名称，SSID',
  `wifi_password` varchar(100) NOT NULL DEFAULT '' COMMENT 'WIFI密码',
  `wifi_encrypt_mode` varchar(100) NOT NULL DEFAULT '' COMMENT 'WIFI加密类型',
  `wifi_visible` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT 'WIFI是否可见',
  `wifi_channel` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '无线信道',
  `is_2g` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '作用于无线2.4G',
  `is_5g` smallint(5) unsigned NOT NULL DEFAULT '0' COMMENT '作用于无线5G',
  `users_amount` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '关联的用户数，在线使用人数',
  `limit_up` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '上传限速',
  `limit_down` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '下载限速',
  `limit_users_max` int(10) unsigned NOT NULL DEFAULT '0' COMMENT '最大无线用户数',
  `close_time` varchar(1000) NOT NULL DEFAULT '' COMMENT '关闭网络时间；格式：{"group":"","time_range":[{"week_start":"","week_end":"","time_start":"","time_end":""}]}',
  `add_time` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `wifi_name` (`wifi_name`)
) ENGINE=MyISAM AUTO_INCREMENT=39 DEFAULT CHARSET=utf8;

-- 正在导出表  ac_m.pi_wifi 的数据：1 rows
/*!40000 ALTER TABLE `pi_wifi` DISABLE KEYS */;
INSERT INTO `pi_wifi` (`id`, `wifi_name`, `wifi_password`, `wifi_encrypt_mode`, `wifi_visible`, `wifi_channel`, `is_2g`, `is_5g`, `users_amount`, `limit_up`, `limit_down`, `limit_users_max`, `close_time`, `add_time`) VALUES
	(1, 'wifi_default', '12345678', 'psk', 0, 0, 1, 1, 0, 0, 0, 0, '', 1499761450);
/*!40000 ALTER TABLE `pi_wifi` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
