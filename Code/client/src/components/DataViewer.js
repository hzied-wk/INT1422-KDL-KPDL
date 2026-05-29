import React from 'react';
import {
  BarChart,
  Bar,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer
} from 'recharts';

function DataViewer({ data, loading, activeOperation }) {
  const COLORS = ['#0d6efd', '#6f42c1', '#fd7e14', '#198754', '#dc3545', '#20c997'];

  if (loading) {
    return (
      <div className="loading-spinner">
        <div>
          <div className="spinner-border text-primary" role="status">
            <span className="visually-hidden">Loading...</span>
          </div>
          <p className="mt-2">Loading data...</p>
        </div>
      </div>
    );
  }

  if (!data || Object.keys(data).length === 0) {
    return (
      <div className="data-table">
        <div className="no-data">
          <p>Select a cube and operation to view data</p>
        </div>
      </div>
    );
  }

  const renderChart = () => {
    if (!data.rows) return null;

    const chartData = data.rows.map((row, index) => {
      if (Array.isArray(row)) {
        return {
          name: row[0],
          value: Number(row[2]) || 0
        };
      }
      return row;
    });

    return (
      <div className="chart-container">
        <h5>📈 Biểu Đồ Dữ Liệu</h5>
        <ResponsiveContainer width="100%" height={300}>
          <BarChart data={chartData}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="name" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Bar dataKey="value" fill="#0d6efd" />
          </BarChart>
        </ResponsiveContainer>
      </div>
    );
  };

  const renderTable = () => {
    if (!data.rows || data.rows.length === 0) {
      return (
        <div className="no-data">
          <p>No data available</p>
        </div>
      );
    }

    return (
      <div className="table-responsive">
        <table className="table table-hover">
          <thead>
            <tr>
              {data.columns && data.columns.map((col, idx) => (
                <th key={idx}>{col}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {data.rows.map((row, idx) => (
              <tr key={idx}>
                {Array.isArray(row) ? (
                  row.map((cell, cellIdx) => (
                    <td key={cellIdx}>{cell}</td>
                  ))
                ) : (
                  <td colSpan={data.columns?.length || 1}>{JSON.stringify(row)}</td>
                )}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  };

  const renderPivotTable = () => {
    if (!data.data || !Array.isArray(data.data)) return null;

    return (
      <div className="table-responsive">
        <table className="table table-hover table-bordered">
          <thead>
            <tr>
              <th>{data.rows ? data.rows[0] : 'Items'}</th>
              {data.columns && data.columns.map((col) => (
                <th key={col} className="text-center">
                  {col}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {data.data[0] && data.data[0].map((item, idx) => (
              <tr key={idx}>
                <td><strong>{item.label}</strong></td>
                {Object.keys(item).map((key) => {
                  if (key === 'label') return null;
                  return (
                    <td key={key} className="text-end">
                      {item[key].toLocaleString()}
                    </td>
                  );
                })}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    );
  };

  const getOperationBadge = () => {
    const badges = {
      'drill-down': { icon: '🔍', text: 'Drill Down', class: 'badge-drill-down' },
      'roll-up': { icon: '🔼', text: 'Roll Up', class: 'badge-roll-up' },
      'slice-dice': { icon: '🎲', text: 'Slice & Dice', class: 'badge-slice-dice' },
      'pivot': { icon: '🔄', text: 'Pivot', class: 'badge-pivot' }
    };

    if (activeOperation && badges[activeOperation]) {
      const badge = badges[activeOperation];
      return (
        <span className={`operation-badge ${badge.class}`}>
          {badge.icon} {badge.text}
        </span>
      );
    }
    return null;
  };

  return (
    <div className="data-table">
      {activeOperation && (
        <div className="mb-3">
          {getOperationBadge()}
        </div>
      )}

      <h5 className="mb-3">📋 Kết Quả Dữ Liệu</h5>

      {renderChart()}

      {activeOperation === 'pivot' ? renderPivotTable() : renderTable()}

      <div className="mt-3 text-muted small">
        <p>
          Số lượng dòng: <strong>{data.rows ? data.rows.length : 0}</strong>
        </p>
      </div>
    </div>
  );
}

export default DataViewer;
