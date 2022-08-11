module.exports = {
  apps: [
    {
      name: 'Prod Ser Dev Database',
      script: 'sudo npm --prefix ./Development run productionServerDevelopmentDatabase',
      out_file: './Development/logs/outProductionServerDevelopmentDatabase.log',
      error_file: './Development/logs/errorProductionServerDevelopmentDatabase.log',
    },
  ],
};
