module.exports = {
  apps: [
    {
      name: 'Prod Ser Prod Database',
      script: 'sudo npm --prefix /home/jxakellis/Documents/Hound/Server/Node/Production run productionServerProductionDatabase',
      out_file: '/home/jxakellis/Documents/Hound/Server/Node/Production/logs/outProductionServerProductionDatabase.log',
      error_file: '/home/jxakellis/Documents/Hound/Server/Node/Production/logs/errorProductionServerProductionDatabase.log',
      // Process is only considered running if it stays alive for more than min_uptime
      // 15000 ms
      min_uptime: 15000,
      restart_delay: 1000,
    },
  ],
};
