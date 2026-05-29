// SSAS Connection Configuration
// This file contains utilities for connecting to SSAS

const ssasConnectionConfig = {
  // SSAS Server Configuration
  server: {
    host: 'localhost',
    port: 2383,
    protocol: 'http',
    path: '/olap/msmdpump.dll'
  },

  // Database and Cube Configuration
  database: 'Localhost_dw_project',

  // Available Cubes
  cubes: {
    sales_cube: {
      name: 'sales_cube',
      description: 'Sales Data Cube',
      facts: ['FACT_DOANH_SO'],
      dimensions: [
        {
          name: 'DIM_MATHANG',
          description: 'Product Dimension',
          hierarchies: ['All', 'Category', 'ProductName']
        },
        {
          name: 'DIM_THOIGIAN',
          description: 'Time Dimension',
          hierarchies: ['All', 'Year', 'Quarter', 'Month', 'Day']
        },
        {
          name: 'DIM_KHACHHANG',
          description: 'Customer Dimension',
          hierarchies: ['All', 'Region', 'CustomerSegment', 'Customer']
        }
      ],
      measures: [
        { name: 'Amount', aggregation: 'Sum' },
        { name: 'Quantity', aggregation: 'Sum' },
        { name: 'OrderCount', aggregation: 'Count' }
      ]
    },

    inventory_cube: {
      name: 'inventory_cube',
      description: 'Inventory Data Cube',
      facts: ['FACT_TON_KHO'],
      dimensions: [
        {
          name: 'DIM_MATHANG',
          description: 'Product Dimension',
          hierarchies: ['All', 'Category', 'ProductName']
        },
        {
          name: 'DIM_THOIGIAN',
          description: 'Time Dimension',
          hierarchies: ['All', 'Year', 'Quarter', 'Month', 'Day']
        },
        {
          name: 'DIM_CUAHANG',
          description: 'Store Dimension',
          hierarchies: ['All', 'Region', 'StoreType', 'Store']
        }
      ],
      measures: [
        { name: 'StockLevel', aggregation: 'Average' },
        { name: 'StockValue', aggregation: 'Sum' },
        { name: 'ReorderPoints', aggregation: 'Average' }
      ]
    }
  },

  // Authentication
  auth: {
    mode: 'windows', // 'windows' or 'basic'
    username: '', // For basic auth
    password: ''  // For basic auth
  },

  // Connection String
  getConnectionString() {
    const { host, port, protocol, path } = this.server;
    return `${protocol}://${host}:${port}${path}`;
  },

  // Get SSAS URL
  getSSASUrl() {
    return this.getConnectionString();
  },

  // Get cube configuration
  getCubeConfig(cubeName) {
    return this.cubes[cubeName] || null;
  },

  // Get all dimensions for a cube
  getDimensions(cubeName) {
    const cube = this.cubes[cubeName];
    return cube ? cube.dimensions : [];
  },

  // Get all measures for a cube
  getMeasures(cubeName) {
    const cube = this.cubes[cubeName];
    return cube ? cube.measures : [];
  }
};

module.exports = ssasConnectionConfig;
