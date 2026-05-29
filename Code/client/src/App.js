import React, { useState, useEffect, useCallback } from 'react';
import axios from 'axios';
import 'bootstrap/dist/css/bootstrap.min.css';
import './App.css';
import CubeSelector from './components/CubeSelector';
import DataViewer from './components/DataViewer';
import OLAPOperations from './components/OLAPOperations';

function App() {
  const [selectedCube, setSelectedCube] = useState('sales_cube');
  const [cubes, setCubes] = useState([]);
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);
  const [activeOperation, setActiveOperation] = useState(null);
  const [error, setError] = useState(null);

  const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

  // Configure axios
  axios.defaults.timeout = 10000;

  const fetchCubes = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      const response = await axios.get(`${API_URL}/cubes`);
      setCubes(response.data.cubes);
      // Fetch initial data for default cube
      await fetchData('sales_cube');
    } catch (error) {
      const errMsg = error.response?.data?.error || error.message || 'Failed to load cubes';
      setError(`Error loading cubes: ${errMsg}`);
      console.error('Error fetching cubes:', error);
      // Set mock cubes if backend is down
      setCubes([
        { name: 'sales_cube', description: 'Sales Data Cube' },
        { name: 'inventory_cube', description: 'Inventory Data Cube' }
      ]);
    } finally {
      setLoading(false);
    }
  }, [API_URL]); // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    fetchCubes();
  }, [fetchCubes]);

  const handleCubeChange = async (cubeName) => {
    setSelectedCube(cubeName);
    await fetchData(cubeName);
  };

  const fetchData = async (cube) => {
    try {
      setLoading(true);
      setError(null);
      const response = await axios.post(`${API_URL}/query`, {
        cube,
        mdxQuery: `SELECT NON EMPTY [Measures].[Amount] ON 0, NON EMPTY [Product] ON 1 FROM [${cube}]`
      });
      setData(response.data);
    } catch (error) {
      console.error('Error fetching data:', error.response?.data?.error || error.message);
      // Use mock data if backend fails
      setData({
        columns: ['Product', 'Year', 'Amount'],
        rows: [
          ['Laptop', '2023', 50000],
          ['Desktop', '2023', 30000],
          ['Tablet', '2023', 20000],
          ['Laptop', '2024', 60000],
          ['Desktop', '2024', 35000],
          ['Tablet', '2024', 25000]
        ]
      });
    } finally {
      setLoading(false);
    }
  };

  const handleOperation = async (operationType, operationData) => {
    try {
      setLoading(true);
      setError(null);
      const endpoint = `${API_URL}/operations/${operationType}`;
      const response = await axios.post(endpoint, {
        cube: selectedCube,
        ...operationData
      });
      setData(response.data);
      setActiveOperation(operationType);
    } catch (error) {
      const errorMsg = error.response?.data?.error || error.message || `Operation ${operationType} failed`;
      setError(`Error: ${errorMsg}`);
      console.error(`Error executing ${operationType}:`, error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App container-fluid">
      <header className="header bg-primary text-white py-4 mb-4">
        <h1>📊 OLAP Web Interface Demo</h1>
        <p>Interactive OLAP Operations: Drill Down, Roll Up, Slice & Dice, Pivot</p>
      </header>

      {error && (
        <div className="alert alert-warning alert-dismissible fade show" role="alert">
          <strong>⚠️ Warning:</strong> {error}
          <button type="button" className="btn-close" onClick={() => setError(null)}></button>
        </div>
      )}

      <div className="row">
        <div className="col-md-3">
          <CubeSelector
            cubes={cubes}
            selectedCube={selectedCube}
            onCubeChange={handleCubeChange}
            loading={loading}
          />
          <OLAPOperations
            onOperation={handleOperation}
            activeOperation={activeOperation}
            loading={loading}
          />
        </div>

        <div className="col-md-9">
          <DataViewer
            data={data}
            loading={loading}
            activeOperation={activeOperation}
          />
        </div>

      </div>
    </div>
  );
}

export default App;
