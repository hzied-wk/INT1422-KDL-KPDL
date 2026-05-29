import React from 'react';

function CubeSelector({ cubes, selectedCube, onCubeChange, loading }) {
  return (
    <div className="card">
      <div className="card-header">
        📦 Select Cube
      </div>
      <div className="card-body">
        {cubes.length === 0 ? (
          <p className="text-muted">Loading cubes...</p>
        ) : (
          <div className="btn-group-vertical w-100" role="group">
            {cubes.map((cube) => (
              <button
                key={cube.name}
                type="button"
                className={`btn ${
                  selectedCube === cube.name
                    ? 'btn-primary'
                    : 'btn-outline-primary'
                }`}
                onClick={() => onCubeChange(cube.name)}
                disabled={loading}
              >
                <strong>{cube.name}</strong>
                <br />
                <small>{cube.description}</small>
              </button>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}

export default CubeSelector;
