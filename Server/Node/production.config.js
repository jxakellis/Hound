module.exports = {
  apps: [
    {
      name: 'Prod Ser Prod Database',
      script: 'sudo npm --prefix ./Production run productionServerProductionDatabase',
      out_file: './Production/logs/outProductionServerProductionDatabase.log',
      error_file: './Production/logs/errorProductionServerProductionDatabase.log',
    },
  ],
};
