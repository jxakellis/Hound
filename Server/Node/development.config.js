module.exports = {
  apps: [
    {
      name: 'Prod Ser Dev Database',
      script: 'sudo npm --prefix /home/jxakellis/Documents/Hound/Server/Node/Development run productionServerDevelopmentDatabase',
      out_file: '/home/jxakellis/Documents/Hound/Server/Node/Development/logs/outProductionServerDevelopmentDatabase.log',
      error_file: '/home/jxakellis/Documents/Hound/Server/Node/Development/logs/errorProductionServerDevelopmentDatabase.log',
      // Process is only considered running if it stays alive for more than min_uptime
      // 15000 ms
      min_uptime: 15000,
      restart_delay: 1000,
    },
  ],
};
