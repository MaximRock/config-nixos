{
  pkgs,
  ...
}: {
  programs.throne = {
    enable = true;
    # Throne 1.3.2 из unstable: только там есть поддержка xhttp (Reality+xhttp)
    package = pkgs.unstable.throne;
    # tunMode из модуля 26.05 НЕ включать: он создаёт wrapper 'throne-core'
    # из несуществующего у 1.3.2 файла share/throne/Core, плюс тянет
    # security.polkit.enablePkexecWrapper, которой в 26.05 нет
  };

  # Throne 1.3.2 ищет ядро по имени ThroneCore на PATH (NKR_CORE_IN_PATH).
  # Тот же wrapper, что создаёт модуль из unstable, но локально (26.05-модуль
  # не знает нового имени ядра).
  security.wrappers."ThroneCore" = {
    source = "${pkgs.unstable.throne}/share/throne/ThroneCore";
    owner = "root";
    group = "root";
    # caps из upstream (sing-box.service), как в модуле unstable
    capabilities = "cap_net_admin,cap_net_raw,cap_net_bind_service,cap_sys_ptrace,cap_dac_read_search+ep";
  };
}
