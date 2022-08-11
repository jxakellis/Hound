module.exports = {
  apps: [
    {
      name: 'Prod Ser Prod Database',
      script: 'sudo npm --prefix ./Production run productionServerProductionDatabase',
      out_file: './Production/logs/outProductionServerProductionDatabase.log',
      error_file: './Production/logs/errorProductionServerProductionDatabase.log',
      // Process is only considered running if it stays alive for more than min_uptime
      // 15000 ms
      min_uptime: 15000,
      restart_delay: 1000,
    },
  ],
};
