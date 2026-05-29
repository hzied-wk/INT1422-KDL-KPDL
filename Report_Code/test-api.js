/**
 * Quick Test Script for OLAP Web Interface
 * Run this to verify the backend API is working
 */

const axios = require('axios');

const API_URL = 'http://localhost:5000/api';

// Colors for console output
const colors = {
  reset: '\x1b[0m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[36m'
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

async function testAPI() {
  log('\n=== OLAP Web Interface API Test ===\n', 'blue');

  try {
    // Test 1: Get Cubes
    log('Test 1: Getting available cubes...', 'yellow');
    const cubesResponse = await axios.get(`${API_URL}/cubes`);
    log('✓ Cubes retrieved:', 'green');
    console.log(cubesResponse.data);

    // Test 2: Query Data
    log('\nTest 2: Querying data...', 'yellow');
    const queryResponse = await axios.post(`${API_URL}/query`, {
      cube: 'sales_cube',
      mdxQuery: 'SELECT NON EMPTY [Measures].[Amount] ON 0, NON EMPTY [Product] ON 1 FROM [sales_cube]'
    });
    log('✓ Data queried:', 'green');
    console.log(queryResponse.data);

    // Test 3: Drill Down
    log('\nTest 3: Testing Drill Down...', 'yellow');
    const drillDownResponse = await axios.post(`${API_URL}/operations/drill-down`, {
      cube: 'sales_cube',
      dimension: 'DIM_MATHANG',
      currentLevel: 0
    });
    log('✓ Drill down executed:', 'green');
    console.log(drillDownResponse.data);

    // Test 4: Roll Up
    log('\nTest 4: Testing Roll Up...', 'yellow');
    const rollUpResponse = await axios.post(`${API_URL}/operations/roll-up`, {
      cube: 'sales_cube',
      dimension: 'DIM_MATHANG',
      currentLevel: 1
    });
    log('✓ Roll up executed:', 'green');
    console.log(rollUpResponse.data);

    // Test 5: Slice & Dice
    log('\nTest 5: Testing Slice & Dice...', 'yellow');
    const sliceDiceResponse = await axios.post(`${API_URL}/operations/slice-dice`, {
      cube: 'sales_cube',
      filters: {
        'DIM_THOIGIAN': '2024',
        'DIM_KHACHHANG': 'North'
      }
    });
    log('✓ Slice & dice executed:', 'green');
    console.log(sliceDiceResponse.data);

    // Test 6: Pivot
    log('\nTest 6: Testing Pivot...', 'yellow');
    const pivotResponse = await axios.post(`${API_URL}/operations/pivot`, {
      cube: 'sales_cube',
      rows: ['DIM_MATHANG'],
      columns: ['DIM_THOIGIAN'],
      measures: ['Amount']
    });
    log('✓ Pivot executed:', 'green');
    console.log(pivotResponse.data);

    log('\n=== All Tests Passed! ✓ ===\n', 'green');

  } catch (error) {
    log(`\n✗ Error: ${error.message}`, 'red');

    if (error.response) {
      log(`Status: ${error.response.status}`, 'red');
      log(`Response:`, 'red');
      console.log(error.response.data);
    } else if (error.request) {
      log('No response received. Is the backend server running?', 'red');
      log('Start backend with: npm start', 'yellow');
    } else {
      log('Error setting up request:', 'red');
      console.log(error);
    }

    process.exit(1);
  }
}

// Run tests
log('Make sure backend is running: npm start', 'yellow');
log('Waiting 2 seconds before starting tests...\n', 'yellow');

setTimeout(() => {
  testAPI();
}, 2000);
