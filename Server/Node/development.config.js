module.exports = {
  apps: [
    {
      name: 'Prod Ser Dev Database',
      script: 'sudo npm --prefix ./Development run productionServerDevelopmentDatabase',
      out_file: './Development/logs/outProductionServerDevelopmentDatabase.log',
      error_file: './Development/logs/errorProductionServerDevelopmentDatabase.log',
      // Process is only considered running if it stays alive for more than min_uptime
      // 15000 ms
      min_uptime: 15000,
      restart_delay: 1000,
    },
  ],
};
