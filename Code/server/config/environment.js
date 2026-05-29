// Environment Configuration
// Edit this file based on your environment

module.exports = {
  // Development
  development: {
    nodeEnv: 'development',
    port: 5000,
    clientPort: 3000,
    debug: true,

    oracle: {
      user: process.env.ORACLE_USER || 'idb_schema',
      password: process.env.ORACLE_PASSWORD || 'IDB#2026Secure!',
      connectString: process.env.ORACLE_CONNECT_STRING || 'localhost/PDB_IDB',
      poolMin: 2,
      poolMax: 10,
      poolIncrement: 2
    },

    cors: {
      origin: 'http://localhost:3000',
      credentials: true
    }
  },

  // Production
  production: {
    nodeEnv: 'production',
    port: process.env.PORT || 5000,
    clientPort: 3000,
    debug: false,

    oracle: {
      user: process.env.ORACLE_USER || 'system',
      password: process.env.ORACLE_PASSWORD || 'oracle',
      connectString: process.env.ORACLE_CONNECT_STRING || 'localhost:1521/XEPDB1',
      poolMin: 2,
      poolMax: 10,
      poolIncrement: 2
    },

    cors: {
      origin: process.env.CORS_ORIGIN || 'https://yourdomain.com',
      credentials: true
    }
  },

  // Staging
  staging: {
    nodeEnv: 'staging',
    port: 5000,
    clientPort: 3000,
    debug: true,

    oracle: {
      user: process.env.ORACLE_USER || 'system',
      password: process.env.ORACLE_PASSWORD || 'oracle',
      connectString: process.env.ORACLE_CONNECT_STRING || 'localhost:1521/XEPDB1',
      poolMin: 2,
      poolMax: 10,
      poolIncrement: 2
    },

    cors: {
      origin: 'https://staging.yourdomain.com',
      credentials: true
    }
  }
};
