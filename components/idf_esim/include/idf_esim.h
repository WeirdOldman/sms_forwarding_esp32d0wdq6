#pragma once

#include <string>
#include <vector>

#include "esp_err.h"

struct IdfEsimProfile {
    std::string iccid;
    std::string isdpAid;
    std::string state;
    std::string nickname;
    std::string serviceProvider;
    std::string profileName;
    std::string profileClass;
};

esp_err_t idf_esim_get_eid(std::string& eid, std::string& message);
esp_err_t idf_esim_list_profiles(std::vector<IdfEsimProfile>& profiles,
                                 std::string& eid,
                                 std::string& message);
esp_err_t idf_esim_enable_profile(const std::string& identifier,
                                  bool refresh,
                                  std::string& message);
esp_err_t idf_esim_disable_profile(const std::string& identifier,
                                   bool refresh,
                                   std::string& message);
esp_err_t idf_esim_delete_profile(const std::string& identifier,
                                  std::string& message);
esp_err_t idf_esim_set_nickname(const std::string& identifier,
                                const std::string& nickname,
                                std::string& message);
esp_err_t idf_esim_switch_profile(const std::string& identifier,
                                  bool refresh,
                                  std::string& message);
std::string idf_esim_mask_profile_id(const std::string& identifier);
// 判断一个 Profile 是否匹配用户输入的标识（ICCID/ISD-P AID/昵称/名称/运营商名，忽略大小写）
bool idf_esim_profile_matches(const IdfEsimProfile& profile, const std::string& identifier);
