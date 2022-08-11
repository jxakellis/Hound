module.exports = {
  apps: [
    {
      name: 'Production Server Production Database',
      script: 'sudo npm run productionServerProductionDatabase',
      error_file: './logs/errorProductionServerProductionDatabase.log',
      out_file: './logs/outProductionServerProductionDatabase.log',
    },
    {
      name: 'Production Server Development Database',
      script: 'sudo npm run productionServerDevelopmentDatabase',
      error_file: './logs/errorProductionServerDevelopmentDatabase.log',
      out_file: './logs/outProductionServerDevelopmentDatabase.log',
    },
  ],
};
