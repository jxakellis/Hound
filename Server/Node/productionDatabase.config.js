module.exports = {
  apps: [
    {
      name: 'Production Database',
      script: `sudo npm --prefix ${__dirname}/Production run productionDatabase`,
      out_file: `${__dirname}/Production/logs/outProductonDatabase.log`,
      error_file: `${__dirname}/Production/logs/errorProductionDatabase.log`,
      // Process is only considered running if it stays alive for more than min_uptime
      // 15000 ms
      min_uptime: 15000,
      restart_delay: 1000,
    },
  ],
};
