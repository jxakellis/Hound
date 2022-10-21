module.exports = {
  apps: [
    {
      name: 'Development Database',
      script: `sudo npm --prefix ${__dirname}/Development run developmentDatabase`,
      out_file: `${__dirname}/Development/logs/outDevelopmentDatabase.log`,
      error_file: `${__dirname}/Development/logs/errorDevelopmentDatabase.log`,
      // Process is only considered running if it stays alive for more than min_uptime
      // 15000 ms
      min_uptime: 15000,
      restart_delay: 1000,
    },
  ],
};
